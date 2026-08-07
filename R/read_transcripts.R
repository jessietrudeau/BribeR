#' Read Vladivideos Transcript Data
#'
#' Loads the bundled `compiled_transcripts` dataset and optionally filters
#' by transcript ID(s).
#'
#' @param transcripts Optional numeric vector of transcript IDs to keep.
#'   If `NULL` (the default), all transcripts are returned.
#'
#' @return A data frame with columns `id`, `row_id`, `date`, `speaker_std`,
#'   `speaker`, and `speech`.
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
  env <- new.env(parent = emptyenv())
  utils::data("compiled_transcripts", package = "BribeR", envir = env)
  data <- env$compiled_transcripts

  if (!is.null(transcripts)) {
    if (!"id" %in% names(data)) {
      stop("Column 'id' not found in the data; cannot filter by transcript.")
    }
    data <- data[data$id %in% transcripts, ]
    if (nrow(data) == 0) {
      warning("No transcripts found matching IDs: ",
              paste(transcripts, collapse = ", "))
    }
  }

  return(data)
}















