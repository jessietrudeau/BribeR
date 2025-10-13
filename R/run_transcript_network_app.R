#' Run the Transcript-Topic-Speaker Shiny app (data from BribeRdata)
#'
#' By default, loads metadata and (optionally) transcripts from the helper package
#' \pkg{BribeRdata}. You can override the transcript directory with \code{transcript_dir}.
#'
#' @param transcript_dir Optional path to a directory of transcript CSV/TSV files
#'   (with a \code{speaker_std} column). If \code{NULL}, the app will try to use
#'   any packaged transcripts in \pkg{BribeRdata} (if present). If neither is found,
#'   the app still runs using only metadata.
#' @export
run_transcript_network_app <- function(transcript_dir = NULL) {
  # ---- 0) Ensure BribeRdata is available (recommended in Suggests) ----
  has_bdata <- requireNamespace("BribeRdata", quietly = TRUE)

  # helpers to fetch from BribeRdata (object-first, then file)
  get_bobj <- function(name) {
    if (!has_bdata) return(NULL)
    # Try to read an exported R object (data frame) from BribeRdata
    out <- try(get(name, envir = asNamespace("BribeRdata")), silent = TRUE)
    if (inherits(out, "try-error")) NULL else out
  }
  bfile <- function(...) {
    if (!has_bdata) return("")
    system.file(..., package = "BribeRdata")
  }

  # ---- 1) Resolve METADATA (Descriptions, Speakers, Topic Descriptions, Actors) ----
  # Try objects first (if BribeRdata ships .rda), else fall back to CSVs under inst/extdata
  descriptions <- get_bobj("descriptions")
  if (is.null(descriptions)) {
    descriptions <- readr::read_csv(
      bfile("extdata", "Updated Inventory & Descriptions", "Descriptions.csv"),
      col_types = readr::cols()
    )
  }

  speakers_df <- get_bobj("speakers_per_transcript")
  if (is.null(speakers_df)) {
    # If your object is named differently, adjust here.
    speakers_df <- readr::read_csv(
      bfile("extdata", "Updated Inventory & Descriptions", "speakers per transcript.csv"),
      col_types = readr::cols()
    )
  }

  topic_descriptions <- get_bobj("topic_descriptions")
  if (is.null(topic_descriptions)) {
    topic_descriptions <- readr::read_csv(
      bfile("extdata", "Updated Inventory & Descriptions", "Topic Descriptions.csv"),
      col_types = readr::cols()
    )
  }

  actor_descriptions_raw <- get_bobj("actors")
  if (is.null(actor_descriptions_raw)) {
    actor_descriptions_raw <- readr::read_csv(
      bfile("extdata", "Updated Inventory & Descriptions", "Actors.csv"),
      col_types = readr::cols()
    )
  }

  # ---- 2) Optional: packaged transcripts & image inside BribeRdata ----
  # If user doesn’t pass transcript_dir, try a packaged transcripts folder in BribeRdata
  if (is.null(transcript_dir) && has_bdata) {
    # Adjust this folder name to whatever BribeRdata uses:
    packaged_tx_dir <- bfile("extdata", "transcripts")
    if (nzchar(packaged_tx_dir) && fs::dir_exists(packaged_tx_dir)) {
      transcript_dir <- packaged_tx_dir
    }
  }

  # Optional image (e.g., montesinos.png) from BribeRdata
  montesinos_png <- bfile("images", "montesinos.png")
  has_img <- nzchar(montesinos_png) && fs::file_exists(montesinos_png)
  if (has_img) {
    shiny::addResourcePath("briber_images", normalizePath(dirname(montesinos_png)))
    montesinos_image <- file.path("/briber_images", basename(montesinos_png))
  } else {
    montesinos_image <- NULL
  }

  # ---- 3) Build UI (same as before) ----
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        .vis-tooltip, .vis-tooltip * {
          white-space: normal !important;
          word-break: keep-all !important;
          overflow-wrap: break-word !important;
          hyphens: manual !important;
          line-height: 1.35;
        }
      "))
    ),
    shiny::titlePanel("Transcript-Topic-Speaker Network"),
    shiny::tabsetPanel(
      shiny::tabPanel(
        "Speaker-Topic Network",
        shiny::fluidRow(
          shiny::column(width = 12, visNetwork::visNetworkOutput("speaker_topic_network", height = "700px"))
        ),
        shiny::fluidRow(
          shiny::column(width = 12, shiny::br(), shiny::uiOutput("type_legend"))
        )
      ),
      shiny::tabPanel(
        "Speaker Co-Appearance Network",
        visNetwork::visNetworkOutput("speaker_co_network", height = "700px")
      )
    )
  )

  # ---- 4) Server: only the data-loading parts differ from your previous code ----
  server <- function(input, output, session) {
    # Speaker frequency from transcripts (optional)
    speaker_frequency <- {
      if (!is.null(transcript_dir) && fs::dir_exists(transcript_dir)) {
        files <- fs::dir_ls(transcript_dir, regexp = "\\.(csv|tsv)$", recurse = TRUE)
        sf <- purrr::map_dfr(files, function(path) {
          ext <- tools::file_ext(path)
          df <- if (identical(ext, "csv")) readr::read_csv(path, col_types = readr::cols())
          else if (identical(ext, "tsv")) readr::read_tsv(path, col_types = readr::cols())
          else tibble::tibble()
          if (!("speaker_std" %in% names(df))) {
            return(tibble::tibble(speaker_std = character(), n = character()))
          }
          df |>
            dplyr::filter(!is.na(.data$speaker_std), .data$speaker_std != "") |>
            dplyr::distinct(.data$speaker_std) |>
            dplyr::mutate(n = basename(path))
        })
        sf |>
          dplyr::distinct(.data$speaker_std, .data$n) |>
          dplyr::count(.data$speaker_std, name = "conversation_count")
      } else {
        tibble::tibble(speaker_std = character(), conversation_count = integer())
      }
    }

    # ………………………… FROM HERE DOWN, reuse your existing graph build code …………………………
    # (Topic reshape, speakers reshape, edges_speaker_topic, edges_speaker_co,
    #  node construction, visNetwork outputs, legend, etc.)
    #
    # Keep the “MONTESINOS image” swap using `montesinos_image` and `has_img` that we set above.

    # === Your existing pipeline (unchanged) ===
    type_colors <- c(
      "Congress"         = "#BDB2FF", "Security"   = "#A0C4FF", "Bureaucrat" = "#CAFFBF",
      "Judiciary"        = "#FDFFB6", "Foreign"    = "#FFD6A5", "Media"      = "#FFADAD",
      "Illicit"          = "#FFC6FF", "Elected Official" = "#9BF6FF",
      "Businessperson"   = "#4daf4a", "Unknown"    = "grey"
    )

    long_topics <- descriptions |>
      dplyr::select(.data$n, tidyselect::starts_with("topic_")) |>
      tidyr::pivot_longer(tidyselect::starts_with("topic_"), names_to = "topic", values_to = "included") |>
      dplyr::filter(.data$included == "x") |>
      dplyr::mutate(n = as.character(.data$n), topic = stringr::str_remove(.data$topic, "^topic_"))

    speaker_long <- speakers_df |>
      tidyr::pivot_longer(cols = - .data$n, names_to = "speaker_col", values_to = "speaker") |>
      dplyr::filter(!is.na(.data$speaker), .data$speaker != "") |>
      dplyr::mutate(n = as.character(.data$n), speaker = stringr::str_trim(.data$speaker))

    edges_speaker_topic <- speaker_long |>
      dplyr::inner_join(long_topics, by = "n") |>
      dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker)) |>
      dplyr::distinct(.data$speaker_std, .data$topic) |>
      dplyr::left_join(speaker_frequency |>
                         dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker_std)),
                       by = "speaker_std") |>
      dplyr::transmute(from = .data$speaker_std, to = .data$topic,
                       width = pmax(1, log1p(dplyr::coalesce(.data$conversation_count, 0))))

    speaker_pairs_topic_net <- speaker_long |>
      dplyr::select(.data$n, .data$speaker) |>
      dplyr::distinct() |>
      dplyr::group_by(.data$n) |>
      dplyr::filter(dplyr::n() > 1) |>
      dplyr::summarise(pairs = list(combn(stringr::str_to_lower(.data$speaker), 2, simplify = FALSE)), .groups = "drop") |>
      tidyr::unnest(.data$pairs) |>
      dplyr::mutate(from = purrr::map_chr(.data$pairs, 1), to = purrr::map_chr(.data$pairs, 2)) |>
      dplyr::select(.data$from, .data$to) |>
      dplyr::filter(.data$from != .data$to)

    edges_placeholder <- speaker_pairs_topic_net |>
      dplyr::mutate(edge_id = paste(pmin(.data$from, .data$to), pmax(.data$from, .data$to), sep = "~~")) |>
      dplyr::distinct(.data$edge_id, .keep_all = TRUE) |>
      dplyr::select(-.data$edge_id) |>
      dplyr::group_by(.data$from, .data$to) |>
      dplyr::summarise(weight = dplyr::n(), .groups = "drop") |>
      dplyr::mutate(color = "#bbbbbb", width = pmax(1, log1p(.data$weight) / 2))

    speaker_pairs <- speaker_long |>
      dplyr::select(.data$n, .data$speaker) |>
      dplyr::distinct() |>
      dplyr::group_by(.data$n) |>
      dplyr::filter(dplyr::n() > 1) |>
      dplyr::summarise(pairs = list(combn(.data$speaker, 2, simplify = FALSE)), .groups = "drop") |>
      tidyr::unnest(.data$pairs) |>
      dplyr::mutate(from = purrr::map_chr(.data$pairs, 1), to = purrr::map_chr(.data$pairs, 2)) |>
      dplyr::select(.data$from, .data$to) |>
      dplyr::filter(.data$from != .data$to)

    edges_speaker_co <- speaker_pairs |>
      dplyr::mutate(from = stringr::str_to_lower(.data$from), to = stringr::str_to_lower(.data$to)) |>
      dplyr::mutate(edge_id = paste(pmin(.data$from, .data$to), pmax(.data$from, .data$to), sep = "~~")) |>
      dplyr::distinct(.data$edge_id, .keep_all = TRUE) |>
      dplyr::select(-.data$edge_id) |>
      dplyr::group_by(.data$from, .data$to) |>
      dplyr::summarise(weight = dplyr::n(), .groups = "drop") |>
      dplyr::mutate(width = pmax(1, log1p(.data$weight)))

    # Build nodes (with optional image for "montesinos")
    nodes_speaker_base <- speaker_long |>
      dplyr::transmute(id = stringr::str_to_lower(stringr::str_trim(.data$speaker))) |>
      dplyr::distinct()

    actor_descriptions <- actor_descriptions_raw |>
      dplyr::mutate(
        Type = stringr::str_trim(.data$Type),
        Type = stringr::str_to_title(.data$Type),
        Type = dplyr::case_when(
          .data$Type %in% c("Illict", "Illicit") ~ "Illicit",
          .data$Type == "Bereaucrat"             ~ "Bureaucrat",
          .data$Type == "Elected official"       ~ "Elected Official",
          .data$Type == "Business"               ~ "Businessperson",
          is.na(.data$Type) | .data$Type == ""   ~ "Unknown",
          TRUE                                   ~ .data$Type
        ),
        name = dplyr::coalesce(.data$name, .data$Name, .data$`...1`, .data$speaker_std)
      )

    nodes_speaker_st <- nodes_speaker_base |>
      dplyr::left_join(
        actor_descriptions |>
          dplyr::mutate(
            speaker_std = stringr::str_trim(.data$speaker_std),
            speaker_std_lower = stringr::str_to_lower(.data$speaker_std),
            Position = dplyr::coalesce(.data$Position, "No info"),
            Type = dplyr::if_else(is.na(.data$Type) | .data$Type == "", "Unknown", .data$Type)
          ),
        by = dplyr::join_by(id == speaker_std_lower)
      ) |>
      dplyr::left_join(
        speaker_frequency |>
          dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker_std)),
        by = dplyr::join_by(id == speaker_std)
      ) |>
      dplyr::mutate(
        group = "Speaker",
        color = type_colors[.data$Type],
        color = ifelse(is.na(.data$color), type_colors[["Unknown"]], .data$color),
        label = "",
        title = paste0(
          "<b>", dplyr::coalesce(.data$name, .data$id), "</b><br>",
          "Standardized ID: ", .data$id, "<br>",
          "Type: ", dplyr::coalesce(.data$Type, "Unknown"), "<br>",
          "Position: ", dplyr::coalesce(.data$Position, "No info"), "<br>",
          "Transcripts: ", dplyr::coalesce(as.character(.data$conversation_count), "0")
        )
      ) |>
      dplyr::select(.data$id, .data$group, .data$title, .data$color, .data$label) |>
      dplyr::distinct(.data$id, .keep_all = TRUE) |>
      dplyr::mutate(
        shape = dplyr::if_else(.data$id == "montesinos" & !is.null(montesinos_image), "circularImage", "dot"),
        image = dplyr::if_else(.data$id == "montesinos" & !is.null(montesinos_image), montesinos_image, NA_character_),
        size  = dplyr::if_else(.data$id == "montesinos" & !is.null(montesinos_image), 60, NA_real_),
        borderWidth = dplyr::if_else(.data$id == "montesinos" & !is.null(montesinos_image), 0, NA_real_)
      )

    nodes_topic_st <- long_topics |>
      dplyr::transmute(id = .data$topic) |>
      dplyr::distinct() |>
      dplyr::left_join(
        topic_descriptions |>
          dplyr::rename(topic = .data$topics, description = .data$descriptions) |>
          dplyr::mutate(topic = stringr::str_remove(.data$topic, "^topic_")),
        by = dplyr::join_by(id == topic)
      ) |>
      dplyr::mutate(
        group = "Topic", label = "",
        title = paste0("<b>", stringr::str_to_title(stringr::str_replace_all(.data$id, "_", " ")), "</b><br>", .data$description),
        value = 300, color = "maroon"
      ) |>
      dplyr::select(.data$id, .data$group, .data$title, .data$value, .data$color, .data$label) |>
      dplyr::distinct(.data$id, .keep_all = TRUE)

    nodes_st <- dplyr::bind_rows(
      nodes_speaker_st |>
        dplyr::select(.data$id, .data$group, .data$title, .data$color, .data$label, .data$value, .data$shape, .data$image, .data$size, .data$borderWidth),
      nodes_topic_st |>
        dplyr::mutate(shape = "dot") |>
        dplyr::select(.data$id, .data$group, .data$title, .data$color, .data$label, .data$value, .data$shape)
    ) |>
      dplyr::distinct(.data$id, .keep_all = TRUE)

    output$speaker_topic_network <- visNetwork::renderVisNetwork({
      visNetwork::visNetwork(
        nodes_st,
        dplyr::bind_rows(
          edges_speaker_topic |>
            dplyr::mutate(color = NA_character_),
          edges_placeholder
        )
      ) |>
        visNetwork::visNodes(shape = "dot", shapeProperties = list(useImageSize = FALSE, useBorderWithImage = TRUE)) |>
        visNetwork::visEdges(arrows = "none", color = list(color = "grey")) |>
        visNetwork::visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) |>
        visNetwork::visPhysics(solver = "forceAtlas2Based", stabilization = TRUE) |>
        visNetwork::visLayout(randomSeed = 42) |>
        visNetwork::visEvents(stabilizationIterationsDone = "function () { this.setOptions({ physics: false }); }")
    })

    output$speaker_co_network <- visNetwork::renderVisNetwork({
      visNetwork::visNetwork(
        nodes_speaker_st |>
          dplyr::select(.data$id, .data$group, .data$title, .data$color, .data$label, .data$value, .data$shape, .data$image, .data$size, .data$borderWidth),
        edges_speaker_co
      ) |>
        visNetwork::visNodes(shape = "dot", shapeProperties = list(useImageSize = FALSE, useBorderWithImage = TRUE)) |>
        visNetwork::visEdges(arrows = "none", color = list(color = "black")) |>
        visNetwork::visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) |>
        visNetwork::visPhysics(solver = "forceAtlas2Based", stabilization = TRUE) |>
        visNetwork::visLayout(randomSeed = 42) |>
        visNetwork::visEvents(stabilizationIterationsDone = "function () { this.setOptions({ physics: false }); }")
    })

    output$type_legend <- shiny::renderUI({
      legend_items <- purrr::map2_chr(names(type_colors), type_colors, function(type, color) {
        paste0(
          "<div style='display: inline-block; margin-right: 15px; margin-bottom: 4px; vertical-align: middle;'>
             <span style='display: inline-block; width: 14px; height: 14px; background-color:", color, "; border: 1px solid #333; border-radius: 50%; margin-right: 6px;'></span>",
          "<span style='font-size: 14px;'>", type, "</span></div>"
        )
      })
      shiny::HTML(paste("<b>Legend – Speaker Types:</b><br><div style='margin-top: 5px;'>", paste(legend_items, collapse = ""), "</div>"))
    })
  }

  shiny::shinyApp(ui = ui, server = server)
}
