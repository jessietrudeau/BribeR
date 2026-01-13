# ============================================================
#  Generate BribeRdata Data Dictionary (Standalone Script)
#  Avoids redundant transcript metadata by reading only 1 CSV.
# ============================================================

library(dplyr)
library(purrr)
library(tibble)
library(readr)
library(DT)
library(htmlwidgets)
library(stringr)

# ---- Paths ----
base_raw <- "data-raw"

inventory_dir   <- file.path(base_raw, "Inventory & Descriptions")
transcripts_dir <- file.path(base_raw, "transcripts")

output_csv  <- "data/data_dictionary_master.csv"
output_html <- "data/data_dictionary_master.html"


# ---- List CSVs ----
inventory_csvs <- list.files(inventory_dir, pattern = "\\.csv$", full.names = TRUE)
transcript_csvs <- list.files(transcripts_dir, pattern = "\\.csv$", full.names = TRUE)

if (length(inventory_csvs) + length(transcript_csvs) == 0) {
  stop("⚠️ No CSV files found in Inventory or Transcripts folders.")
}

message("📦 Inventory files:")
print(basename(inventory_csvs))

message("📄 Transcript files detected:")
print(basename(transcript_csvs))


# ---- Helper: First non-empty value ----
first_nonempty <- function(x) {
  x <- as.character(x)
  valid <- which(!is.na(x) & x != "" & !str_detect(x, "^\\s*$"))
  if (length(valid) == 0) return(NA_character_)
  return(x[valid[1]])
}


# ---- Extract metadata from a single CSV ----
extract_from_csv <- function(file_path, override_filename = NULL) {
  df <- suppressMessages(readr::read_csv(file_path, show_col_types = FALSE))
  
  tibble(
    file_name = if (!is.null(override_filename)) override_filename else basename(file_path),
    column_name = names(df),
    data_type = sapply(df, function(x) class(x)[1]),
    example_value = sapply(df, first_nonempty),
    missing_values = sapply(df, function(x) sum(is.na(x))),
    total_rows = nrow(df),
    description = NA_character_
  )
}


# ============================================================
#  MAIN PROCESS
# ============================================================

# ---- Process Inventory & Description files (ALL) ----
inventory_dict <- purrr::map_dfr(inventory_csvs, extract_from_csv)


# ---- Process Transcript files (ONLY FIRST CSV) ----
if (length(transcript_csvs) > 0) {
  
  message("🔍 Transcript CSVs share identical schema. Using only the first file:")
  print(basename(transcript_csvs[1]))
  
  transcript_dict <- extract_from_csv(
    file_path = transcript_csvs[1],
    override_filename = "transcripts/*.csv (shared schema)"
  )
  
} else {
  transcript_dict <- tibble()
}


# ---- Combine dictionary ----
data_dictionary <- bind_rows(inventory_dict, transcript_dict)


# ---- Ensure output folder ----
if (!dir.exists("data")) dir.create("data")


# ---- Save CSV ----
write.csv(data_dictionary, output_csv, row.names = FALSE)
message("✔️ Saved CSV to:  ", output_csv)


# ---- Save HTML ----
datatable(
  data_dictionary,
  options = list(pageLength = 25, scrollX = TRUE)
) %>%
  saveWidget(output_html, selfcontained = TRUE)

message("Saved HTML to: ", output_html)


message("Data dictionary generation complete.")
