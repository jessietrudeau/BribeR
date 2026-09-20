test_that("read_transcript_meta_data returns a tibble with expected columns", {
  meta <- read_transcript_meta_data()
  expect_s3_class(meta, "tbl_df")
  expect_true(all(c("id", "date", "speakers", "n_words", "topics") %in% names(meta)))
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

test_that("read_transcript_meta_data filters to a single transcript ID", {
  one <- read_transcript_meta_data(1)
  expect_equal(nrow(one), 1)
  expect_equal(one$id, 1)
})

test_that("read_transcript_meta_data filters to multiple transcript IDs", {
  some <- read_transcript_meta_data(c(1, 2))
  expect_equal(nrow(some), 2)
  expect_setequal(some$id, c(1, 2))
})

test_that("read_transcript_meta_data returns every transcript by default", {
  all_meta <- read_transcript_meta_data()
  one      <- read_transcript_meta_data(1)
  expect_gt(nrow(all_meta), nrow(one))
})

test_that("read_transcript_meta_data filtered columns match the unfiltered ones", {
  expect_equal(
    names(read_transcript_meta_data(1)),
    names(read_transcript_meta_data())
  )
})

test_that("read_transcript_meta_data warns about IDs with no transcript", {
  expect_warning(
    read_transcript_meta_data(99999),
    "Transcript ID\\(s\\) not found: 99999"
  )
})

test_that("read_transcript_meta_data keeps found IDs and drops missing ones", {
  mixed <- suppressWarnings(read_transcript_meta_data(c(1, 99999)))
  expect_equal(nrow(mixed), 1)
  expect_equal(mixed$id, 1)
})

test_that("read_transcript_meta_data returns a well-formed empty tibble for unknown IDs", {
  none <- suppressWarnings(read_transcript_meta_data(99999))
  expect_s3_class(none, "tbl_df")
  expect_equal(nrow(none), 0)
  expect_true(all(c("id", "date", "speakers", "n_words", "topics") %in% names(none)))
})

test_that("read_transcript_meta_data returns only real topic names", {
  meta <- read_transcript_meta_data()
  topic_names <- gsub("_", " ", sub("^topic_", "",
    grep("^topic_", names(transcript_index), value = TRUE)))

  expect_true(all(unlist(meta$topics) %in% topic_names))
})

test_that("read_transcript_meta_data errors on non-numeric IDs", {
  expect_error(read_transcript_meta_data("media"), "must be numeric transcript IDs")
  expect_error(read_transcript_meta_data(NA), "must be numeric transcript IDs")
})

