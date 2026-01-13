# data-raw/build_transcripts.R

# ---- setup ----
required_pkgs <- c("readr", "dplyr", "purrr", "stringr", "fs")
to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")

library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(fs)

# ---- config ----
TRANSCRIPTS_DIR <- "data-raw/transcripts"
OUTPUT_DATA_DIR <- "data"
OBJECT_NAME     <- "vladivideos_transcripts"
OUTPUT_RDA_PATH <- file.path(OUTPUT_DATA_DIR, paste0(OBJECT_NAME, ".rda"))

# ---- helpers ----
.read_one_transcript <- function(path) {
  # n from filename (e.g., "50.csv" -> 50)
  fname <- path_file(path)
  n_chr <- tools::file_path_sans_ext(fname)
  n_num <- suppressWarnings(as.integer(n_chr))
  
  df <- readr::read_csv(
    file = path,
    col_types = cols(
      speaker     = col_character(),
      speech      = col_character(),
      speaker_std = col_character(),
      .default    = col_guess()
    ),
    progress = FALSE
  )
  
  required_cols <- c("speaker", "speech", "speaker_std")
  missing <- setdiff(required_cols, names(df))
  if (length(missing)) {
    stop(sprintf("File %s is missing required columns: %s",
                 path, paste(missing, collapse = ", ")))
  }
  
  df %>%
    mutate(
      n = if (!is.na(n_num)) n_num else n_chr,  # numeric when possible, else character
      row_id = dplyr::row_number()
    ) %>%
    relocate(n, row_id, speaker, speech, speaker_std)
}

# ---- build ----
if (!dir_exists(TRANSCRIPTS_DIR)) {
  stop(sprintf("Directory not found: %s", TRANSCRIPTS_DIR))
}
if (!dir_exists(OUTPUT_DATA_DIR)) {
  dir_create(OUTPUT_DATA_DIR, recurse = TRUE)
}

csv_paths <- dir_ls(TRANSCRIPTS_DIR, regexp = "\\.csv$", type = "file", recurse = FALSE)

if (length(csv_paths) == 0L) {
  stop(sprintf("No CSV files found in %s", TRANSCRIPTS_DIR))
}

message(sprintf("Found %d CSV files. Reading & combining...", length(csv_paths)))

vladivideos_transcripts <- csv_paths %>%
  { 
    basenames <- path_file(.)
    nums <- suppressWarnings(as.integer(tools::file_path_sans_ext(basenames)))
    if (all(!is.na(nums))) .[order(nums)] else sort(.)
  } %>%
  map_dfr(.read_one_transcript) %>%
  mutate(
    speaker     = as.character(speaker),
    speech      = as.character(speech),
    speaker_std = as.character(speaker_std)
  )

# ---- save ----
save(vladivideos_transcripts, file = OUTPUT_RDA_PATH, compress = "xz")
message(sprintf("Saved combined transcripts to: %s", OUTPUT_RDA_PATH))
