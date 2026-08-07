test_that("read_transcripts returns a data frame with expected columns", {
  result <- read_transcripts()
  expect_s3_class(result, "data.frame")
  expected_cols <- c("id", "row_id", "date", "speaker", "speech", "speaker_std")
  expect_true(all(expected_cols %in% names(result)))
})

test_that("read_transcripts returns non-empty data when called with no arguments", {
  result <- read_transcripts()
  expect_gt(nrow(result), 0)
})

test_that("read_transcripts places n, row_id, date as the first three columns", {
  result <- read_transcripts()
  expect_equal(names(result)[1:3], c("id", "row_id", "date"))
})

test_that("read_transcripts places speaker_std before the speech text column", {
  result <- read_transcripts()
  expect_lt(match("speaker_std", names(result)), match("speech", names(result)))
})

test_that("read_transcripts does not include a topic column", {
  result <- read_transcripts()
  expect_false("topic" %in% names(result))
})

test_that("read_transcripts filters to a single transcript ID", {
  result <- read_transcripts(transcripts = 1)
  expect_gt(nrow(result), 0)
  expect_true(all(result$id == 1))
})

test_that("read_transcripts filters to multiple transcript IDs", {
  result <- read_transcripts(transcripts = c(1, 2))
  expect_gt(nrow(result), 0)
  expect_true(all(result$id %in% c(1, 2)))
  expect_true(length(unique(result$id)) <= 2)
})

test_that("read_transcripts filtered result is a subset of the full data", {
  all_data    <- read_transcripts()
  subset_data <- read_transcripts(transcripts = c(1, 2))
  expect_true(nrow(subset_data) <= nrow(all_data))
})

test_that("read_transcripts warns when no transcripts match", {
  expect_warning(
    read_transcripts(transcripts = 99999),
    "No transcripts found matching IDs"
  )
})

test_that("read_transcripts returns zero rows (with warning) for non-existent ID", {
  result <- suppressWarnings(read_transcripts(transcripts = 99999))
  expect_equal(nrow(result), 0)
})
