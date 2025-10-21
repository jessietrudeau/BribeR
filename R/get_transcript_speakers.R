#' Retrieve All Unique Speakers Across Transcripts
#'
#' This function scans all `.csv` transcript files in the
#' `data-raw/transcripts` folder of the **BribeRdata** package and
#' returns a vector of all unique speaker names found in the
#' `speaker_std` column.
#'
#' Each transcript is read individually, and unique speaker names are
#' combined into a single deduplicated list.
#'
#' For reference, see the BribeRdata repository:
#' <https://github.com/jessietrudeau/BribeRdata/tree/main/data-raw/transcripts>
#'
#' @param package Character string naming the package that stores the transcripts.
#' Defaults to `"BribeRdata"`.
#'
#' @return A character vector of unique standardized speaker names.
#'
#' @examples
#' \dontrun{
#' # Retrieve all unique speaker names
#' speakers <- get_transcript_speakers()
#'
#' # Display how many unique speakers exist
#' length(speakers)
#'
#' # View a few examples
#' head(speakers, 10)
#' }
#'
#' @export
get_transcript_speakers <- function(package = "BribeRdata") {
  # Locate transcripts folder
  transcripts_dir <- system.file("data-raw", "transcripts", package = package)

  # Fallback for development mode
  if (transcripts_dir == "" && dir.exists(file.path("data-raw", "transcripts"))) {
    transcripts_dir <- file.path("data-raw", "transcripts")
  }

  if (transcripts_dir == "" || !dir.exists(transcripts_dir)) {
    stop("Transcript directory not found. Check that the package or data path exists.")
  }

  # List all .csv transcripts
  files <- list.files(transcripts_dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(files) == 0) stop("No transcript files found in ", transcripts_dir)

  # Iterate and extract 'speaker_std' values
  all_speakers <- unique(unlist(lapply(files, function(f) {
    dat <- tryCatch(read.csv(f, stringsAsFactors = FALSE), error = function(e) NULL)
    if (!is.null(dat) && "speaker_std" %in% names(dat)) {
      dat$speaker_std
    } else {
      NULL
    }
  })))

  # Clean up (remove NAs, duplicates, trim whitespace)
  all_speakers <- sort(unique(trimws(all_speakers)))
  all_speakers <- all_speakers[nzchar(all_speakers)]  # remove empty strings

  return(all_speakers)
}
