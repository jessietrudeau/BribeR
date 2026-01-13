
# ---- setup ----
required_pkgs <- c("dplyr", "readr", "stringr", "purrr")
to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")

library(dplyr)
library(readr)
library(stringr)
library(purrr)

# ---- define paths ----
transcript_dir <- "data-raw/transcripts"
descriptions_path <- "data-raw/Inventory & Descriptions/Descriptions.csv"
output_path <- "data/vladivideos_detailed.rda"  # you can rename this

# ---- read descriptions ----
descriptions <- read_csv(descriptions_path, show_col_types = FALSE)

# identify all columns that start with "topic_"
topic_cols <- grep("^topic_", names(descriptions), value = TRUE)

# for each row, concatenate the *column names* where the value == "x"
descriptions <- descriptions %>%
  rowwise() %>%
  mutate(topic = paste(
    topic_cols[which(c_across(all_of(topic_cols)) == "x")],
    collapse = ", "
  )) %>%
  ungroup() %>%
  select(n, date, topic)

# ---- read transcripts ----
transcript_files <- list.files(transcript_dir, pattern = "\\.csv$", full.names = TRUE)

read_single_transcript <- function(file_path) {
  data <- read_csv(file_path, show_col_types = FALSE)
  n_value <- as.numeric(str_remove(basename(file_path), "\\.csv$"))
  
  data %>%
    mutate(
      n = n_value,
      row_id = row_number()
    )
}

all_transcripts <- map_dfr(transcript_files, read_single_transcript)

# ---- merge topic and date info ----
compiled_transcripts <- all_transcripts %>%
  left_join(descriptions, by = "n")

# ---- save as RDA ----
if (!dir.exists("data")) dir.create("data")
save(compiled_transcripts, file = output_path)

message("✅ Compiled RDA saved at: ", output_path)

















