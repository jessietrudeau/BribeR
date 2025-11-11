# ============================================================
# GENERATE DATA DICTIONARY AND OPEN IT IN BROWSER AS HTML
# ============================================================

#' Generate the BribeRdata Data Dictionary (Development)
#'
#' This function compiles metadata for all `.rda` files located in
#' `/Users/andressoto/Documents/BribeRdata/data`, saves the result as
#' `data_dictionary_master.csv`, converts it into an interactive
#' HTML table, and opens that file in your default web browser.
#'
#' @return The path to the generated HTML file (invisibly).
#' @export
generate_data_dictionary <- function() {
  # ---- Load required packages ----
  library(dplyr)
  library(purrr)
  library(tibble)
  library(DT)
  library(htmlwidgets)

  # ---- FIXED LOCAL PATH ----
  data_dir <- "/Users/andressoto/Documents/BribeRdata/data"
  output_csv <- file.path(data_dir, "data_dictionary_master.csv")
  output_html <- file.path(data_dir, "data_dictionary_master.html")

  # ---- FUNCTION TO PROCESS EACH .RDA ----
  extract_from_rda <- function(file_path) {
    env <- new.env()
    load(file_path, envir = env)
    obj_names <- ls(envir = env)

    purrr::map_dfr(obj_names, function(obj_name) {
      df <- get(obj_name, envir = env)
      # Skip non-data-frame objects
      if (!is.data.frame(df) && !tibble::is_tibble(df)) return(tibble())

      tibble(
        file_name = basename(file_path),
        object_name = obj_name,
        column_name = names(df),
        data_type = sapply(df, function(x) class(x)[1]),
        example_value = sapply(df, function(x) paste0(utils::head(x, 1), collapse = ", ")),
        missing_values = sapply(df, function(x) sum(is.na(x))),
        total_rows = nrow(df),
        description = NA_character_
      )
    })
  }

  # ---- MAIN PROCESS ----
  rda_files <- list.files(data_dir, pattern = "\\.rda$", full.names = TRUE)

  if (length(rda_files) == 0) {
    stop("No .rda files found in: ", data_dir)
  }

  message("🔍 Processing the following .rda files:")
  print(basename(rda_files))

  data_dictionary <- purrr::map_dfr(rda_files, extract_from_rda)

  # ---- SAVE AS CSV ----
  write.csv(data_dictionary, output_csv, row.names = FALSE)

  # ---- CONVERT TO INTERACTIVE HTML TABLE ----
  datatable(data_dictionary, options = list(pageLength = 25, scrollX = TRUE)) %>%
    saveWidget(output_html, selfcontained = TRUE)

  # ---- OPEN HTML FILE IN BROWSER ----
  browseURL(output_html)

  # ---- CONFIRMATION ----
  message("Data dictionary successfully created and opened in browser!")
  message("CSV:  ", output_csv)
  message("HTML: ", output_html)

  invisible(output_html)
}
