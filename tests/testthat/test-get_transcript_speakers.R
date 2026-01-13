test_that("get_transcript_speakers returns one row per transcript with list-column speakers", {
  tmpdir <- tempfile("briber_speakers_")
  dir.create(tmpdir, recursive = TRUE)

  fp <- file.path(tmpdir, "speakers per transcript.csv")

  # Wide format mimicking your real file (misspelling included)
  df <- data.frame(
    n = c(1, 2, 3),
    speakrer_std_1 = c("MONTESINOS", "FUJIMORI", NA),
    speakrer_std_2 = c("  MONTESINOS  ", "ADVISOR", ""),
    speakrer_std_3 = c("", "FUJIMORI", "BACKGROUND"),
    stringsAsFactors = FALSE
  )

  readr::write_csv(df, fp)

  out <- get_transcript_speakers(path = fp)

  expect_s3_class(out, "tbl_df")
  expect_equal(names(out), c("n", "speakers"))
  expect_equal(out$n, c("1", "2", "3"))

  # Row 1: duplicates + whitespace => unique, trimmed, sorted
  expect_equal(out$speakers[[1]], c("MONTESINOS"))

  # Row 2: includes duplicate FUJIMORI, plus ADVISOR => sorted unique
  expect_equal(out$speakers[[2]], c("ADVISOR", "FUJIMORI"))

  # Row 3: only BACKGROUND (others empty/NA)
  expect_equal(out$speakers[[3]], c("BACKGROUND"))
})

test_that("get_transcript_speakers errors when file is missing", {
  expect_error(
    get_transcript_speakers(path = tempfile(fileext = ".csv")),
    "file not found|not found",
    fixed = FALSE
  )
})

test_that("get_transcript_speakers errors when 'n' column is missing", {
  tmpdir <- tempfile("briber_speakers_")
  dir.create(tmpdir, recursive = TRUE)

  fp <- file.path(tmpdir, "speakers per transcript.csv")

  df <- data.frame(
    speakrer_std_1 = c("A"),
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, fp)

  expect_error(
    get_transcript_speakers(path = fp),
    "Expected column 'n'",
    fixed = FALSE
  )
})

test_that("get_transcript_speakers errors when no speaker columns are present", {
  tmpdir <- tempfile("briber_speakers_")
  dir.create(tmpdir, recursive = TRUE)

  fp <- file.path(tmpdir, "speakers per transcript.csv")

  df <- data.frame(
    n = c(1, 2),
    other = c("x", "y"),
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, fp)

  expect_error(
    get_transcript_speakers(path = fp),
    "No speaker columns found",
    fixed = FALSE
  )
})

test_that("get_transcript_speakers accepts correctly spelled speaker_std_* columns too", {
  tmpdir <- tempfile("briber_speakers_")
  dir.create(tmpdir, recursive = TRUE)

  fp <- file.path(tmpdir, "speakers per transcript.csv")

  df <- data.frame(
    n = c(1),
    speaker_std_1 = c("ALVA"),
    speaker_std_2 = c("  ALVA  "),
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, fp)

  out <- get_transcript_speakers(path = fp)

  expect_equal(out$n, "1")
  expect_equal(out$speakers[[1]], c("ALVA"))
})
