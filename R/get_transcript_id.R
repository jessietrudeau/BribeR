#' Retrieve Available Transcript IDs
#'
#' This function lists all available transcript IDs (or *n* values)
#' based on the `.csv` files stored in the `data-raw/transcripts` folder
#' of the **BribeRdata** package.
#'
#' Each transcript is named numerically (e.g., `1.csv`, `19.csv`, `104.csv`),
#' and its ID corresponds directly to that number.
#'
#' For reference, see the BribeRdata repository:
#' <https://github.com/jessietrudeau/BribeRdata/tree/main/data-raw/transcripts>
#'
#' @param package Character string naming the package that stores the transcripts.
#' Defaults to `"BribeRdata"`.
#'
#' @return A numeric vector of available transcript IDs.
#'
#' @examples
#' \dontrun{
#' # Retrieve all available transcript IDs
#' ids <- get_transcript_id()
#'
#' # Use those IDs to load specific transcripts
#' subset <- get_transcripts_raw(n = ids[1:3])
#' }
#'
#' @export
get_transcript_id <- function(package = "BribeRdata") {
  # Try system.file() first (for installed package)
  transcripts_dir <- system.file("data-raw", "transcripts", package = package)

  # Fallback: use local path during development
  if (transcripts_dir == "" && dir.exists(file.path("data-raw", "transcripts"))) {
    transcripts_dir <- file.path("data-raw", "transcripts")
  }

  # Validate that the directory exists
  if (transcripts_dir == "" || !dir.exists(transcripts_dir)) {
    stop("Transcript directory not found. Check that the package or data path exists.")
  }

  # List all CSV files
  files <- list.files(transcripts_dir, pattern = "\\.csv$", full.names = FALSE)

  # Extract numeric IDs
  ids <- as.numeric(tools::file_path_sans_ext(files))
  ids <- sort(ids, na.last = NA)

  return(ids)
}
