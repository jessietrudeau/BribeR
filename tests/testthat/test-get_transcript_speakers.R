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

test_that("get_transcript_speakers filters to a single transcript ID", {
  one <- get_transcript_speakers(n = 1)
  expect_gt(nrow(one), 0)
  # every speaker returned should be attached only to transcript 1
  expect_true(all(vapply(one$transcripts, function(x) identical(x, 1), logical(1))))
})

test_that("get_transcript_speakers filters to multiple transcript IDs", {
  some <- get_transcript_speakers(n = c(1, 2))
  expect_gt(nrow(some), 0)
  expect_true(all(unlist(some$transcripts) %in% c(1, 2)))
})

test_that("get_transcript_speakers filtering by n is a subset of everything", {
  all_speakers <- get_transcript_speakers()
  one          <- get_transcript_speakers(n = 1)
  expect_true(all(one$speaker_std %in% all_speakers$speaker_std))
  expect_lt(nrow(one), nrow(all_speakers))
})

test_that("get_transcript_speakers filters by a single topic", {
  media <- get_transcript_speakers(topic = "media")
  expect_s3_class(media, "tbl_df")
  expect_gt(nrow(media), 0)
  # every transcript credited to a speaker must be a media transcript
  media_ids <- get_transcript_id(topic = "media")
  expect_true(all(unlist(media$transcripts) %in% media_ids))
})

test_that("get_transcript_speakers narrows across multiple topics (AND logic)", {
  media <- get_transcript_speakers(topic = "media")
  both  <- get_transcript_speakers(topic = c("media", "reelection"))

  expect_true(all(both$speaker_std %in% media$speaker_std))
  expect_lt(nrow(both), nrow(media))
  # speakers drawn from the 8 transcripts flagged for both topics
  expect_true(all(unlist(both$transcripts) %in% get_transcript_id(topic = c("media", "reelection"))))
})

test_that("get_transcript_speakers combines n and topic with AND", {
  # transcript 4 is flagged for media, transcript 1 is not
  hit  <- get_transcript_speakers(n = 4, topic = "media")
  miss <- get_transcript_speakers(n = 1, topic = "media")

  expect_gt(nrow(hit), 0)
  expect_true(all(unlist(hit$transcripts) == 4))
  expect_equal(nrow(miss), 0)
})

test_that("get_transcript_speakers returns a well-formed empty tibble", {
  none <- get_transcript_speakers(n = 1, topic = "media")
  expect_s3_class(none, "tbl_df")
  expect_equal(nrow(none), 0)
  expect_true(all(c("speaker_std", "transcripts") %in% names(none)))
})

test_that("get_transcript_speakers warns about transcript IDs that do not exist", {
  expect_warning(
    get_transcript_speakers(n = 99999),
    "Transcript ID\\(s\\) not found: 99999"
  )
})

test_that("get_transcript_speakers errors on an unknown topic", {
  expect_error(
    get_transcript_speakers(topic = "nonexistent_topic_xyz"),
    "not found in transcript_index"
  )
})
