#' Read transcript-level metadata (id, date, speakers, duration, topics)
#'
#' @description
#' Builds a tidy data frame of transcript metadata from bundled package data.
#' Combines information from three internal sources:
#' 1. **transcript_index** (transcript identifiers, dates, topic flags),
#' 2. **speakers_per_transcript** (speaker roster per transcript), and
#' 3. **compiled_transcripts** (word counts derived from the `speech` column).
#'
#' @details
#' - **Transcript ID (`id`) and `date`:** Read from the bundled `transcript_index` dataset.
#' - **Topics (`topics` list-column):** Columns in `transcript_index` whose names start
#'   with `topic_` are interpreted as topic flags (1/0 integers). Topic names are
#'   normalized by removing the `topic_` prefix and replacing `_` with spaces.
#' - **Speakers (`speakers` list-column):** Read from the bundled `speakers_per_transcript`
#'   dataset. Speaker columns are collapsed to a unique, sorted character vector per transcript.
#' - **Duration (`n_words`):** Computed from the bundled `compiled_transcripts` dataset by
#'   summing whitespace-delimited tokens in the `speech` column for each unique transcript `n`.
#'
#' @param quiet Logical; if `FALSE`, prints progress messages. Default `TRUE`.
#'
#' @return
#' A tibble with one row per transcript and columns:
#' - `id` (numeric): transcript identifier.
#' - `date` (character): date associated with the transcript (or `NA` if absent).
#' - `speakers` (list of character): unique, sorted vector of speakers for the transcript.
#' - `n_words` (integer): total word count across the transcript's `speech` column.
#' - `topics` (list of character): vector of topic names inferred from `topic_*` flags.
#'
#' @examples
#' \donttest{
#' # Load metadata for all transcripts
#' meta <- read_transcript_meta_data()
#' head(meta)
#' }
#'
#' @seealso [read_transcripts()], [get_transcript_speakers()]
#' @export
read_transcript_meta_data <- function(quiet = TRUE) {

  # --- helper: detect truthy topic flags
  .is_topic_marked <- function(x) {
    if (is.logical(x)) return(isTRUE(x))
    if (is.numeric(x)) return(!is.na(x) && x != 0)
    if (is.character(x)) {
      v <- tolower(trimws(x))
      return(!is.na(v) && nzchar(v) && !v %in% c("0", "false", "no", "na", "n/a"))
    }
    FALSE
  }

  # --- load bundled data
  .load_pkg_data <- function(dataset_name, object_name = dataset_name) {
    env <- new.env(parent = emptyenv())
    utils::data(list = dataset_name, package = "BribeR", envir = env)
    env[[object_name]]
  }

  desc        <- .load_pkg_data("transcript_index")
  spt         <- .load_pkg_data("speakers_per_transcript")
  transcripts <- .load_pkg_data("compiled_transcripts")

  # --- validate basics
  if (!"id" %in% names(desc)) stop("`transcript_index` must include column 'id'.", call. = FALSE)
  if (!"date" %in% names(desc)) {
    if (!quiet) warning("`transcript_index` has no 'date' column; setting NA for dates.")
    desc$date <- NA_character_
  }
  if (!"id" %in% names(spt)) stop("`speakers_per_transcript` must include column 'id'.", call. = FALSE)

  # --- normalize ids
  desc <- dplyr::mutate(desc, id = as.character(.data$id))
  spt  <- dplyr::mutate(spt,  id = as.character(.data$id))

  # --- drop transcript IDs that have no actual transcript data
  valid_ids <- unique(as.character(transcripts$id))
  desc <- dplyr::filter(desc, .data$id %in% valid_ids)

  # --- speakers: wide -> long -> list-column
  spt_speaker_cols <- grep("^(speakrer_std_|speaker_std_)[0-9]+$", names(spt), value = TRUE)
  if (!length(spt_speaker_cols)) {
    stop("`speakers_per_transcript` must include columns like 'speaker_std_1'.", call. = FALSE)
  }

  speakers_long <- spt |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(spt_speaker_cols),
      names_to = "slot",
      values_to = "speaker_std"
    ) |>
    dplyr::mutate(speaker_std = stringr::str_trim(as.character(.data$speaker_std))) |>
    dplyr::filter(!is.na(.data$speaker_std) & .data$speaker_std != "") |>
    dplyr::distinct(.data$id, .data$speaker_std)

  speakers_vec <- speakers_long |>
    dplyr::group_by(.data$id) |>
    dplyr::summarise(speakers = list(sort(unique(.data$speaker_std))), .groups = "drop")

  # --- topics: from topic_* flag columns in descriptions
  topic_cols <- grep("^topic_", names(desc), value = TRUE)
  topics_vec <- if (length(topic_cols)) {
    desc |>
      dplyr::rowwise() |>
      dplyr::mutate(
        topics = list({
          chosen <- character(0)
          for (tc in topic_cols) {
            if (.is_topic_marked(get(tc))) {
              nm <- gsub("^topic_", "", tc)
              nm <- gsub("_", " ", nm)
              chosen <- c(chosen, nm)
            }
          }
          unique(chosen)
        })
      ) |>
      dplyr::ungroup() |>
      dplyr::select(.data$id, .data$topics)
  } else {
    dplyr::transmute(desc, id = .data$id, topics = list(character(0)))
  }

  # --- word counts: from compiled_transcripts speech column
  transcripts <- dplyr::mutate(transcripts, id = as.character(.data$id))

  duration_df <- transcripts |>
    dplyr::filter(!is.na(.data$speech) & .data$speech != "") |>
    dplyr::group_by(.data$id) |>
    dplyr::summarise(
      n_words = as.integer(sum(stringr::str_count(.data$speech, "\\S+"), na.rm = TRUE)),
      .groups = "drop"
    )

  # --- convert joining tables to numeric id before assembly
  speakers_vec <- dplyr::mutate(speakers_vec, id = as.numeric(.data$id))
  duration_df  <- dplyr::mutate(duration_df,  id = as.numeric(.data$id))
  topics_vec   <- dplyr::mutate(topics_vec,   id = as.numeric(.data$id))

  # --- assemble output
  meta <- desc |>
    dplyr::transmute(id = as.numeric(.data$id), date = as.character(.data$date)) |>
    dplyr::left_join(speakers_vec, by = "id") |>
    dplyr::left_join(duration_df,  by = "id") |>
    dplyr::left_join(topics_vec,   by = "id")

  # ensure list-cols exist even if missing
  if (!"speakers" %in% names(meta)) meta$speakers <- replicate(nrow(meta), character(0), simplify = FALSE)
  if (!"topics"   %in% names(meta)) meta$topics   <- replicate(nrow(meta), character(0), simplify = FALSE)
  if (!"n_words"  %in% names(meta)) meta$n_words  <- NA_integer_

  meta <- meta |>
    dplyr::select(.data$id, .data$date, .data$speakers, .data$n_words, .data$topics) |>
    tibble::as_tibble()

  if (!quiet) {
    message("Built metadata for ", nrow(meta), " transcripts.")
  }

  meta
}










