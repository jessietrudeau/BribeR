# R/run_transcript_network_app.R and data-raw/shinylive-app/app.R hold the same
# UI and server. The second cannot call library(bribeR), because shinylive runs
# R in the browser and can only install packages from a wasm repository, so the
# logic is written out twice and the two can drift apart.
#
# This compares them from the UI definition onwards, which is everything except
# the setup each one needs: the package version wraps its body in a function and
# reads its data with utils::data() and system.file(), while the standalone
# version calls library() and readRDS() against files beside it.
#
# data-raw/ is excluded from the built package, so this skips during R CMD check
# and runs from the source tree under devtools::test().

normalise <- function(path) {
  lines <- readLines(path, warn = FALSE)
  lines <- sub("(?<![\"'])#.*$", "", lines, perl = TRUE)   # drop comments
  lines <- gsub("\\b[a-zA-Z][a-zA-Z0-9.]*::", "", lines)   # drop pkg:: prefixes
  lines <- trimws(gsub("[[:space:]]+", " ", lines))
  lines[nzchar(lines)]
}

shared_body <- function(path) {
  x <- normalise(path)
  start <- match("ui <- fluidPage(", x)
  stop  <- match("shinyApp(ui = ui, server = server)", x)
  if (is.na(start) || is.na(stop)) {
    stop("could not locate the shared body in ", path, call. = FALSE)
  }
  x[start:stop]
}

test_that("the shinylive app and the package function have not drifted apart", {
  pkg_file <- testthat::test_path("..", "..", "R", "run_transcript_network_app.R")
  app_file <- testthat::test_path("..", "..", "data-raw", "shinylive-app", "app.R")
  skip_if_not(file.exists(pkg_file) && file.exists(app_file),
              "source tree not available")

  pkg <- shared_body(pkg_file)
  app <- shared_body(app_file)

  only_pkg <- setdiff(pkg, app)
  only_app <- setdiff(app, pkg)
  expect_equal(
    length(only_pkg) + length(only_app), 0,
    info = paste0(
      "The two copies of the app have diverged. Make the same change in both.\n",
      if (length(only_pkg)) paste0("Only in the package function:\n  ",
                                   paste(only_pkg, collapse = "\n  "), "\n"),
      if (length(only_app)) paste0("Only in the shinylive app:\n  ",
                                   paste(only_app, collapse = "\n  "))
    )
  )
  expect_identical(pkg, app)
})
