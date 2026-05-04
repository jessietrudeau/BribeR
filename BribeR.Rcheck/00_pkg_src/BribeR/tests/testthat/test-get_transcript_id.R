
test_that("get_transcript_id returns a sorted numeric vector", {
  ids <- get_transcript_id()
  expect_type(ids, "double")
  expect_true(!is.unsorted(ids))
  expect_gt(length(ids), 0)
})

test_that("get_transcript_id filters by speaker", {
  ids <- get_transcript_id(speaker = "montesinos")
  expect_type(ids, "double")
  expect_gt(length(ids), 0)

  # filtered should be a subset of all
  all_ids <- get_transcript_id()
  expect_true(all(ids %in% all_ids))
})

test_that("get_transcript_id filters by topic", {
  ids <- get_transcript_id(topic = "media")
  expect_type(ids, "double")
  expect_gt(length(ids), 0)

  all_ids <- get_transcript_id()
  expect_true(all(ids %in% all_ids))
})

test_that("get_transcript_id accepts multiple speakers (OR logic)", {
  ids_single <- get_transcript_id(speaker = "kouri")
  ids_multi  <- get_transcript_id(speaker = c("kouri", "montesinos"))
  expect_true(length(ids_multi) >= length(ids_single))
})

test_that("get_transcript_id accepts multiple topics (OR logic)", {
  ids_single <- get_transcript_id(topic = "media")
  ids_multi  <- get_transcript_id(topic = c("media", "reelection"))
  expect_true(length(ids_multi) >= length(ids_single))
})

test_that("get_transcript_id combines speaker and topic with OR", {
  ids_speaker <- get_transcript_id(speaker = "kouri")
  ids_topic   <- get_transcript_id(topic = "media")
  ids_both    <- get_transcript_id(speaker = "kouri", topic = "media")

  # OR means combined should be at least as large as either alone
  expect_true(length(ids_both) >= length(ids_speaker))
  expect_true(length(ids_both) >= length(ids_topic))
})

test_that("get_transcript_id errors on invalid speaker", {
  expect_error(
    get_transcript_id(speaker = "nonexistent_person_xyz"),
    "not found in transcript_index"
  )
})

test_that("get_transcript_id errors on invalid topic", {
  expect_error(
    get_transcript_id(topic = "nonexistent_topic_xyz"),
    "not found in transcript_index"
  )
})














