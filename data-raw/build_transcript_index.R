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
  "inst/data-raw/transcripts",
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

# ---- load descriptions.csv ----
# There is no standalone `descriptions` dataset shipped with the package;
# its content is folded directly into `transcript_index` below.
desc_candidates <- c(
  Sys.getenv("DESCRIPTIONS_CSV", unset = NA),
  "data-raw/Inventory & Descriptions/Descriptions.csv",
  "data-raw/descriptions.csv",
  file.path(transcripts_root, "descriptions.csv")
) |> unique()
desc_candidates <- desc_candidates[!is.na(desc_candidates)]
desc_path <- desc_candidates[file_exists(desc_candidates)][1]
if (is.na(desc_path)) {
  stop("descriptions.csv not found. Checked: ", paste(desc_candidates, collapse = " | "))
}
descriptions_df <- read_csv(desc_path, show_col_types = FALSE)

message("Using descriptions from: ", desc_path)

# Helper: convert a raw "x"/NA (or blank) character flag to integer 0/1.
.to_flag <- function(x) {
  if (is.numeric(x) || is.integer(x)) return(as.integer(!is.na(x) & x != 0L))
  as.integer(!is.na(x) & grepl("^\\s*x\\s*$", as.character(x), ignore.case = TRUE))
}

# ---- identify and convert topic columns to binary ----
names(descriptions_df)[names(descriptions_df) == "topic_safety"] <- "topic_security"
topic_cols <- grep("(?i)^topic", names(descriptions_df), value = TRUE)
message("Detected ", length(topic_cols), " topic columns.")
if (length(topic_cols) > 0) {
  descriptions_df <- descriptions_df %>%
    mutate(across(all_of(topic_cols), .to_flag))
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
    ) |> as.Date()),
    in_book           = .to_flag(in_book),
    in_online_archive = .to_flag(in_online_archive),
    original_id       = as.character(original_n)
  ) %>%
  select(n, original_id, date, in_book, in_online_archive, type, summary, speakers, all_of(topic_cols)) %>%
  filter(!is.na(n))

# ======================================================================
# MODIFIED SECTION: Handle wide-format "speakers per transcript.csv"
# ======================================================================

message("Loading wide-format 'speakers per transcript.csv'...")

speakers_candidates <- c(
  Sys.getenv("SPEAKERS_CSV", unset = NA),
  "data-raw/Inventory & Descriptions/speakers per transcript.csv",
  "data-raw/speakers per transcript.csv"
) |> unique()
speakers_candidates <- speakers_candidates[!is.na(speakers_candidates)]
speakers_path <- speakers_candidates[file_exists(speakers_candidates)][1]

if (is.na(speakers_path)) {
  stop("The file 'speakers per transcript.csv' was not found. Checked: ",
       paste(speakers_candidates, collapse = " | "))
}

speakers_df <- read_csv(speakers_path, show_col_types = FALSE)
names(speakers_df) <- gsub("speakrer_std_", "speaker_std_", names(speakers_df), fixed = TRUE)

# Identify all speaker columns
speaker_cols <- grep("^speaker_std_", names(speakers_df), value = TRUE)
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
    n      = suppressWarnings(as.integer(tools::file_path_sans_ext(path_file(file_abs)))),
    file   = path_file(file_abs),
    format = tolower(tools::file_ext(file_abs))
  ) %>%
  select(n, file, format) %>%
  left_join(metadata_df, by = "n") %>%
  left_join(speaker_matrix, by = "n") %>%
  arrange(n)

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
    n_topics   = if (length(topic_cols_present) > 0)
      rowSums(across(all_of(topic_cols_present)), na.rm = TRUE) else NA_integer_,
    n_speakers = if (length(speaker_cols_present) > 0)
      rowSums(across(all_of(speaker_cols_present)), na.rm = TRUE) else NA_integer_
  )

# ---- reorder columns and rename n -> id ----
# Descriptive columns first, then speaker/topic counts, then the speaker_*
# and topic_* boolean (1/0) indicator columns used for filtering.
.desc_cols <- intersect(
  c("n", "file", "format", "date", "original_id", "in_book",
    "in_online_archive", "type", "summary", "speakers"),
  names(transcript_index)
)
.cnt_cols <- intersect(c("n_speakers", "n_topics"), names(transcript_index))
.s_cols   <- grep("^speaker_", names(transcript_index), value = TRUE)
.t_cols   <- grep("^topic_",   names(transcript_index), value = TRUE)

transcript_index <- transcript_index %>%
  select(all_of(c(.desc_cols, .cnt_cols, .s_cols, .t_cols))) %>%
  rename(id = n)

# ---- diagnostics ----
if (any(is.na(transcript_index$id))) {
  warning("Non-numeric filenames detected; some `id` values are NA.")
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
