#' Read transcript-level metadata (n, date, speakers, duration, topics)
#'
#' @description
#' Builds a tidy data frame of transcript metadata from three sources:
#' 1) **Descriptions.csv** (transcript identifiers, dates, topic flags),
#' 2) **speakers_per_transcript.csv** (speaker roster per transcript), and
#' 3) the **finalized transcripts folder** (word-count duration from the `speech` column).
#'
#' @details
#' - **Transcript ID (`n`) and `date`:** Read from *Descriptions.csv*. The first
#'   column `n` identifies the transcript; `date` is taken as-is (coerced to character).
#' - **Topics (`topics` list-column):** Any columns in *Descriptions.csv* whose
#'   names start with `topic_` are interpreted as topic flags. A topic is considered
#'   present if the cell is “truthy” (e.g., `x`/`X`, non-empty string, `1`, `TRUE`).
#'   Topic names are normalized by removing the `topic_` prefix and replacing `_`
#'   with spaces.
#' - **Speakers (`speakers` list-column):** Read from *speakers_per_transcript.csv*.
#'   The file is expected to store speakers in wide form with columns named like
#'   `speakrer_std_1` **(source misspelling accepted)** or `speaker_std_1`, `..._2`, etc.
#'   These are collapsed to a unique, sorted character vector per transcript.
#' - **Duration (`n_words`):** If a matching transcript file exists in `transcripts_dir`,
#'   the function sums whitespace-delimited tokens across the `speech` column to produce
#'   a total word count. A transcript file is matched by basename (e.g., `12.csv` or `12.tsv`
#'   corresponds to `n == "12"`). If no file is found, `n_words` is `NA`.
#'
#' @param descriptions_path Character path to *Descriptions.csv* containing at least
#'   column `n`; ideally also `date` and topic flag columns prefixed with `topic_`.
#' @param speakers_per_transcript_path Character path to *speakers_per_transcript.csv*
#'   containing column `n` and wide speaker columns named `speakrer_std_#` or `speaker_std_#`.
#' @param transcripts_dir Character path to the folder containing finalized transcript files
#'   (`.csv`/`.tsv`) with a `speech` column used for word counts. Filenames (without extension)
#'   must match `n` in *Descriptions.csv*.
#' @param pattern Regex used to match transcript files in `transcripts_dir`. Default `"\\.(csv|tsv)$"`.
#' @param recursive Logical; search `transcripts_dir` subfolders. Default `FALSE`.
#' @param quiet Logical; if `FALSE`, prints progress messages. Default `TRUE`.
#'
#' @return
#' A tibble with one row per transcript and columns:
#' - `n` (character): transcript identifier (from *Descriptions.csv*).
#' - `date` (character): date from *Descriptions.csv* (or `NA` if absent).
#' - `speakers` (list of character): unique, sorted vector of speakers for the transcript.
#' - `n_words` (integer): total word count across the transcript’s `speech` column
#'   (or `NA` if the file is not found / lacks `speech`).
#' - `topics` (list of character): vector of topic names inferred from `topic_*` flags.
#'
#' @examples
#' \dontrun{
#' meta <- read_transcript_meta_data(
#'    descriptions_path = "data-raw/Inventory & Descriptions/Descriptions.csv",
#'    speakers_per_transcript_path = "data-raw/Inventory & Descriptions/speakers per transcript.csv",
#'     transcripts_dir = "data-raw/transcripts",
#'    recursive = TRUE
#'     )
#'
#' view(meta)
#' }
#'



