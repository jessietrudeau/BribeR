# ======================================================================
# Build Transcript Index with Binary Topic & Speaker Columns
# (Modified: Handles wide-format "speakers per transcript.csv" file)
# ======================================================================

# ---- setup ----
required_pkgs <- c("fs", "dplyr", "stringr", "tools", "readr", "purrr", "lubridate", "tidyr")
to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")

library(fs)
library(dplyr)
library(stringr)
library(tools)
library(readr)
library(purrr)
library(lubridate)
library(tidyr)

# ---- configuration ----
transcripts_candidates <- c(
  Sys.getenv("TRANSCRIPTS_DIR", unset = NA),
  "data-raw/transcripts"
) |> unique()
transcripts_candidates <- transcripts_candidates[!is.na(transcripts_candidates)]
transcripts_root <- transcripts_candidates[dir_exists(transcripts_candidates)][1]
if (is.na(transcripts_root)) {
  stop("No transcripts directory found. Checked: ", paste(transcripts_candidates, collapse = " | "))
}
rel_start <- path_dir(transcripts_root)

# ---- list transcript files ----
files <- dir_ls(
  transcripts_root, recurse = TRUE, type = "file",
  regexp = "(?i)\\.(csv|tsv)$"
)
if (length(files) == 0L) stop("No transcript files found under: ", transcripts_root)

# Sort numerically by basename if possible
base_ids <- tools::file_path_sans_ext(path_file(files))
nums <- suppressWarnings(as.integer(base_ids))
ord <- if (all(!is.na(nums))) order(nums) else order(base_ids)
files <- files[ord]

# ---- load descriptions (for topics + date) ----
descriptions_df <- NULL
used_source <- NULL

if (exists("descriptions", inherits = TRUE)) {
  obj <- get("descriptions", inherits = TRUE)
  if (is.data.frame(obj)) {
    descriptions_df <- obj
    used_source <- "memory(descriptions)"
  }
}

if (is.null(descriptions_df)) {
  rda_candidate <- Sys.getenv("DESCRIPTIONS_RDA", unset = "~/Documents/BribeRdata/data/descriptions.rda")
  if (file_exists(rda_candidate)) {
    env <- new.env(parent = emptyenv())
    loaded <- load(rda_candidate, envir = env)
    if ("descriptions" %in% loaded && is.data.frame(env$descriptions)) {
      descriptions_df <- env$descriptions
      used_source <- rda_candidate
    }
  }
}

if (is.null(descriptions_df)) {
  desc_candidates <- c(
    Sys.getenv("DESCRIPTIONS_CSV", unset = NA),
    "data-raw/Inventory & Descriptions/descriptions.csv",
    "data-raw/descriptions.csv",
    file.path(transcripts_root, "descriptions.csv")
  ) |> unique()
  desc_candidates <- desc_candidates[!is.na(desc_candidates)]
  desc_path <- desc_candidates[file_exists(desc_candidates)][1]
  if (is.na(desc_path)) {
    stop("descriptions.csv not found. Checked: ", paste(desc_candidates, collapse = " | "))
  }
  descriptions_df <- read_csv(desc_path, show_col_types = FALSE)
  used_source <- desc_path
}

message("Using descriptions from: ", used_source)

# ---- identify and convert topic columns to binary ----
topic_cols <- grep("(?i)^topic", names(descriptions_df), value = TRUE)
message("Detected ", length(topic_cols), " topic columns.")
if (length(topic_cols) > 0) {
  descriptions_df <- descriptions_df %>%
    mutate(across(
      all_of(topic_cols),
      ~ ifelse(str_detect(str_to_lower(trimws(.)), "x"), 1L, 0L)
    ))
} else {
  message("⚠️ No topic columns found. Check column names in descriptions.csv.")
}

# ---- prepare metadata (n + date + topics) ----
metadata_df <- descriptions_df %>%
  mutate(
    n = suppressWarnings(as.integer(n)),
    date = suppressWarnings(parse_date_time(
      date,
      orders = c(
        "Y-m-d", "Y/m/d", "Ymd",
        "m/d/Y", "m-d-Y", "mdY",
        "d/m/Y", "d-m-Y", "dmY",
        "d b Y", "d B Y", "b d Y", "B d Y",
        "Y b d", "Y B d", "b Y", "B Y", "Y"
      ),
      tz = "UTC"
    ) |> as.Date())
  ) %>%
  select(n, date, all_of(topic_cols)) %>%
  filter(!is.na(n))

# ======================================================================
# MODIFIED SECTION: Handle wide-format "speakers per transcript.csv"
# ======================================================================

message("Loading wide-format 'speakers per transcript.csv'...")

speakers_path <- "/Users/andressoto/Documents/BribeRdata/data-raw/Inventory & Descriptions/speakers per transcript.csv"

if (!file_exists(speakers_path)) {
  stop("The file 'speakers per transcript.csv' was not found at ", speakers_path)
}

speakers_df <- read_csv(speakers_path, show_col_types = FALSE)

# Identify all speaker columns (with the typo 'speakrer_std_')
speaker_cols <- grep("^speakrer_std_", names(speakers_df), value = TRUE)
if (length(speaker_cols) == 0) {
  stop("No 'speakrer_std_' columns detected in the speakers file.")
}

