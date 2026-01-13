# data-raw/build_inventory_descriptions.R

# ---- setup ----
required_pkgs <- c("readr", "fs")
to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")

library(readr)
library(fs)

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
  if (!dir_exists(out_dir)) dir_create(out_dir, recurse = TRUE)
  
  # assign into current environment so save() captures the desired symbol name
  assign(object_name, df, envir = environment())
  out_path <- file.path(out_dir, paste0(object_name, ".rda"))
  save(list = object_name, file = out_path, compress = "xz")
  message(sprintf("Saved %-30s <- %s", paste0(object_name, ".rda"), path_file(csv_path)))
}

# ---- build ----
if (!dir_exists(INPUT_DIR)) {
  stop(sprintf("Input directory not found: %s", INPUT_DIR))
}

csv_paths <- dir_ls(INPUT_DIR, regexp = "\\.csv$", type = "file", recurse = FALSE)
if (length(csv_paths) == 0L) stop(sprintf("No CSV files found in %s", INPUT_DIR))

# derive object names (with optional overrides)
proposed_names <- vapply(csv_paths, function(p) {
  f <- path_file(p)
  if (!is.null(OVERRIDE_NAMES[[f]])) {
    OVERRIDE_NAMES[[f]]
  } else {
    .clean_object_name(f)
  }
}, character(1))

# ensure uniqueness if two files clean to the same name
object_names <- make.unique(proposed_names, sep = "_")

# show mapping
mapping <- data.frame(
  file = path_file(csv_paths),
  object = object_names,
  stringsAsFactors = FALSE
)
print(mapping, row.names = FALSE)

# save each CSV as its own .rda
invisible(mapply(.save_one_csv_as_rda, csv_paths, object_names))
message(sprintf("Done. %d datasets written to '%s/'.", length(csv_paths), OUTPUT_DIR))
