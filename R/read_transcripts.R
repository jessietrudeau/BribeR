#' Read a Transcript-Formatted RDA File
#'
#' This function loads a pre-processed `.rda` file containing compiled transcript data.
#' It supports loading from:
#' \itemize{
#'   \item A **local file path** on your computer,
#'   \item A **remote URL** (e.g., a GitHub raw link), or
#'   \item An **installed package’s** `data/` directory (optional).
#' }
#'
#' The `.rda` file must contain a single object with the standardized transcript structure:
#' \describe{
#'   \item{n}{Transcript ID or name (the original `.csv` file name).}
#'   \item{row_id}{Row number within the individual transcript (chronological order).}
#'   \item{speaker}{Original speaker label from the source transcript.}
#'   \item{speech}{Speech text content of the transcript.}
#'   \item{speaker_std}{Standardized or normalized version of the speaker name.}
#' }
#'
#' This function is general-purpose and not tied to any particular package. Any `.rda`
#' file that follows the schema above can be loaded for analysis or further processing.
#'
#' For demonstration purposes, the examples use the open-source
#' **BribeRData** repository and its dataset
#' [`vladivideos_transcripts.rda`](https://github.com/jessietrudeau/BribeRdata/blob/730367bc869081ecd994c73754b51e4373eab887/data/vladivideos_transcripts.rda).
#'
#' @param path Character string specifying one of:
#' \itemize{
#'   \item The **name** of an `.rda` file within a package (without extension),
#'   \item A **local file path** to an `.rda`,
#'   \item Or a **URL** (e.g., GitHub raw link) pointing to an `.rda` file.
#' }
#' @param package Optional. Character string naming the package containing the RDA
#' (if loading from a package’s `data/` directory). Defaults to `NULL`.
#'
#' @return A data frame (or tibble) with columns `n`, `row_id`, `speaker`, `speech`,
#' and `speaker_std`.
#'
#' @examples
#' \dontrun{
#' # 1. Load a local RDA file
#' transcripts_local <- read_transcripts("~/Documents/transcripts_subset.rda")
#'
#' # 2. Load a remote RDA file from GitHub (BribeRData example)
#' transcripts_remote <- read_transcripts(
#'   "https://raw.githubusercontent.com/jessietrudeau/BribeRdata/730367bc869081ecd994c73754b51e4373eab887/data/vladivideos_transcripts.rda"
#' )
#'
#' # 3. Load from a package (optional, if available)
#' transcripts_pkg <- read_transcripts("vladivideos_transcripts", package = "BribeRdata")
#'
#' # View structure and inspect speaker names
#' str(transcripts_remote)
#' unique(transcripts_remote$speaker_std)
#' }
#'
#' @seealso [get_transcripts_raw()], [get_transcript_id()], [get_transcript_speakers()]
#' @export
read_transcripts <- function(path, package = NULL) {
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

  return(data)
}
