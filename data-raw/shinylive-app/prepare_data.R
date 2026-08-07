# Copies the data run_transcript_network_app() depends on into this folder as
# plain .rds/files, so app.R can be a self-contained Shiny app with no
# dependency on BribeR being installed (shinylive/webR can't install
# unpublished packages). Re-run this after any change to data/*.rda,
# inst/data-raw/transcripts/, or inst/images/montesinos.PNG.

app_dir <- "data-raw/shinylive-app"

for (nm in c("transcript_index", "speakers_per_transcript", "topic_descriptions", "actors")) {
  load(file.path("data", paste0(nm, ".rda")))
  saveRDS(get(nm), file.path(app_dir, paste0(nm, ".rds")))
}

file.copy(
  list.files("inst/data-raw/transcripts", pattern = "\\.csv$", full.names = TRUE),
  file.path(app_dir, "transcripts"),
  overwrite = TRUE
)

file.copy(
  "inst/images/montesinos.PNG",
  file.path(app_dir, "www", "montesinos.PNG"),
  overwrite = TRUE
)
