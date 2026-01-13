#' Get speakers present in each transcript
#'
#' Reads the canonical "speakers per transcript.csv" file and returns one row per
#' transcript `n` with a list-column of unique speakers present in that transcript.
#'
#' @param path Optional. Path to the speakers-per-transcript file.
#'   Defaults to "data-raw/Inventory & Descriptions/speakers per transcript.csv".
#'
#' @return A tibble with columns:
#'   - `n` (character): transcript id
#'   - `speakers` (list): unique, sorted character vector of speakers for that transcript
#' @examples
#' # Load in all unique speakers in each transcript
#' speakers <- get_transcript_speakers()
#'
#'
#' @export
get_transcript_speakers <- function(
    path = file.path("data-raw", "Inventory & Descriptions", "speakers per transcript.csv")
) {
  if (!file.exists(path)) {
    stop("Speakers-per-transcript file not found at: ", path, call. = FALSE)
  }

  df <- readr::read_csv(path, show_col_types = FALSE, progress = FALSE)

  if (!"n" %in% names(df)) {
    stop("Expected column 'n' in speakers-per-transcript file.", call. = FALSE)
  }

  # accept both correct and misspelled prefixes
  speaker_cols <- grep("^(speakrer_std_|speaker_std_)[0-9]+$", names(df), value = TRUE)
  if (!length(speaker_cols)) {
    stop(
      "No speaker columns found. Expected columns like 'speakrer_std_1' or 'speaker_std_1'.",
      call. = FALSE
    )
  }

  df |>
    dplyr::mutate(n = as.character(.data$n)) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      speakers = list({
        v <- unlist(dplyr::c_across(dplyr::all_of(speaker_cols)), use.names = FALSE)
        v <- as.character(v)
        v <- v[!is.na(v)]
        v <- trimws(v)
        v <- v[nzchar(v)]
        sort(unique(v))
      })
    ) |>
    dplyr::ungroup() |>
    dplyr::select(n, speakers) |>
    tibble::as_tibble()
}
