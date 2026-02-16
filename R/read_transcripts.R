#' Read Vladivideos Transcript Data
#'
#' Loads the bundled `vladivideos_detailed` dataset and optionally filters
#' by transcript ID(s).
#'
#' @param transcripts Optional numeric vector of transcript IDs (`n`) to
#'   keep. If `NULL` (the default), all transcripts are returned.
#'
#' @return A data frame with columns `n`, `row_id`, `date`, `speaker`,
#'   `speech`, `speaker_std`, and `topic`.
#'
#' @examples
#' # Load all transcripts
#' all <- read_transcripts()
#' head(all)
#'
#' # Load only transcript 1
#' t1 <- read_transcripts(transcripts = 1)
#'
#' # Load transcripts 5, 7, and 13
#' subset <- read_transcripts(transcripts = c(5, 7, 13))
#'
#' @seealso [get_transcripts_raw()], [get_transcript_id()], [get_transcript_speakers()]
#' @export
read_transcripts <- function(transcripts = NULL) {
  rda_path <- system.file("data", "vladivideos_detailed.rda", package = "BribeR")
  if (rda_path == "") {
    stop("Could not find vladivideos_detailed.rda in the BribeR package.")
  }
  env <- new.env()
  load(rda_path, envir = env)
  data <- env$compiled_transcripts

  if (!is.null(transcripts)) {
    if (!"n" %in% names(data)) {
      stop("Column 'n' not found in the data; cannot filter by transcript.")
    }
    data <- data[data$n %in% transcripts, ]
    if (nrow(data) == 0) {
      warning("No transcripts found matching IDs: ",
              paste(transcripts, collapse = ", "))
    }
  }

  # Reorder columns: n, row_id, date first, then everything else
  first_cols <- c("n", "row_id", "date")
  first_cols <- first_cols[first_cols %in% names(data)]
  remaining <- setdiff(names(data), first_cols)
  data <- data[, c(first_cols, remaining), drop = FALSE]

  return(data)
}















