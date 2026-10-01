# Copies the data run_transcript_network_app() depends on into this folder as
# plain .rds files, so app.R can be a self-contained Shiny app with no
# dependency on bribeR being installed (shinylive/webR can only install
# packages from a wasm repository, and bribeR is not published to one).
#
# Re-run this after any change to data/*.rda, inst/data-raw/transcripts/, or
# inst/images/montesinos.PNG.

app_dir <- "data-raw/shinylive-app"

DATASETS <- c("transcript_index", "speakers_per_transcript",
              "topic_descriptions", "speakers")

for (nm in DATASETS) {
  load(file.path("data", paste0(nm, ".rda")))
  saveRDS(get(nm), file.path(app_dir, paste0(nm, ".rds")))
}

# Drop any .rds left over from a dataset that is no longer copied, so the app
# folder holds exactly the datasets listed above.
stale_rds <- setdiff(
  basename(list.files(app_dir, pattern = "\\.rds$")),
  paste0(DATASETS, ".rds")
)
if (length(stale_rds)) {
  invisible(file.remove(file.path(app_dir, stale_rds)))
  message("Removed stale .rds: ", paste(stale_rds, collapse = ", "))
}

# Clear the transcript copies before recopying. Overwriting alone would leave
# behind files whose transcript number no longer exists, and the app would then
# read two numbering schemes at once.
old_csv <- list.files(file.path(app_dir, "transcripts"), pattern = "\\.csv$",
                      full.names = TRUE)
if (length(old_csv)) invisible(file.remove(old_csv))

invisible(file.copy(
  list.files("inst/data-raw/transcripts", pattern = "\\.csv$", full.names = TRUE),
  file.path(app_dir, "transcripts"),
  overwrite = TRUE
))

invisible(file.copy(
  "inst/images/montesinos.PNG",
  file.path(app_dir, "www", "montesinos.PNG"),
  overwrite = TRUE
))

message(sprintf("Copied %d datasets, %d transcripts and the Montesinos image.",
                length(DATASETS),
                length(list.files(file.path(app_dir, "transcripts"), pattern = "\\.csv$"))))
