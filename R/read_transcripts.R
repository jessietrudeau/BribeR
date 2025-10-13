#' Read transcript files into an Arrow Table
#'
#' @description
#' Loads all `.csv` and `.tsv` transcript files from a directory into a single
#' `arrow::Table`. Each transcript is expected to contain at least the columns:
#' - `speaker_std` : standardized speaker identifier
#' - `speech` : transcript text, which will be renamed internally to `text`
#'
#' A new column `file_id` is added, taken from the basename of the file
#' (without the extension). Optionally, the raw `speaker` column can be
#' preserved if it exists in the input.
#'
#' @param dir Character string. Path to the directory containing transcript files.
#' @param pattern Regex pattern for matching files. Defaults to `"\\.(csv|tsv)$"`.
#' @param recursive Logical. Should subdirectories be searched? Default is `FALSE`.
#' @param keep_original_speaker Logical. If `TRUE`, include the original `speaker`
#'   column (if present) in the output. Default is `FALSE`.
#' @param skip_on_missing Logical. If `TRUE`, files missing required columns
#'   are skipped with a warning. If `FALSE`, the function stops with an error.
#'   Default is `TRUE`.
#' @param quiet Logical. If `FALSE`, print a message for each loaded file.
#'   Default is `TRUE`.
#'
#' @return
#' An `arrow::Table` with the following columns:
#' - `file_id` : transcript identifier (filename without extension)
#' - `speaker_std` : standardized speaker name
#' - `text` : transcript text
#' - `speaker` : included only if `keep_original_speaker = TRUE` and present in source
#'
#' @examples
read_transcripts <- function(
    dir,
    pattern = "\\.(csv|tsv)$",
    recursive = FALSE,
    keep_original_speaker = FALSE,
    skip_on_missing = TRUE,
    quiet = TRUE
) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Package 'arrow' is required. Please install it (e.g., install.packages('arrow')).", call. = FALSE)
  }

  files <- base::list.files(path = dir, pattern = pattern, full.names = TRUE, recursive = recursive)
  if (length(files) == 0L) {
    stop("No files found in '", dir, "' matching pattern '", pattern, "'.", call. = FALSE)
  }

  .read_transcript <- function(fp) {
    if (grepl("\\.csv$", fp, ignore.case = TRUE)) {
      readr::read_csv(fp, show_col_types = FALSE, progress = FALSE)
    } else if (grepl("\\.tsv$", fp, ignore.case = TRUE) || grepl("\\.txt$", fp, ignore.case = TRUE)) {
      readr::read_tsv(fp, show_col_types = FALSE, progress = FALSE)
    } else {
      stop("Unsupported file extension for: ", fp)
    }
  }

  out <- list()

  for (fp in files) {
    df <- try(.read_transcript(fp), silent = TRUE)
    if (inherits(df, "try-error")) {
      warning("Skipping unreadable file: ", basename(fp))
      next
    }

    required_cols <- c("speaker_std", "speech")
    missing <- setdiff(required_cols, names(df))
    if (length(missing) > 0) {
      msg <- paste0("Missing required column(s) [", paste(missing, collapse = ", "),
                    "] in ", basename(fp), ".")
      if (skip_on_missing) {
        warning(msg)
        next
      } else {
        stop(msg, call. = FALSE)
      }
    }

    core <- tibble::tibble(
      file_id     = tools::file_path_sans_ext(basename(fp)),
      speaker_std = as.character(df$speaker_std),
      text        = as.character(df$speech)
    )

    if (keep_original_speaker && "speaker" %in% names(df)) {
      core$speaker <- as.character(df$speaker)
    }

    core$speaker_std <- stringr::str_trim(core$speaker_std)
    core$text        <- stringr::str_trim(core$text)
    core <- dplyr::filter(core, !is.na(.data$text) & .data$text != "")

    if (!quiet) message("Loaded: ", basename(fp), " (", nrow(core), " rows)")
    out[[length(out) + 1L]] <- core
  }

  if (length(out) == 0L) {
    stop("No valid transcripts were loaded. Check files or set skip_on_missing = FALSE.", call. = FALSE)
  }

  all_df <- dplyr::bind_rows(out)
  arrow::Table$create(all_df)
}
