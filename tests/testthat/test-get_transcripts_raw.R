
test_that("get_transcripts_raw loads all transcripts as a named list", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("data-raw/transcripts", recursive = TRUE)

  # Minimal transcript files
  readr::write_csv(data.frame(speaker = "A", speech = "hi"), "data-raw/transcripts/1.csv")
  readr::write_csv(data.frame(speaker = "B", speech = "hello"), "data-raw/transcripts/2.csv")

  out <- get_transcripts_raw(package = "nonexistent_package") # force fallback path

  expect_type(out, "list")
  expect_named(out, c("1", "2"))

  expect_s3_class(out[["1"]], "data.frame")
  expect_true(all(c("speaker", "speech") %in% names(out[["1"]])))
})

test_that("get_transcripts_raw filters by n", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("data-raw/transcripts", recursive = TRUE)

  readr::write_csv(data.frame(speaker = "A", speech = "hi"), "data-raw/transcripts/1.csv")
  readr::write_csv(data.frame(speaker = "B", speech = "hello"), "data-raw/transcripts/2.csv")

  out <- get_transcripts_raw(n = 2, package = "nonexistent_package")

  expect_named(out, "2")
  expect_equal(nrow(out[["2"]]), 1)
  expect_equal(out[["2"]]$speaker[[1]], "B")
})

test_that("get_transcripts_raw errors if n does not exist", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("data-raw/transcripts", recursive = TRUE)
  readr::write_csv(data.frame(speaker = "A", speech = "hi"), "data-raw/transcripts/1.csv")

  expect_error(
    get_transcripts_raw(n = 999, package = "nonexistent_package"),
    "No matching transcripts found",
    fixed = FALSE
  )
})

test_that("get_transcripts_raw combine=TRUE returns a tibble with n column", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("data-raw/transcripts", recursive = TRUE)

  readr::write_csv(data.frame(speaker = "A", speech = "one two"), "data-raw/transcripts/1.csv")
  readr::write_csv(data.frame(speaker = "B", speech = "three four"), "data-raw/transcripts/2.csv")

  combined <- get_transcripts_raw(combine = TRUE, package = "nonexistent_package")

  expect_s3_class(combined, "data.frame")
  expect_true(all(c("n", "speaker", "speech") %in% names(combined)))
  expect_true(is.integer(combined$n) || is.numeric(combined$n))
  expect_equal(sort(unique(combined$n)), c(1, 2))
})

test_that("get_transcripts_raw errors if transcript directory not found", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  expect_error(
    get_transcripts_raw(package = "nonexistent_package"),
    "Transcript directory not found",
    fixed = FALSE
  )
})

test_that("get_transcripts_raw errors if directory exists but has no csv files", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("data-raw/transcripts", recursive = TRUE)

  expect_error(
    get_transcripts_raw(package = "nonexistent_package"),
    "No transcript .csv files found",
    fixed = FALSE
  )
})




