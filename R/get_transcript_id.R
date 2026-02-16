#' Retrieve Available Transcript IDs
#'
#' Lists all available transcript IDs based on the `.csv` files stored in
#' the `data-raw/transcripts` folder of the **BribeR** package. Optionally
#' filters to only those transcripts that include any of the specified
#' speakers or topics, using the bundled `transcript_index` dataset.
#'
#' When multiple speakers and/or topics are provided, all filters are
#' combined with OR logic: a transcript is included if **any** of the
#' specified speakers appear in it **or** **any** of the specified topics
#' are flagged.
#'
#' Each transcript is named numerically (e.g., `1.csv`, `19.csv`, `104.csv`),
#' and its ID corresponds directly to that number.
#'
#' @param speaker Optional character vector of one or more standardized speaker
#'   names (e.g., `"montesinos"`, `c("kouri", "crousillat")`). If provided,
#'   transcripts where any of these speakers are present will be included.
#' @param topic Optional character vector of one or more topic names (e.g.,
#'   `"media"`, `c("reelection", "state_capture")`). The `topic_` prefix is
#'   added automatically if not included. Transcripts where any of these topics
#'   are flagged will be included.
#'
#' @return A sorted numeric vector of matching transcript IDs.
#'
#' @examples
#' # Retrieve all available transcript IDs
#' ids <- get_transcript_id()
#'
#' # Retrieve transcript IDs where Montesinos appears
#' get_transcript_id(speaker = "montesinos")
#'
#' # Retrieve transcript IDs where either Kouri or Crousillat appears
#' get_transcript_id(speaker = c("kouri", "crousillat"))
#'
#' # Retrieve transcript IDs about media or reelection
#' get_transcript_id(topic = c("media", "reelection"))
#'
#' # Combine: transcripts with Kouri OR about media
#' get_transcript_id(speaker = "kouri", topic = "media")
#'
#' @seealso [read_transcripts()], [get_transcripts_raw()], [get_transcript_speakers()]
#' @export
get_transcript_id <- function(speaker = NULL, topic = NULL) {
  transcripts_dir <- system.file("data-raw", "transcripts", package = "BribeR")

  # Fallback: local path during development
  if (transcripts_dir == "" && dir.exists(file.path("data-raw", "transcripts"))) {
    transcripts_dir <- file.path("data-raw", "transcripts")
  }

  if (transcripts_dir == "" || !dir.exists(transcripts_dir)) {
    stop("Transcript directory not found. Is the BribeR package installed correctly?", call. = FALSE)
  }

  files <- list.files(transcripts_dir, pattern = "\\.csv$", full.names = FALSE)
  all_ids <- as.numeric(tools::file_path_sans_ext(files))
  all_ids <- sort(all_ids, na.last = NA)

  # If no filters, return all IDs
  if (is.null(speaker) && is.null(topic)) {
    return(all_ids)
  }

  # Load transcript_index for filtering
  rda_path <- system.file("data", "transcript_index.rda", package = "BribeR")
  if (rda_path == "") {
    stop("Could not find transcript_index.rda in the BribeR package.", call. = FALSE)
  }
  env <- new.env()
  load(rda_path, envir = env)
  index <- env$transcript_index

  # Restrict to IDs that exist as files
  index <- index[index$n %in% all_ids, ]

  # Collect matching row indices (OR across all filters)
  matched <- logical(nrow(index))

  # Match speakers
  if (!is.null(speaker)) {
    speaker_cols <- paste0("speaker_", tolower(speaker))
    available_speakers <- grep("^speaker_", names(index), value = TRUE)

    missing <- speaker_cols[!speaker_cols %in% names(index)]
    if (length(missing) > 0) {
      available_names <- sub("^speaker_", "", available_speakers)
      stop(
        "Speaker(s) not found in transcript_index: ",
        paste(sub("^speaker_", "", missing), collapse = ", "), ". ",
        "Available speakers include: ",
        paste(head(available_names, 10), collapse = ", "),
        if (length(available_names) > 10) ", ..." else "",
        call. = FALSE
      )
    }

    for (sc in speaker_cols) {
      matched <- matched | (!is.na(index[[sc]]) & index[[sc]] != 0)
    }
  }

  # Match topics
  if (!is.null(topic)) {
    topic_cols <- ifelse(grepl("^topic_", topic), topic, paste0("topic_", tolower(topic)))
    available_topics <- grep("^topic_", names(index), value = TRUE)

    missing <- topic_cols[!topic_cols %in% names(index)]
    if (length(missing) > 0) {
      available_names <- sub("^topic_", "", available_topics)
      stop(
        "Topic(s) not found in transcript_index: ",
        paste(sub("^topic_", "", missing), collapse = ", "), ". ",
        "Available topics: ",
        paste(available_names, collapse = ", "),
        call. = FALSE
      )
    }

    for (tc in topic_cols) {
      matched <- matched | (!is.na(index[[tc]]) & index[[tc]] != 0)
    }
  }

  filtered_ids <- sort(as.numeric(index$n[matched]), na.last = NA)
  filtered_ids
}
