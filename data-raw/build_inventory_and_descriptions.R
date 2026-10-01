# data-raw/build_inventory_and_descriptions.R
#
# Turns the hand-maintained CSVs in "data-raw/Inventory & Descriptions" into
# the package datasets, derives the speaker roster from the dialogue, and
# checks that every listed speaker is recorded speaking.
#
# Run build_transcripts_detailed.R first: the roster and the check both read
# data/compiled_transcripts.rda.

# ---- setup ----
required_pkgs <- c("readr", "fs", "stringi")
to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
library(readr)
if (!requireNamespace("fs", quietly = TRUE)) library(fs)

# ---- config ----
INPUT_DIR  <- file.path("data-raw", "Inventory & Descriptions")
OUTPUT_DIR <- "data"

# Column renames applied after reading, per dataset.
RENAME_COLS <- list(
  "speakers" = c("Position" = "position", "Type" = "type", "Party" = "party")
)

# Columns whose values are lowercased, per dataset. Speaker identifier columns
# are lowercased for every dataset and do not need listing here.
LOWERCASE_VALUE_COLS <- list(
  "speakers" = c("type")
)

# Descriptions.csv is folded into `transcript_index` by build_transcript_index.R
# rather than shipped on its own, so no .rda is written for it.
EXCLUDE_OBJECTS <- c("descriptions")

# ---- helpers ----
# A CSV becomes a dataset named after its file: lowercased, with runs of
# non-alphanumeric characters collapsed to single underscores.
.clean_object_name <- function(fname) {
  base <- tools::file_path_sans_ext(basename(fname))
  nm <- tolower(base)
  nm <- gsub("[^a-z0-9]+", "_", nm)
  nm <- gsub("_+", "_", nm)
  nm <- sub("^_", "", nm)
  nm <- sub("_$", "", nm)
  if (!grepl("^[a-z]", nm)) nm <- paste0("x_", nm)
  nm
}

.save_one_csv_as_rda <- function(csv_path, object_name, out_dir = OUTPUT_DIR) {
  df <- readr::read_csv(csv_path, show_col_types = FALSE, progress = FALSE)

  if (!is.null(RENAME_COLS[[object_name]])) {
    mapping <- RENAME_COLS[[object_name]]
    for (i in seq_along(mapping)) names(df)[names(df) == names(mapping)[i]] <- mapping[i]
  }

  # Lowercase speaker identifiers after the renames, so the column names match.
  speaker_val_cols <- grep("^speaker$|^speaker_std(_[0-9]+)?$", names(df),
                           value = TRUE, perl = TRUE)
  for (col in speaker_val_cols) df[[col]] <- tolower(df[[col]])

  if (!is.null(LOWERCASE_VALUE_COLS[[object_name]])) {
    for (col in LOWERCASE_VALUE_COLS[[object_name]]) df[[col]] <- tolower(df[[col]])
  }

  if (!fs::dir_exists(out_dir)) fs::dir_create(out_dir, recurse = TRUE)

  # assign into this environment so save() writes the object under the name we want
  assign(object_name, df, envir = environment())
  out_path <- file.path(out_dir, paste0(object_name, ".rda"))
  save(list = object_name, file = out_path, compress = "xz")
  message(sprintf("Saved %-30s <- %s", paste0(object_name, ".rda"), fs::path_file(csv_path)))
}

.norm_speaker <- function(x) {
  stringi::stri_trans_general(tolower(trimws(as.character(x))), "Latin-ASCII")
}

# ---- write one dataset per CSV ----
if (!fs::dir_exists(INPUT_DIR)) {
  stop(sprintf("Input directory not found: %s", INPUT_DIR))
}

csv_paths <- fs::dir_ls(INPUT_DIR, regexp = "\\.csv$", type = "file", recurse = FALSE)
if (length(csv_paths) == 0L) stop(sprintf("No CSV files found in %s", INPUT_DIR))

object_names <- make.unique(
  vapply(csv_paths, function(p) .clean_object_name(fs::path_file(p)), character(1)),
  sep = "_"
)

keep <- !object_names %in% EXCLUDE_OBJECTS
csv_paths    <- csv_paths[keep]
object_names <- object_names[keep]

print(data.frame(file = fs::path_file(csv_paths), object = object_names,
                 stringsAsFactors = FALSE), row.names = FALSE)

invisible(mapply(.save_one_csv_as_rda, csv_paths, object_names))
message(sprintf("Done. %d datasets written to '%s/'.", length(csv_paths), OUTPUT_DIR))

# ---- speakers per transcript, derived from the dialogue ----
# A speaker is anyone with at least one turn in the transcript, so the roster
# is computed rather than maintained by hand. Speakers appear in the order
# they first speak. "background" carries stage directions and is excluded.
CT_PATH <- file.path(OUTPUT_DIR, "compiled_transcripts.rda")
if (!file.exists(CT_PATH)) {
  stop("compiled_transcripts.rda not found. Run build_transcripts_detailed.R first.")
}
load(CT_PATH)

.roster_for <- function(i) {
  v <- trimws(compiled_transcripts$speaker_std[compiled_transcripts$id == i])
  v <- v[!is.na(v) & nzchar(v) & v != "background"]
  unique(v)
}
ids   <- sort(unique(compiled_transcripts$id))
lists <- lapply(ids, .roster_for)
width <- max(lengths(lists))
mat   <- t(vapply(lists, function(v) c(v, rep(NA_character_, width - length(v))),
                  character(width)))
colnames(mat) <- paste0("speaker_std_", seq_len(width))
speakers_per_transcript <- tibble::as_tibble(
  cbind(data.frame(id = as.numeric(ids)), as.data.frame(mat, stringsAsFactors = FALSE))
)
save(speakers_per_transcript,
     file = file.path(OUTPUT_DIR, "speakers_per_transcript.rda"), compress = "xz")
message(sprintf("Derived speakers_per_transcript: %d transcripts, %d speaker slots, %d entries.",
                nrow(speakers_per_transcript), width, sum(lengths(lists))))

# ---- verify every listed speaker is recorded speaking ----
# Every speaker_std in `speakers` must appear at least once in the dialogue.
# compiled_transcripts already stores speaker_std lowercased and stripped of
# diacritics; the roster side is normalised to match.
speaking <- unique(trimws(compiled_transcripts$speaker_std))
speaking <- speaking[!is.na(speaking) & nzchar(speaking)]

load(file.path(OUTPUT_DIR, "speakers.rda"))
silent <- speakers$speaker_std[!.norm_speaker(speakers$speaker_std) %in% speaking]
if (length(silent) > 0) {
  stop(sprintf("speakers.csv lists %d individual(s) who never speak: %s",
               length(silent), paste(silent, collapse = ", ")))
}

message(sprintf("All %d listed speakers are recorded speaking.", nrow(speakers)))
