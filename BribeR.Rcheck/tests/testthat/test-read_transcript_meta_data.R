test_that("read_transcript_meta_data returns a tibble with expected columns", {
  meta <- read_transcript_meta_data()
  expect_s3_class(meta, "tbl_df")
  expect_true(all(c("n", "date", "speakers", "n_words", "topics") %in% names(meta)))
  expect_gt(nrow(meta), 0)
})

test_that("read_transcript_meta_data speakers column is a list", {
  meta <- read_transcript_meta_data()
  expect_type(meta$speakers, "list")
})

test_that("read_transcript_meta_data topics column is a list", {
  meta <- read_transcript_meta_data()
  expect_type(meta$topics, "list")
})

test_that("read_transcript_meta_data n_words is numeric", {
  meta <- read_transcript_meta_data()
  expect_type(meta$n_words, "integer")
})

test_that("read_transcript_meta_data quiet = FALSE prints a message", {
  expect_message(
    read_transcript_meta_data(quiet = FALSE),
    "Built metadata for"
  )
})