read_transcript_meta_data <- function(
    descriptions_path,
    speakers_per_transcript_path,
    transcripts_dir,
    pattern = "\\.(csv|tsv)$",
    recursive = FALSE,
    quiet = TRUE
) {
  # --- helpers
  .read_tabular <- function(fp) {
    if (grepl("\\.csv$", fp, ignore.case = TRUE)) {
      readr::read_csv(fp, show_col_types = FALSE, progress = FALSE)
    } else if (grepl("\\.tsv$", fp, ignore.case = TRUE) || grepl("\\.txt$", fp, ignore.case = TRUE)) {
      readr::read_tsv(fp, show_col_types = FALSE, progress = FALSE)
    } else {
      stop("Unsupported file extension for: ", fp)
    }
  }
  .is_topic_marked <- function(x) {
    # Treat common truthy marks as a topic flag (x, X, 1, TRUE, non-empty strings)
    if (is.logical(x)) return(isTRUE(x))
    if (is.numeric(x)) return(!is.na(x) && x != 0)
    if (is.character(x)) {
      v <- tolower(trimws(x))
      return(!is.na(v) && nzchar(v) && !v %in% c("0","false","no","na","n/a"))
    }
    FALSE
  }

  # --- load inputs
  desc <- .read_tabular(descriptions_path)
  spt  <- .read_tabular(speakers_per_transcript_path)

  # --- validate basics
  if (!"n" %in% names(desc)) stop("`Descriptions.csv` must include column 'n'.", call. = FALSE)
  if (!"date" %in% names(desc)) {
    if (!quiet) warning("`Descriptions.csv` has no 'date' column; setting NA for dates.")
    desc$date <- NA_character_
  }
  if (!"n" %in% names(spt))  stop("`speakers_per_transcript.csv` must include column 'n'.", call. = FALSE)

  # --- normalize ids
  desc <- dplyr::mutate(desc, n = as.character(.data$n))
  spt  <- dplyr::mutate(spt,  n = as.character(.data$n))

  # --- speakers vector: wide -> long -> list-column
  spt_speaker_cols <- grep("^(speakrer_std_|speaker_std_)[0-9]+$", names(spt), value = TRUE)
  if (!length(spt_speaker_cols)) {
    stop("`speakers_per_transcript.csv` must include columns like 'speakrer_std_1' or 'speaker_std_1'.", call. = FALSE)
  }
  speakers_long <- spt |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(spt_speaker_cols),
      names_to = "slot",
      values_to = "speaker_std"
    ) |>
    dplyr::mutate(speaker_std = stringr::str_trim(as.character(.data$speaker_std))) |>
    dplyr::filter(!is.na(.data$speaker_std) & .data$speaker_std != "") |>
    dplyr::distinct(n, speaker_std)

  speakers_vec <- speakers_long |>
    dplyr::group_by(n) |>
    dplyr::summarise(speakers = list(sort(unique(speaker_std))), .groups = "drop")

  # --- topics vector from Descriptions.csv (columns marked with x / truthy)
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
      dplyr::select(n, topics)
  } else {
    dplyr::transmute(desc, n, topics = list(character(0)))
  }

  # --- duration metric: total word count by transcript from finalized data (speech column)
  files <- base::list.files(transcripts_dir, pattern = pattern, full.names = TRUE, recursive = recursive)
  if (length(files) == 0L && !quiet) message("No transcript files found in '", transcripts_dir, "' with pattern '", pattern, "'. Word counts set to NA.")
  counts <- lapply(files, function(fp) {
    df <- try(.read_tabular(fp), silent = TRUE)
    if (inherits(df, "try-error")) return(NULL)
    if (!"speech" %in% names(df)) return(NULL)
    txt <- df$speech
    if (!is.character(txt)) txt <- as.character(txt)
    txt <- txt[!is.na(txt) & nzchar(txt)]
    n_words <- if (length(txt)) sum(stringr::str_count(txt, "\\S+"), na.rm = TRUE) else 0L
    data.frame(
      n = as.character(tools::file_path_sans_ext(basename(fp))),
      n_words = as.integer(n_words),
      stringsAsFactors = FALSE
    )
  })
  counts <- counts[!vapply(counts, is.null, logical(1))]
  duration_df <- if (length(counts)) dplyr::bind_rows(counts) else dplyr::tibble(n = character(0), n_words = integer(0))

  # --- assemble output: col1 n, col2 date, col3 speakers (vector), col4 n_words, col5 topics (vector)
  meta <- desc |>
    dplyr::transmute(n, date = as.character(.data$date)) |>
    dplyr::left_join(speakers_vec, by = "n") |>
    dplyr::left_join(duration_df,  by = "n") |>
    dplyr::left_join(topics_vec,   by = "n")

  # ensure list-cols exist even if missing
  if (!"speakers" %in% names(meta)) meta$speakers <- replicate(nrow(meta), character(0), simplify = FALSE)
  if (!"topics"   %in% names(meta)) meta$topics   <- replicate(nrow(meta), character(0), simplify = FALSE)
  if (!"n_words"  %in% names(meta)) meta$n_words  <- NA_integer_

  meta <- meta |>
    dplyr::select(n, date, speakers, n_words, topics) |>
    tibble::as_tibble()

  if (!quiet) {
    message("Built metadata for ", nrow(meta), " transcripts.")
  }
  meta
}

