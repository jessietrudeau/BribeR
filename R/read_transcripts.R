#' Read and Optionally Filter a Transcript-Formatted RDA File
#'
#' This function loads a pre-processed `.rda` file containing compiled transcript data.
#' It supports loading from:
#' \itemize{
#'   \item A **local file path** on your computer,
#'   \item A **remote URL** (e.g., a GitHub raw link), or
#'   \item An **installed package’s** `data/` directory (optional).
#' }
#'
#' Optionally, users can specify one or multiple transcript IDs (`n`) to filter
#' only those transcripts of interest. If no filter is provided, the full dataset
#' is returned.
#'
#' @param path Character string specifying one of:
#' \itemize{
#'   \item The **name** of an `.rda` file within a package (without extension),
#'   \item A **local file path** to an `.rda`,
#'   \item Or a **URL** (e.g., GitHub raw link) pointing to an `.rda` file.
#' }
#' @param package Optional. Character string naming the package containing the RDA
#' (if loading from a package’s `data/` directory). Defaults to `NULL`.
#' @param transcripts Optional numeric or character vector specifying transcript
#' IDs (`n`) to filter. If `NULL`, all transcripts are returned.
#'
#' @return A data frame (or tibble) with columns `n`, `row_id`, `speaker`, `speech`,
#' and `speaker_std`. If `transcripts` is specified, only matching transcripts are returned.
#'
#' @examples
#' \dontrun{
#' # 1. Load the full dataset
#' all_transcripts <- read_transcripts(
#'   "https://raw.githubusercontent.com/jessietrudeau/BribeRdata/main/data/vladivideos_transcripts.rda"
#' )
#'
#' # 2. Retrieve only transcript 1
#' t1 <- read_transcripts(
#'   "https://raw.githubusercontent.com/jessietrudeau/BribeRdata/main/data/vladivideos_transcripts.rda",
#'   transcripts = 1
#' )
#'
#' # 3. Retrieve transcripts 5, 7, and 13
#' subset_transcripts <- read_transcripts(
#'   "https://raw.githubusercontent.com/jessietrudeau/BribeRdata/main/data/vladivideos_transcripts.rda",
#'   transcripts = c(5, 7, 13)
#' )
#' }
#'
#' @seealso [get_transcripts_raw()], [get_transcript_id()], [get_transcript_speakers()]
#' @export
read_transcripts <- function(path, package = NULL, transcripts = NULL) {
  if (missing(path) || !nzchar(path)) {
    stop("Please provide the name, path, or URL of the RDA file.")
  }

  resolved_path <- NULL

  # --- CASE 1: Remote RDA (e.g., GitHub raw link) ---
  if (grepl("^https?://", path)) {
    temp_file <- tempfile(fileext = ".rda")
    message("Downloading RDA from remote URL...")
    utils::download.file(path, destfile = temp_file, mode = "wb", quiet = TRUE)
    resolved_path <- temp_file
  }

  # --- CASE 2: Local RDA file ---
  else if (file.exists(path)) {
    resolved_path <- path
  }

  # --- CASE 3: Package RDA (if specified) ---
  else if (!is.null(package)) {
    pkg_path <- system.file("data", paste0(path, ".rda"), package = package)
    if (pkg_path == "" && file.exists(file.path("data", paste0(path, ".rda")))) {
      pkg_path <- file.path("data", paste0(path, ".rda"))
    }
    if (pkg_path != "" && file.exists(pkg_path)) {
      resolved_path <- pkg_path
    } else {
      stop("Could not find the specified .rda file in package or local directory: ", path)
    }
  }

  else {
    stop("Could not resolve path: please provide a valid file path, package name, or URL.")
  }

  # --- Load the RDA file ---
  env <- new.env()
  load(resolved_path, envir = env)
  obj_name <- ls(env)
  if (length(obj_name) != 1) {
    stop("The RDA file should contain exactly one object, found: ",
         paste(obj_name, collapse = ", "))
  }

  data <- get(obj_name, envir = env)

  # --- Validate column structure ---
  expected_cols <- c("n", "row_id", "speaker", "speech", "speaker_std")
  missing_cols <- setdiff(expected_cols, names(data))
  if (length(missing_cols) > 0) {
    warning("The following expected columns are missing: ",
            paste(missing_cols, collapse = ", "))
  }

  # --- Optional transcript filtering ---
  if (!is.null(transcripts)) {
    if (!"n" %in% names(data)) {
      stop("Column 'n' not found in the data; cannot filter by transcript.")
    }

    data <- dplyr::filter(data, n %in% transcripts)

    if (nrow(data) == 0) {
      warning("No transcripts found matching IDs: ", paste(transcripts, collapse = ", "))
    }
  }

  return(data)
}
