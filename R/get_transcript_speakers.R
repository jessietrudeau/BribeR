#' Get transcripts each speaker appears in
#'
#' Loads the bundled `speakers_per_transcript` dataset and returns one row per
#' unique speaker with a list-column of transcript IDs (`n`) where that speaker
#' appears.
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
#' @seealso [read_transcripts()], [get_transcript_id()], [get_transcripts_raw()]
#' @export
get_transcript_speakers <- function() {
  rda_path <- system.file("data", "speakers_per_transcript.rda", package = "BribeR")
  if (rda_path == "") {
    stop("Could not find speakers_per_transcript.rda in the BribeR package.", call. = FALSE)
  }

  env <- new.env()
  load(rda_path, envir = env)
  df <- env$speakers_per_transcript

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

  # Pivot to long format: one row per (n, speaker_std)
  long <- df |>
    dplyr::mutate(n = as.numeric(.data$n)) |>
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



