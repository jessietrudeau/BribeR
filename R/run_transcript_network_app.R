#' Run the Transcript–Topic–Speaker Network App
#'
#' Launches an interactive Shiny app visualizing relationships between speakers,
#' topics, and transcripts. The app is **schema-driven** and works with *any dataset*
#' following the BribeRdata metadata structure.
#'
#' @param meta_dir Path or URL to a folder (or base URL) containing metadata CSVs:
#'   - **Descriptions**: includes `n` and `topic_*` columns (each `topic_` column marks presence with `"x"`)
#'   - **Speakers per transcript**: includes `n` and one or more speaker columns
#'   - **Topic Descriptions**: includes `topics` and `descriptions` columns
#'   - **Actors**: includes at least `speaker_std`, and optionally `Type` and `Position` columns
#' @param transcript_dir Optional path or URL to transcript CSV/TSV files
#'   containing a `speaker_std` column, used to compute speaker frequency.
#' @param highlight_nodes Optional named list or two-column data frame specifying
#'   which nodes to display with circular images. The names (or first column)
#'   correspond to node IDs; the values (or second column) give image paths or URLs.
#'
#' @details
#' This function is **data-agnostic**:
#' - You can use *any dataset*, as long as files match the above schema.
#' - Actor `Type` values can be anything meaningful to your dataset (e.g. `"Academic"`, `"NGO Worker"`, `"Politician"`).
#' - The app dynamically colors and groups nodes by these `Type` values.
#'
#' @return Launches a Shiny app.
#' @export
#'
#' @examples
#' \dontrun{
#' run_transcript_network_app(
#'   meta_dir = "https://raw.githubusercontent.com/username/repo/main/data/",
#'   transcript_dir = "path/to/transcripts/",
#'   highlight_nodes = list("alice_smith" = "https://.../alice.png")
#' )
#' }
run_transcript_network_app <- function(meta_dir, transcript_dir = NULL, highlight_nodes = NULL) {

  # ---- 0) Helpers ----
  is_url <- function(x) grepl("^https?://", x, ignore.case = TRUE)
  rtrim_slash <- function(x) sub("/+$", "/", x)

  if (missing(meta_dir)) stop("`meta_dir` is required (local path or URL).", call. = FALSE)

  # Dynamic file discovery
  find_file <- function(base, pattern) {
    if (is_url(base)) {
      paste0(rtrim_slash(base), pattern)
    } else {
      files <- fs::dir_ls(base, regexp = "(?i)\\.csv$", recurse = FALSE)
      match <- files[stringr::str_detect(basename(files), pattern)]
      if (length(match) == 0) return(NULL)
      match[1]
    }
  }

  safe_read_csv <- function(path_or_url) {
    if (is.null(path_or_url)) return(tibble::tibble())
    if (is_url(path_or_url)) {
      tryCatch(readr::read_csv(path_or_url, col_types = readr::cols()),
               error = function(e) tibble::tibble())
    } else if (fs::file_exists(path_or_url)) {
      readr::read_csv(path_or_url, col_types = readr::cols())
    } else tibble::tibble()
  }

  # ---- 1) Load metadata ----
  desc_path   <- find_file(meta_dir, "description")
  spkr_path   <- find_file(meta_dir, "speaker")
  topic_path  <- find_file(meta_dir, "topic")
  actor_path  <- find_file(meta_dir, "actor")

  descriptions           <- safe_read_csv(desc_path)
  speakers_df            <- safe_read_csv(spkr_path)
  topic_descriptions     <- safe_read_csv(topic_path)
  actor_descriptions_raw <- safe_read_csv(actor_path)

  # ---- 2) Validate schema ----
  check_cols <- function(df, required, name) {
    if (nrow(df) == 0) stop(paste("File missing or unreadable:", name), call. = FALSE)
    missing <- setdiff(required, names(df))
    if (length(missing) > 0)
      stop(paste(name, "is missing required columns:", paste(missing, collapse = ", ")), call. = FALSE)
  }

  check_cols(descriptions, "n", "Descriptions")
  check_cols(speakers_df,  "n", "Speakers per transcript")
  check_cols(topic_descriptions, c("topics", "descriptions"), "Topic Descriptions")
  check_cols(actor_descriptions_raw, "speaker_std", "Actors")

  # ---- 3) Compute speaker frequency ----
  speaker_frequency <- tibble::tibble(speaker_std = character(), conversation_count = integer())
  if (!is.null(transcript_dir) && fs::dir_exists(transcript_dir)) {
    files <- fs::dir_ls(transcript_dir, regexp = "\\.(csv|tsv)$", recurse = TRUE)
    sf <- purrr::map_dfr(files, function(f) {
      ext <- tools::file_ext(f)
      df <- if (ext == "csv") readr::read_csv(f, col_types = readr::cols())
      else if (ext == "tsv") readr::read_tsv(f, col_types = readr::cols())
      else tibble::tibble()
      if (!"speaker_std" %in% names(df)) return(tibble::tibble(speaker_std = character(), n = character()))
      df |>
        dplyr::filter(!is.na(.data$speaker_std), .data$speaker_std != "") |>
        dplyr::distinct(.data$speaker_std) |>
        dplyr::mutate(n = basename(f))
    })
    speaker_frequency <- sf |>
      dplyr::distinct(.data$speaker_std, .data$n) |>
      dplyr::count(.data$speaker_std, name = "conversation_count")
  }

  # ---- 4) Prepare highlight images ----
  highlight_tbl <- if (is.null(highlight_nodes)) {
    tibble::tibble()
  } else if (is.list(highlight_nodes)) {
    tibble::tibble(id = names(highlight_nodes), image = unlist(highlight_nodes))
  } else if (is.data.frame(highlight_nodes)) {
    tibble::as_tibble(highlight_nodes) |> dplyr::rename(id = 1, image = 2)
  } else {
    stop("`highlight_nodes` must be a named list or two-column data frame (id, image).", call. = FALSE)
  }

  # ---- 5) Build UI ----
  ui <- shiny::fluidPage(
    shiny::titlePanel("Transcript–Topic–Speaker Network"),
    shiny::tabsetPanel(
      shiny::tabPanel(
        "Speaker–Topic Network",
        visNetwork::visNetworkOutput("speaker_topic_network", height = "700px"),
        shiny::br(),
        shiny::uiOutput("type_legend")
      ),
      shiny::tabPanel(
        "Speaker Co-Appearance Network",
        visNetwork::visNetworkOutput("speaker_co_network", height = "700px")
      )
    )
  )

  # ---- 6) Server ----
  server <- function(input, output, session) {

    # ---- Dynamic color palette for actor types ----
    actor_types <- actor_descriptions_raw |>
      dplyr::mutate(Type = dplyr::if_else(is.na(.data$Type) | .data$Type == "", "Unknown", .data$Type)) |>
      dplyr::distinct(.data$Type) |>
      dplyr::pull(.data$Type)

    # assign a color palette dynamically
    palette <- RColorBrewer::brewer.pal(min(length(actor_types), 8), "Set3")
    type_colors <- setNames(rep(palette, length.out = length(actor_types)), actor_types)

    # ---- Topics ----
    long_topics <- descriptions |>
      dplyr::select(.data$n, tidyselect::starts_with("topic_")) |>
      tidyr::pivot_longer(tidyselect::starts_with("topic_"),
                          names_to = "topic", values_to = "included") |>
      dplyr::filter(.data$included == "x") |>
      dplyr::mutate(topic = stringr::str_remove(.data$topic, "^topic_"))

    # ---- Speakers ----
    speaker_long <- speakers_df |>
      tidyr::pivot_longer(cols = - .data$n, names_to = "speaker_col", values_to = "speaker") |>
      dplyr::filter(!is.na(.data$speaker), .data$speaker != "") |>
      dplyr::mutate(speaker = stringr::str_trim(.data$speaker))

    # ---- Edges ----
    edges_speaker_topic <- speaker_long |>
      dplyr::inner_join(long_topics, by = "n") |>
      dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker)) |>
      dplyr::distinct(.data$speaker_std, .data$topic) |>
      dplyr::left_join(
        speaker_frequency |> dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker_std)),
        by = "speaker_std"
      ) |>
      dplyr::transmute(from = .data$speaker_std, to = .data$topic,
                       width = pmax(1, log1p(dplyr::coalesce(.data$conversation_count, 0))))

    speaker_pairs <- speaker_long |>
      dplyr::group_by(.data$n) |>
      dplyr::filter(dplyr::n() > 1) |>
      dplyr::summarise(pairs = list(combn(stringr::str_to_lower(.data$speaker), 2, simplify = FALSE)), .groups = "drop") |>
      tidyr::unnest(.data$pairs) |>
      dplyr::mutate(from = purrr::map_chr(.data$pairs, 1), to = purrr::map_chr(.data$pairs, 2)) |>
      dplyr::select(.data$from, .data$to)

    edges_speaker_co <- speaker_pairs |>
      dplyr::mutate(edge_id = paste(pmin(.data$from, .data$to), pmax(.data$from, .data$to), sep = "~~")) |>
      dplyr::distinct(.data$edge_id, .keep_all = TRUE) |>
      dplyr::group_by(.data$from, .data$to) |>
      dplyr::summarise(weight = dplyr::n(), .groups = "drop") |>
      dplyr::mutate(width = pmax(1, log1p(.data$weight)))

    # ---- Nodes ----
    nodes_speaker <- speaker_long |>
      dplyr::transmute(id = stringr::str_to_lower(stringr::str_trim(.data$speaker))) |>
      dplyr::distinct() |>
      dplyr::left_join(
        actor_descriptions_raw |>
          dplyr::mutate(
            speaker_std_lower = stringr::str_to_lower(.data$speaker_std),
            Type = dplyr::if_else(is.na(.data$Type) | .data$Type == "", "Unknown", .data$Type),
            Position = dplyr::coalesce(.data$Position, "No info")
          ),
        by = dplyr::join_by(id == speaker_std_lower)
      ) |>
      dplyr::left_join(
        speaker_frequency |> dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker_std)),
        by = dplyr::join_by(id == speaker_std)
      ) |>
      dplyr::left_join(highlight_tbl, by = "id") |>
      dplyr::mutate(
        color = type_colors[.data$Type],
        color = ifelse(is.na(.data$color), "#B0B0B0", .data$color),
        shape = dplyr::if_else(!is.na(.data$image), "circularImage", "dot"),
        size  = dplyr::if_else(!is.na(.data$image), 60, NA_real_),
        borderWidth = dplyr::if_else(!is.na(.data$image), 0, NA_real_),
        title = paste0("<b>", dplyr::coalesce(.data$name, .data$id), "</b><br>",
                       "Type: ", dplyr::coalesce(.data$Type, "Unknown"), "<br>",
                       "Position: ", dplyr::coalesce(.data$Position, "No info"), "<br>",
                       "Transcripts: ", dplyr::coalesce(as.character(.data$conversation_count), "0"))
      )

    nodes_topic <- long_topics |>
      dplyr::transmute(id = .data$topic) |>
      dplyr::left_join(
        topic_descriptions |> dplyr::rename(topic = .data$topics, description = .data$descriptions),
        by = dplyr::join_by(id == topic)
      ) |>
      dplyr::mutate(
        group = "Topic", color = "maroon",
        title = paste0("<b>", stringr::str_to_title(stringr::str_replace_all(.data$id, "_", " ")), "</b><br>", .data$description)
      )

    nodes <- dplyr::bind_rows(nodes_speaker, nodes_topic)

    # ---- Outputs ----
    output$speaker_topic_network <- visNetwork::renderVisNetwork({
      visNetwork::visNetwork(nodes, edges_speaker_topic) |>
        visNetwork::visNodes(shape = "dot") |>
        visNetwork::visEdges(color = list(color = "grey")) |>
        visNetwork::visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
    })

    output$speaker_co_network <- visNetwork::renderVisNetwork({
      visNetwork::visNetwork(nodes_speaker, edges_speaker_co) |>
        visNetwork::visNodes(shape = "dot") |>
        visNetwork::visEdges(color = list(color = "black")) |>
        visNetwork::visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
    })

    output$type_legend <- shiny::renderUI({
      legend_items <- purrr::map2_chr(names(type_colors), type_colors, function(t, c)
        sprintf("<div style='display:inline-block;margin-right:15px;'>
          <span style='display:inline-block;width:14px;height:14px;background-color:%s;
          border:1px solid #333;border-radius:50%%;margin-right:6px;'></span>%s</div>", c, t))
      shiny::HTML(paste("<b>Legend – Speaker Types:</b><br>", paste(legend_items, collapse = "")))
    })
  }

  shiny::shinyApp(ui, server)
}