# Convert wide-format table to long-format (one row per speaker)
speaker_table <- speakers_df %>%
  pivot_longer(
    cols = all_of(speaker_cols),
    names_to = "speaker_col",
    values_to = "speaker_std"
  ) %>%
  filter(!is.na(speaker_std), speaker_std != "") %>%
  mutate(
    n = as.integer(n),
    speaker_key = str_to_lower(str_squish(str_trim(speaker_std)))
  ) %>%
  distinct(n, speaker_key)

# Build binary matrix of speaker presence per transcript
speaker_matrix <- speaker_table %>%
  mutate(value = 1L) %>%
  pivot_wider(
    id_cols = n,
    names_from = speaker_key,
    values_from = value,
    values_fill = list(value = 0L),
    names_prefix = "speaker_"
  )

message("Constructed speaker matrix from wide-format file (",
        nrow(speaker_matrix), " transcripts; ",
        length(grep('^speaker_', names(speaker_matrix))), " unique speakers).")

# ======================================================================
# Continue normal logic
# ======================================================================

# ---- load actors.csv and filter speaker columns ----
actor_candidates <- c(
  Sys.getenv("ACTORS_CSV", unset = NA),
  "data-raw/Inventory & Descriptions/actors.csv",
  "data-raw/actors.csv"
) |> unique()
actor_candidates <- actor_candidates[!is.na(actor_candidates)]
actor_path <- actor_candidates[file_exists(actor_candidates)][1]

if (!is.na(actor_path)) {
  message("Using actors list from: ", actor_path)
  actors_df <- read_csv(actor_path, show_col_types = FALSE)
  valid_speakers <- actors_df %>%
    filter(!is.na(speaker_std)) %>%
    mutate(speaker_key = str_to_lower(str_squish(str_trim(speaker_std)))) %>%
    pull(speaker_key) %>%
    unique()
} else {
  warning("⚠️ actors.csv not found. Keeping all speakers.")
  valid_speakers <- unique(speaker_table$speaker_key)
}

# ---- filter speaker columns by actors.csv ----
if (exists("speaker_matrix") && nrow(speaker_matrix) > 0) {
  speaker_cols_to_keep <- paste0("speaker_", valid_speakers)
  existing_speaker_cols <- grep("^speaker_", names(speaker_matrix), value = TRUE)
  keep_cols <- intersect(existing_speaker_cols, speaker_cols_to_keep)
  speaker_matrix <- speaker_matrix %>%
    select(any_of(c("n", keep_cols)))
  removed_cols <- setdiff(existing_speaker_cols, keep_cols)
  message("Filtered to ", length(keep_cols), " valid speakers from actors.csv.")
  if (length(removed_cols) > 0) {
    message("Removed ", length(removed_cols), " speakers not found in actors.csv.")
  }
}

# ---- build transcript index ----
transcript_index <- tibble(file_abs = files) %>%
  mutate(
    file   = path_rel(file_abs, start = rel_start),
    id     = tools::file_path_sans_ext(path_file(file_abs)),
    n      = suppressWarnings(as.integer(id)),
    format = tolower(path_ext(file_abs))
  ) %>%
  select(n, file, format) %>%
  left_join(metadata_df, by = "n") %>%
  left_join(speaker_matrix, by = "n") %>%
  arrange(n, file)

# ---- replace NA with 0 ----
speaker_cols_present <- grep("^speaker_", names(transcript_index), value = TRUE)
topic_cols_present   <- grep("^topic_", names(transcript_index), value = TRUE)

if (length(speaker_cols_present) > 0) {
  transcript_index <- transcript_index %>%
    mutate(across(all_of(speaker_cols_present), ~ replace_na(., 0L)))
}
if (length(topic_cols_present) > 0) {
  transcript_index <- transcript_index %>%
    mutate(across(all_of(topic_cols_present), ~ replace_na(., 0L)))
}

# ---- add summary counts ----
transcript_index <- transcript_index %>%
  mutate(
    topic_count   = if (length(topic_cols_present) > 0)
      rowSums(across(all_of(topic_cols_present)), na.rm = TRUE) else NA_integer_,
    speaker_count = if (length(speaker_cols_present) > 0)
      rowSums(across(all_of(speaker_cols_present)), na.rm = TRUE) else NA_integer_
  )

# ---- diagnostics ----
if (any(is.na(transcript_index$n))) {
  warning("Non-numeric filenames detected; some `n` values are NA.")
}
if ("date" %in% names(transcript_index) && any(is.na(transcript_index$date))) {
  message("ℹ️ Some transcripts are missing date information.")
}

message("Speaker columns kept: ", length(speaker_cols_present))
message("Topic columns created: ", length(topic_cols_present))

# ---- save output ----
dir_create("data")
save(transcript_index, file = "data/transcript_index.rda", compress = "bzip2")

message("✅ Saved transcript_index to data/transcript_index.rda (",
        nrow(transcript_index), " transcripts; ",
        length(topic_cols_present), " topic cols; ",
        length(speaker_cols_present), " speaker cols).")
