test_that("read_transcripts errors on missing/empty path", {
  expect_error(read_transcripts(), "Please provide", fixed = FALSE)
  expect_error(read_transcripts(""), "Please provide", fixed = FALSE)
})

test_that("read_transcripts loads a local .rda with exactly one object", {
  tmp <- tempfile(fileext = ".rda")

  df <- data.frame(
    n = c(1, 1, 2),
    row_id = c(1, 2, 1),
    speaker = c("A", "B", "A"),
    speech = c("hi", "hello", "yo"),
    speaker_std = c("a", "b", "a"),
    stringsAsFactors = FALSE
  )

  save(df, file = tmp)

  out <- read_transcripts(tmp)

  expect_s3_class(out, "data.frame")
  expect_true(all(c("n", "row_id", "speaker", "speech", "speaker_std") %in% names(out)))
  expect_equal(nrow(out), 3)
})

test_that("read_transcripts warns if expected columns are missing", {
  tmp <- tempfile(fileext = ".rda")

  df_missing <- data.frame(
    n = c(1, 2),
    speech = c("x", "y"),
    stringsAsFactors = FALSE
  )

  save(df_missing, file = tmp)

  expect_warning(
    out <- read_transcripts(tmp),
    "expected columns are missing",
    fixed = FALSE
  )

  expect_s3_class(out, "data.frame")
  expect_true(all(c("n", "speech") %in% names(out)))
})

test_that("read_transcripts errors if .rda contains multiple objects", {
  tmp <- tempfile(fileext = ".rda")

  a <- data.frame(x = 1)
  b <- data.frame(y = 2)
  save(a, b, file = tmp)

  expect_error(
    read_transcripts(tmp),
    "exactly one object",
    fixed = FALSE
  )
})

test_that("read_transcripts filters by transcript IDs when provided", {
  tmp <- tempfile(fileext = ".rda")

  df <- data.frame(
    n = c(1, 1, 2, 3),
    row_id = 1:4,
    speaker = c("A", "B", "C", "D"),
    speech = c("s1", "s2", "s3", "s4"),
    speaker_std = c("a", "b", "c", "d"),
    stringsAsFactors = FALSE
  )

  save(df, file = tmp)

  out <- read_transcripts(tmp, transcripts = c(1, 3))

  expect_equal(sort(unique(out$n)), c(1, 3))
  expect_equal(nrow(out), 3)
})

test_that("read_transcripts warns when filter returns no rows", {
  tmp <- tempfile(fileext = ".rda")

  df <- data.frame(
    n = c(1, 1),
    row_id = 1:2,
    speaker = c("A", "B"),
    speech = c("s1", "s2"),
    speaker_std = c("a", "b"),
    stringsAsFactors = FALSE
  )

  save(df, file = tmp)

  expect_warning(
    out <- read_transcripts(tmp, transcripts = 999),
    "No transcripts found matching IDs",
    fixed = FALSE
  )

  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 0)
})

test_that("read_transcripts errors if filtering requested but column n is missing", {
  tmp <- tempfile(fileext = ".rda")

  df_no_n <- data.frame(
    row_id = 1:2,
    speaker = c("A", "B"),
    speech = c("s1", "s2"),
    speaker_std = c("a", "b"),
    stringsAsFactors = FALSE
  )

  save(df_no_n, file = tmp)

  expect_error(
    read_transcripts(tmp, transcripts = 1),
    "Column 'n' not found",
    fixed = FALSE
  )
})

