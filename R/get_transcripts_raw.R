#' Retrieve Raw Transcript Files from bribeR
#'
#' This function retrieves one or more raw transcript `.csv` files from the
#' `data-raw/transcripts` folder of the **bribeR** package.
#' It supports both installed and development versions of the package.
#'
#' Transcripts are named by their numeric ID (e.g., `1.csv`, `19.csv`, `104.csv`).
#' You can load all transcripts or specify a subset by transcript ID.
#'
#' @param n Optional integer or vector of integers specifying which transcript(s)
#'   to load. If `NULL` (default), all transcripts are loaded.
#' @param combine Logical; if `TRUE`, combines all transcripts into a single tibble
#'   with an added column `n` (the transcript ID). Defaults to `FALSE`.
#' @param package Character string naming the package that stores the transcripts.
#'   Defaults to `"bribeR"`. (Kept for flexibility/testing.)
#'
#' @return If `combine = FALSE`, returns a named list of data frames (tibbles).
#'   If `combine = TRUE`, returns a combined tibble with an added column `n`.
#'
#'
#' @examples
#' \dontrun{
#' # Load all transcripts (as a list)
#' all_transcripts <- get_transcripts_raw()
#'
#' # Load a specific transcript by ID
#' t3 <- get_transcripts_raw(n = 3)
#'
#' # Load multiple transcripts and combine them
#' subset_combined <- get_transcripts_raw(
#'   n = c(3, 19, 104),
#'   combine = TRUE
#' )
#' }
#' @export
get_transcripts_raw <- function(n = NULL, combine = FALSE, package = "bribeR") {
  # Try system.file() first (installed package)
  transcripts_dir <- system.file("data-raw", "transcripts", package = package)

  # Fallback: local path during development
  if (transcripts_dir == "" && dir.exists(file.path("data-raw", "transcripts"))) {
    transcripts_dir <- file.path("data-raw", "transcripts")
  }

  if (transcripts_dir == "" || !dir.exists(transcripts_dir)) {
    stop("Transcript directory not found. Check that the package or data path exists.", call. = FALSE)
  }

  # List all CSV files
  files <- list.files(transcripts_dir, pattern = "\\.csv$", full.names = TRUE)

  if (length(files) == 0) {
    stop("No transcript .csv files found in: ", transcripts_dir, call. = FALSE)
  }

  # Filter by transcript ID(s)
  if (!is.null(n)) {
    n_chr <- as.character(n)
    target_files <- paste0(n_chr, ".csv")
    files <- files[basename(files) %in% target_files]

    if (length(files) == 0) {
      stop("No matching transcripts found for IDs: ", paste(n, collapse = ", "), call. = FALSE)
    }
  }

  # Read files into a named list
  transcripts <- lapply(files, function(fp) {
    if (requireNamespace("readr", quietly = TRUE)) {
      readr::read_csv(fp, show_col_types = FALSE, progress = FALSE)
    } else {
      utils::read.csv(fp, stringsAsFactors = FALSE)
    }
  })
  names(transcripts) <- tools::file_path_sans_ext(basename(files))

  # Combine into tibble if requested
  if (combine) {
    if (!requireNamespace("dplyr", quietly = TRUE)) {
      stop("Package 'dplyr' required for combine = TRUE", call. = FALSE)
    }

    transcripts <- dplyr::bind_rows(
      lapply(names(transcripts), function(id) {
        dplyr::mutate(transcripts[[id]], n = as.integer(id))
      })
    )
  }

  transcripts
}
