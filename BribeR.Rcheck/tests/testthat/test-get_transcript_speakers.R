test_that("get_transcript_speakers returns a tibble with expected columns", {
  speakers <- get_transcript_speakers()
  expect_s3_class(speakers, "tbl_df")
  expect_true(all(c("speaker_std", "transcripts") %in% names(speakers)))
  expect_gt(nrow(speakers), 0)
})

test_that("get_transcript_speakers transcripts column is a list of numeric vectors", {
  speakers <- get_transcript_speakers()
  expect_type(speakers$transcripts, "list")

  # check first entry is numeric
  first_entry <- speakers$transcripts[[1]]
  expect_type(first_entry, "double")
})

test_that("get_transcript_speakers returns unique speaker_std values", {
  speakers <- get_transcript_speakers()
  expect_equal(length(speakers$speaker_std), length(unique(speakers$speaker_std)))
})

test_that("get_transcript_speakers results are sorted by speaker_std", {
  speakers <- get_transcript_speakers()
  expect_true(!is.unsorted(speakers$speaker_std))
})
