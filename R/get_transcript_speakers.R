#' Get transcripts each speaker appears in
#'
#' Loads the bundled `speakers_per_transcript` dataset and returns one row per
#' unique speaker with a list-column of transcript IDs (`n`) where that speaker
#' appears. Optionally filters to only transcripts matching specific IDs and/or
#' topics.
#'
#' When both `n` and `topic` are provided, they are combined with AND logic:
#' only transcripts that match the specified IDs **and** have the specified
#' topics are included. When only one filter is provided, it is applied alone.
#' When neither is provided, all speakers across all transcripts are returned.
#'
#' @param n Optional numeric vector of transcript IDs to restrict results to
#'   (e.g., `1`, `c(1, 5, 10)`).
#' @param topic Optional character vector of one or more topic names (e.g.,
#'   `"media"`, `c("reelection", "state_capture")`). The `topic_` prefix is
#'   added automatically if not included. Transcripts where any of these topics
#'   are flagged will be included.
#'
#' @return A tibble with columns:
#'   - `speaker_std` (character): standardized speaker identifier
#'   - `transcripts` (list): sorted numeric vector of transcript IDs where the speaker appears
#'
#' @examples
#' # Get all speakers and their transcript appearances
#' speakers <- get_transcript_speakers()
#' head(speakers)
#'
#' # Get speakers from specific transcripts
#' get_transcript_speakers(n = c(1, 5))
#'
#' # Get speakers from transcripts about media
#' get_transcript_speakers(topic = "media")
#'
#' # Get speakers from transcript 1 that is also about media
#' get_transcript_speakers(n = 1, topic = "media")
#'
#' @seealso [read_transcripts()], [get_transcript_id()], [get_transcripts_raw()]
#' @export
get_transcript_speakers <- function(n = NULL, topic = NULL) {

  # --- helper: load bundled .rda
  .load_pkg_data <- function(filename, object_name) {
    rda_path <- system.file("data", paste0(filename, ".rda"), package = "BribeR")
    if (rda_path == "") {
      stop("Could not find ", filename, ".rda in the BribeR package.", call. = FALSE)
    }
    env <- new.env()
    load(rda_path, envir = env)
    env[[object_name]]
  }

  df <- .load_pkg_data("speakers_per_transcript", "speakers_per_transcript")

  if (!"n" %in% names(df)) {
    stop("Expected column 'n' in speakers_per_transcript dataset.", call. = FALSE)
  }

  # accept both correct and misspelled prefixes
  speaker_cols <- grep("^(speakrer_std_|speaker_std_)[0-9]+$", names(df), value = TRUE)
  if (!length(speaker_cols)) {
    stop(
      "No speaker columns found. Expected columns like 'speaker_std_1'.",
      call. = FALSE
    )
  }

  # --- determine which transcript IDs to keep --------------------------------
  all_ids <- sort(unique(as.numeric(df$n)), na.last = NA)
  keep_ids <- all_ids

  # Filter by n
  if (!is.null(n)) {
    n <- as.numeric(n)
    missing_n <- n[!n %in% all_ids]
    if (length(missing_n) > 0) {
      warning(
        "Transcript ID(s) not found: ",
        paste(missing_n, collapse = ", "),
        call. = FALSE
      )
    }
    keep_ids <- intersect(keep_ids, n)
  }

  # Filter by topic using transcript_index
  if (!is.null(topic)) {
    index <- .load_pkg_data("transcript_index", "transcript_index")

    topic_cols <- ifelse(grepl("^topic_", topic), topic, paste0("topic_", tolower(topic)))
    available_topics <- grep("^topic_", names(index), value = TRUE)

    missing_topics <- topic_cols[!topic_cols %in% names(index)]
    if (length(missing_topics) > 0) {
      available_names <- sub("^topic_", "", available_topics)
      stop(
        "Topic(s) not found in transcript_index: ",
        paste(sub("^topic_", "", missing_topics), collapse = ", "), ". ",
        "Available topics: ",
        paste(available_names, collapse = ", "),
        call. = FALSE
      )
    }

    matched <- logical(nrow(index))
    for (tc in topic_cols) {
      matched <- matched | (!is.na(index[[tc]]) & index[[tc]] != 0)
    }
    topic_ids <- as.numeric(index$n[matched])
    keep_ids <- intersect(keep_ids, topic_ids)
  }

  # --- pivot and summarise ---------------------------------------------------
  long <- df |>
    dplyr::mutate(n = as.numeric(.data$n)) |>
    dplyr::filter(.data$n %in% keep_ids) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(speaker_cols),
      names_to = "slot",
      values_to = "speaker_std"
    ) |>
    dplyr::mutate(speaker_std = trimws(as.character(.data$speaker_std))) |>
    dplyr::filter(!is.na(.data$speaker_std) & .data$speaker_std != "") |>
    dplyr::distinct(.data$speaker_std, .data$n)

  # Group by speaker, collect transcript IDs
  long |>
    dplyr::group_by(.data$speaker_std) |>
    dplyr::summarise(
      transcripts = list(sort(unique(.data$n))),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$speaker_std) |>
    tibble::as_tibble()
}



