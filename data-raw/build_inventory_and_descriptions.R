# data-raw/build_inventory_descriptions.R
# ---- setup ----
required_pkgs <- c("readr", "fs")
to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
library(readr)
if (!requireNamespace("fs", quietly = TRUE)) library(fs)

# ---- config ----
INPUT_DIR  <- file.path("data-raw", "Inventory & Descriptions")
OUTPUT_DIR <- "data"

# (Optional) Override names here if you want custom dataset names:
# e.g., c("Descriptions.csv" = "descriptions", "speakers per transcript.csv" = "speakers_per_transcript")
OVERRIDE_NAMES <- c(
  # "Descriptions.csv"               = "descriptions",
  # "speakers per transcript.csv"    = "speakers_per_transcript",
  # "Topic Descriptions.csv"         = "topic_descriptions",
  # "Actors.csv"                     = "actors"
)

# (Optional) Columns to drop per object name after reading:
DROP_COLS <- list()

# (Optional) Rename columns per object (old_name = new_name):
RENAME_COLS <- list(
  "speakers_per_transcript" = c("n" = "id"),
  "actors"                  = c("Position" = "position", "Type" = "type", "Party" = "party")
)

# (Optional) Replace a value in a specific column per object. Each object
# maps to a list of one or more list(col=, old=, new=) substitutions:
RENAME_VALUES <- list(
  "topic_descriptions" = list(list(col = "topics", old = "topic_safety", new = "topic_security")),
  "actors"              = list(list(col = "type", old = "Illict", new = "Illicit"))
)

# (Optional) Pattern-based column rename per object (fixed string, not regex):
RENAME_COL_PATTERNS <- list(
  "speakers_per_transcript" = c("speakrer_std_" = "speaker_std_")
)

# (Optional) Convert "x"/NA indicator columns to integer 0/1 per object.
# Column names are matched by regex pattern. Any value matching /^\s*x\s*$/i
# becomes 1L; NA or anything else becomes 0L.
CONVERT_BINARY_COLS <- list()

# (Optional) Columns whose string values should be lowercased per object:
LOWERCASE_VALUE_COLS <- list(
  "actors" = c("type")
)

# ---- helpers ----
.clean_object_name <- function(fname) {
  # strip extension, lower, replace non-alnum with underscores, collapse repeats,
  # trim leading/trailing underscores, and ensure leading letter
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
  if (!is.null(DROP_COLS[[object_name]])) df <- df[, !names(df) %in% DROP_COLS[[object_name]], drop = FALSE]
  if (!is.null(RENAME_COLS[[object_name]])) {
    mapping <- RENAME_COLS[[object_name]]
    for (i in seq_along(mapping)) names(df)[names(df) == names(mapping)[i]] <- mapping[i]
  }
  if (!is.null(RENAME_VALUES[[object_name]])) {
    for (rv in RENAME_VALUES[[object_name]]) {
      df[[rv$col]][df[[rv$col]] == rv$old] <- rv$new
    }
  }
  if (!is.null(RENAME_COL_PATTERNS[[object_name]])) {
    patterns <- RENAME_COL_PATTERNS[[object_name]]
    for (i in seq_along(patterns)) names(df) <- gsub(names(patterns)[i], patterns[i], names(df), fixed = TRUE)
  }
  # Lowercase speaker identifier values after all column renames have been applied.
  speaker_val_cols <- grep("^speaker$|^speaker_std(_[0-9]+)?$", names(df), value = TRUE, perl = TRUE)
  for (col in speaker_val_cols) df[[col]] <- tolower(df[[col]])
  if (!is.null(LOWERCASE_VALUE_COLS[[object_name]])) {
    for (col in LOWERCASE_VALUE_COLS[[object_name]]) df[[col]] <- tolower(df[[col]])
  }
  if (!is.null(CONVERT_BINARY_COLS[[object_name]])) {
    hit_cols <- unique(unlist(lapply(
      CONVERT_BINARY_COLS[[object_name]],
      function(p) grep(p, names(df), value = TRUE, perl = TRUE)
    )))
    for (col in hit_cols) {
      raw <- df[[col]]
      df[[col]] <- ifelse(!is.na(raw) & grepl("^\\s*x\\s*$", raw, ignore.case = TRUE), 1L, 0L)
    }
  }
  if (!fs::dir_exists(out_dir)) fs::dir_create(out_dir, recurse = TRUE)

  # assign into current environment so save() captures the desired symbol name
  assign(object_name, df, envir = environment())
  out_path <- file.path(out_dir, paste0(object_name, ".rda"))
  save(list = object_name, file = out_path, compress = "xz")
  message(sprintf("Saved %-30s <- %s", paste0(object_name, ".rda"), fs::path_file(csv_path)))
}

# ---- build ----
if (!fs::dir_exists(INPUT_DIR)) {
  stop(sprintf("Input directory not found: %s", INPUT_DIR))
}

csv_paths <- fs::dir_ls(INPUT_DIR, regexp = "\\.csv$", type = "file", recurse = FALSE)
if (length(csv_paths) == 0L) stop(sprintf("No CSV files found in %s", INPUT_DIR))

# derive object names (with optional overrides)
proposed_names <- vapply(csv_paths, function(p) {
  f <- fs::path_file(p)
  if (!is.null(OVERRIDE_NAMES[[f]])) {
    OVERRIDE_NAMES[[f]]
  } else {
    .clean_object_name(f)
  }
}, character(1))

# ensure uniqueness if two files clean to the same name
object_names <- make.unique(proposed_names, sep = "_")

# Datasets intentionally not produced as standalone .rda files. "descriptions"
# is folded directly into `transcript_index` by build_transcript_index.R
# instead of being shipped as its own dataset.
EXCLUDE_OBJECTS <- c("descriptions")
keep <- !object_names %in% EXCLUDE_OBJECTS
csv_paths    <- csv_paths[keep]
object_names <- object_names[keep]

# show mapping
mapping <- data.frame(
  file = fs::path_file(csv_paths),
  object = object_names,
  stringsAsFactors = FALSE
)
print(mapping, row.names = FALSE)

# save each CSV as its own .rda
invisible(mapply(.save_one_csv_as_rda, csv_paths, object_names))
message(sprintf("Done. %d datasets written to '%s/'.", length(csv_paths), OUTPUT_DIR))


