#' Run the Transcript-Topic-Speaker Shiny app (fixed project paths)
#'
#' Launch an interactive Shiny application that visualizes the relationships
#' between speakers and topics in a transcript collection, using fixed
#' project-relative paths for metadata and transcripts.
#'
#' This version assumes your working directory is set to the project root and
#' uses the following fixed subdirectories:
#' \itemize{
#'   \item \code{data-raw/Inventory & Descriptions} for:
#'     \itemize{
#'       \item \code{Descriptions.csv}
#'       \item \code{speakers per transcript.csv}
#'       \item \code{Topic Descriptions.csv}
#'       \item \code{Actors.csv}
#'     }
#'   \item \code{data-raw/transcripts} for transcript CSV/TSV files
#'   \item \code{inst/images/montesinos.PNG} (optional image for the "montesinos" node)
#' }
#'
#' @param transcript_dir Optional path to a directory of transcript CSV/TSV files
#'   (with a \code{speaker_std} column). If \code{NULL}, the app will use
#'   \code{data-raw/transcripts} under the current working directory.
#'
#' @return A \code{shiny.appobj} that, when printed, launches the
#'   Transcript-Topic-Speaker Shiny application.
#'
#' @details
#' This function expects the metadata CSVs to have the following structure:
#' \itemize{
#'   \item \code{Descriptions.csv} contains a column \code{n} (transcript ID)
#'     and multiple \code{topic_...} columns with \code{"x"} indicating topic
#'     inclusion.
#'   \item \code{speakers per transcript.csv} contains a column \code{n} and
#'     wide-format speaker columns with speaker names.
#'   \item \code{Topic Descriptions.csv} contains a column \code{topics} and
#'     a column \code{descriptions} describing each topic.
#'   \item \code{Actors.csv} contains information on actors, including
#'     \code{speaker}, \code{speaker_std}, \code{Type}, and \code{Position}.
#' }
#' Transcript files in \code{data-raw/transcripts} (or in \code{transcript_dir})
#' must contain a \code{speaker_std} column used to compute speaker frequency
#' across conversations.
#'
#' @examples
#' \dontrun{
#' # Run using the default data-raw/ structure:
#' run_transcript_network_app()
#'
#' # Run using a custom transcript directory:
#' run_transcript_network_app("other/transcripts/path")
#' }
#'
#' @export
run_transcript_network_app <- function(transcript_dir = NULL) {

  # ---- 0) Fixed paths relative to current working directory -----------------
  meta_dir <- fs::path("data-raw", "Inventory & Descriptions")
  transcripts_default_dir <- fs::path("data-raw", "transcripts")
  montesinos_image_path <- fs::path("inst", "images", "montesinos.PNG")

  descriptions_path       <- fs::path(meta_dir, "Descriptions.csv")
  speakers_path           <- fs::path(meta_dir, "speakers per transcript.csv")
  topic_descriptions_path <- fs::path(meta_dir, "Topic Descriptions.csv")
  actors_path             <- fs::path(meta_dir, "Actors.csv")

  if (is.null(transcript_dir)) {
    transcript_dir <- transcripts_default_dir
  }

  # ---- 1) Load metadata from fixed paths ------------------------------------
  if (!fs::file_exists(descriptions_path)) {
    stop("Descriptions.csv not found at: ", descriptions_path)
  }
  descriptions <- readr::read_csv(descriptions_path, col_types = readr::cols())

  if (!fs::file_exists(speakers_path)) {
    stop("'speakers per transcript.csv' not found at: ", speakers_path)
  }
  speakers_df <- readr::read_csv(speakers_path, col_types = readr::cols())

  if (!fs::file_exists(topic_descriptions_path)) {
    stop("Topic Descriptions.csv not found at: ", topic_descriptions_path)
  }
  topic_descriptions <- readr::read_csv(topic_descriptions_path, col_types = readr::cols())

  if (!fs::file_exists(actors_path)) {
    stop("Actors.csv not found at: ", actors_path)
  }
  actor_descriptions_raw <- readr::read_csv(actors_path, col_types = readr::cols())

  # ---- 2) Optional image from fixed path ------------------------------------
  has_img <- fs::file_exists(montesinos_image_path)
  if (has_img) {
    shiny::addResourcePath(
      "briber_images",
      normalizePath(dirname(montesinos_image_path))
    )
    montesinos_image <- file.path("/briber_images", basename(montesinos_image_path))
  } else {
    montesinos_image <- NULL
  }

  # ---- 3) Build UI ----------------------------------------------------------
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
          shiny::column(
            width = 12,
            visNetwork::visNetworkOutput("speaker_topic_network", height = "700px")
          )
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

  # ---- 4) Server ------------------------------------------------------------
  server <- function(input, output, session) {

    # Speaker frequency from transcripts (optional)
    speaker_frequency <- {
      if (!is.null(transcript_dir) && fs::dir_exists(transcript_dir)) {
        files <- fs::dir_ls(transcript_dir, regexp = "\\.(csv|tsv)$", recurse = TRUE)
        sf <- purrr::map_dfr(files, function(path) {
          ext <- tools::file_ext(path)
          df <- if (identical(ext, "csv")) {
            readr::read_csv(path, col_types = readr::cols())
          } else if (identical(ext, "tsv")) {
            readr::read_tsv(path, col_types = readr::cols())
          } else {
            tibble::tibble()
          }
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

    # === Type colors ===
    type_colors <- c(
      "Congress"         = "#BDB2FF", "Security"   = "#A0C4FF", "Bureaucrat" = "#CAFFBF",
      "Judiciary"        = "#FDFFB6", "Foreign"    = "#FFD6A5", "Media"      = "#FFADAD",
      "Illicit"          = "#FFC6FF", "Elected Official" = "#9BF6FF",
      "Businessperson"   = "#4daf4a", "Unknown"    = "grey"
    )

    # === Topic reshape ===
    long_topics <- descriptions |>
      dplyr::select(.data$n, tidyselect::starts_with("topic_")) |>
      tidyr::pivot_longer(
        tidyselect::starts_with("topic_"),
        names_to = "topic",
        values_to = "included"
      ) |>
      dplyr::filter(.data$included == "x") |>
      dplyr::mutate(
        n     = as.character(.data$n),
        topic = stringr::str_remove(.data$topic, "^topic_")
      )

    # === Speakers reshape ===
    speaker_long <- speakers_df |>
      tidyr::pivot_longer(
        cols = - .data$n,
        names_to = "speaker_col",
        values_to = "speaker"
      ) |>
      dplyr::filter(!is.na(.data$speaker), .data$speaker != "") |>
      dplyr::mutate(
        n       = as.character(.data$n),
        speaker = stringr::str_trim(.data$speaker)
      )

    # === Edges: Speaker -> Topic ===
    edges_speaker_topic <- speaker_long |>
      dplyr::inner_join(long_topics, by = "n") |>
      dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker)) |>
      dplyr::distinct(.data$speaker_std, .data$topic) |>
      dplyr::left_join(
        speaker_frequency |>
          dplyr::mutate(speaker_std = stringr::str_to_lower(.data$speaker_std)),
        by = "speaker_std"
      ) |>
      dplyr::transmute(
        from  = .data$speaker_std,
        to    = .data$topic,
        width = pmax(1, log1p(dplyr::coalesce(.data$conversation_count, 0)))
      )

    # === Speaker pairs for placeholder edges (for layout support) ===
    speaker_pairs_topic_net <- speaker_long |>
      dplyr::select(.data$n, .data$speaker) |>
      dplyr::distinct() |>
      dplyr::group_by(.data$n) |>
      dplyr::filter(dplyr::n() > 1) |>
      dplyr::summarise(
        pairs = list(combn(stringr::str_to_lower(.data$speaker), 2, simplify = FALSE)),
        .groups = "drop"
      ) |>
      tidyr::unnest(.data$pairs) |>
      dplyr::mutate(
        from = purrr::map_chr(.data$pairs, 1),
        to   = purrr::map_chr(.data$pairs, 2)
      ) |>
      dplyr::select(.data$from, .data$to) |>
      dplyr::filter(.data$from != .data$to)

    edges_placeholder <- speaker_pairs_topic_net |>
      dplyr::mutate(
        edge_id = paste(
          pmin(.data$from, .data$to),
          pmax(.data$from, .data$to),
          sep = "~~"
        )
      ) |>
      dplyr::distinct(.data$edge_id, .keep_all = TRUE) |>
      dplyr::select(-.data$edge_id) |>
      dplyr::group_by(.data$from, .data$to) |>
      dplyr::summarise(weight = dplyr::n(), .groups = "drop") |>
      dplyr::mutate(
        color = "#bbbbbb",
        width = pmax(1, log1p(.data$weight) / 2)
      )

    # === Speaker pairs for co-appearance network ===
    speaker_pairs <- speaker_long |>
      dplyr::select(.data$n, .data$speaker) |>
      dplyr::distinct() |>
      dplyr::group_by(.data$n) |>
      dplyr::filter(dplyr::n() > 1) |>
      dplyr::summarise(
        pairs = list(combn(.data$speaker, 2, simplify = FALSE)),
        .groups = "drop"
      ) |>
      tidyr::unnest(.data$pairs) |>
      dplyr::mutate(
        from = purrr::map_chr(.data$pairs, 1),
        to   = purrr::map_chr(.data$pairs, 2)
      ) |>
      dplyr::select(.data$from, .data$to) |>
      dplyr::filter(.data$from != .data$to)

    edges_speaker_co <- speaker_pairs |>
      dplyr::mutate(
        from = stringr::str_to_lower(.data$from),
        to   = stringr::str_to_lower(.data$to)
      ) |>
      dplyr::mutate(
        edge_id = paste(
          pmin(.data$from, .data$to),
          pmax(.data$from, .data$to),
          sep = "~~"
        )
      ) |>
      dplyr::distinct(.data$edge_id, .keep_all = TRUE) |>
      dplyr::select(-.data$edge_id) |>
      dplyr::group_by(.data$from, .data$to) |>
      dplyr::summarise(weight = dplyr::n(), .groups = "drop") |>
      dplyr::mutate(width = pmax(1, log1p(.data$weight)))

    # === Speaker nodes (actors + frequency) ===
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
        # use `speaker` as display name, fall back to speaker_std if needed
        name = dplyr::coalesce(.data$speaker, .data$speaker_std)
      )

    nodes_speaker_st <- nodes_speaker_base |>
      dplyr::left_join(
        actor_descriptions |>
          dplyr::mutate(
            speaker_std       = stringr::str_trim(.data$speaker_std),
            speaker_std_lower = stringr::str_to_lower(.data$speaker_std),
            Position          = dplyr::coalesce(.data$Position, "No info"),
            Type              = dplyr::if_else(
              is.na(.data$Type) | .data$Type == "",
              "Unknown",
              .data$Type
            )
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
        value = pmax(1, log1p(dplyr::coalesce(.data$conversation_count, 0))),
        title = paste0(
          "<b>", dplyr::coalesce(.data$name, .data$id), "</b><br>",
          "Standardized ID: ", .data$id, "<br>",
          "Type: ", dplyr::coalesce(.data$Type, "Unknown"), "<br>",
          "Position: ", dplyr::coalesce(.data$Position, "No info"), "<br>",
          "Transcripts: ", dplyr::coalesce(as.character(.data$conversation_count), "0")
        )
      ) |>
      dplyr::select(
        .data$id, .data$group, .data$title, .data$color,
        .data$label, .data$value
      ) |>
      dplyr::distinct(.data$id, .keep_all = TRUE)

    # Add Montesinos image properties *outside* the pipe, to avoid `{}` on RHS
    if (!has_img) {
      nodes_speaker_st <- nodes_speaker_st |>
        dplyr::mutate(
          shape       = "dot",
          image       = NA_character_,
          size        = NA_real_,
          borderWidth = NA_real_
        )
    } else {
      nodes_speaker_st <- nodes_speaker_st |>
        dplyr::mutate(
          shape       = dplyr::if_else(.data$id == "montesinos", "circularImage", "dot"),
          image       = dplyr::if_else(.data$id == "montesinos", montesinos_image, NA_character_),
          size        = dplyr::if_else(.data$id == "montesinos", 60, NA_real_),
          borderWidth = dplyr::if_else(.data$id == "montesinos", 0, NA_real_)
        )
    }

    # === Topic nodes ===
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
        group = "Topic",
        label = "",
        title = paste0(
          "<b>",
          stringr::str_to_title(stringr::str_replace_all(.data$id, "_", " ")),
          "</b><br>",
          .data$description
        ),
        value = 300,
        color = "maroon"
      ) |>
      dplyr::select(.data$id, .data$group, .data$title, .data$value,
                    .data$color, .data$label) |>
      dplyr::distinct(.data$id, .keep_all = TRUE)

    # === Combined nodes for Speaker-Topic view ===
    nodes_st <- dplyr::bind_rows(
      nodes_speaker_st |>
        dplyr::select(
          .data$id, .data$group, .data$title, .data$color,
          .data$label, .data$value, .data$shape, .data$image,
          .data$size, .data$borderWidth
        ),
      nodes_topic_st |>
        dplyr::mutate(shape = "dot") |>
        dplyr::select(
          .data$id, .data$group, .data$title, .data$color,
          .data$label, .data$value, .data$shape
        )
    ) |>
      dplyr::distinct(.data$id, .keep_all = TRUE)

    # === Speaker-Topic Network ===
    output$speaker_topic_network <- visNetwork::renderVisNetwork({
      visNetwork::visNetwork(
        nodes_st,
        dplyr::bind_rows(
          edges_speaker_topic |>
            dplyr::mutate(color = NA_character_),
          edges_placeholder
        )
      ) |>
        visNetwork::visNodes(
          shape = "dot",
          shapeProperties = list(
            useImageSize = FALSE,
            useBorderWithImage = TRUE
          )
        ) |>
        visNetwork::visEdges(
          arrows = "none",
          color = list(color = "grey")
        ) |>
        visNetwork::visOptions(
          highlightNearest = TRUE,
          nodesIdSelection = TRUE
        ) |>
        visNetwork::visPhysics(
          solver = "forceAtlas2Based",
          stabilization = TRUE
        ) |>
        visNetwork::visLayout(randomSeed = 42) |>
        visNetwork::visEvents(
          stabilizationIterationsDone =
            "function () { this.setOptions({ physics: false }); }"
        )
    })

    # === Speaker Co-Appearance Network ===
    output$speaker_co_network <- visNetwork::renderVisNetwork({
      visNetwork::visNetwork(
        nodes_speaker_st |>
          dplyr::select(
            .data$id, .data$group, .data$title, .data$color,
            .data$label, .data$value, .data$shape, .data$image,
            .data$size, .data$borderWidth
          ),
        edges_speaker_co
      ) |>
        visNetwork::visNodes(
          shape = "dot",
          shapeProperties = list(
            useImageSize = FALSE,
            useBorderWithImage = TRUE
          )
        ) |>
        visNetwork::visEdges(
          arrows = "none",
          color = list(color = "black")
        ) |>
        visNetwork::visOptions(
          highlightNearest = TRUE,
          nodesIdSelection = TRUE
        ) |>
        visNetwork::visPhysics(
          solver = "forceAtlas2Based",
          stabilization = TRUE
        ) |>
        visNetwork::visLayout(randomSeed = 42) |>
        visNetwork::visEvents(
          stabilizationIterationsDone =
            "function () { this.setOptions({ physics: false }); }"
        )
    })

    # === Legend ===
    output$type_legend <- shiny::renderUI({
      legend_items <- purrr::map2_chr(
        names(type_colors),
        type_colors,
        function(type, color) {
          paste0(
            "<div style='display: inline-block; margin-right: 15px;
                        margin-bottom: 4px; vertical-align: middle;'>
               <span style='display: inline-block; width: 14px; height: 14px;
                            background-color:", color, ";
                            border: 1px solid #333;
                            border-radius: 50%;
                            margin-right: 6px;'></span>",
            "<span style='font-size: 14px;'>", type, "</span></div>"
          )
        }
      )
      shiny::HTML(
        paste(
          "<b>Legend – Speaker Types:</b><br><div style='margin-top: 5px;'>",
          paste(legend_items, collapse = ""),
          "</div>"
        )
      )
    })
  }

  shiny::shinyApp(ui = ui, server = server)
}
