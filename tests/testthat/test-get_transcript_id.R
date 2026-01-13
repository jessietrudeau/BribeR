
test_that("get_transcript_id returns sorted numeric transcript IDs from local data-raw", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("data-raw/transcripts", recursive = TRUE)

  # Create fake transcript files
  file.create(
    file.path("data-raw/transcripts", c("10.csv", "2.csv", "1.csv"))
  )

  ids <- get_transcript_id(package = "nonexistent_package")

  expect_type(ids, "double")
  expect_equal(ids, c(1, 2, 10))
})

test_that("get_transcript_id ignores non-numeric filenames", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("data-raw/transcripts", recursive = TRUE)

  file.create(
    file.path("data-raw/transcripts", c("1.csv", "abc.csv", "2.csv"))
  )

  ids <- get_transcript_id(package = "nonexistent_package")

  expect_equal(ids, c(1, 2))
})

test_that("get_transcript_id errors if transcript directory not found", {
  old_wd <- getwd()
  tmpdir <- tempfile("briber_")
  dir.create(tmpdir, recursive = TRUE)
  setwd(tmpdir)
  on.exit(setwd(old_wd), add = TRUE)

  expect_error(
    get_transcript_id(package = "nonexistent_package"),
    "Transcript directory not found",
    fixed = FALSE
  )
})


