
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

test_that("get_transcript_id narrows across multiple speakers (AND logic)", {
  ids_single <- get_transcript_id(speaker = "crousillat carreno")
  ids_multi  <- get_transcript_id(speaker = c("crousillat carreno", "montesinos"))

  # AND means the combined result is a subset of either filter alone
  expect_true(length(ids_multi) <= length(ids_single))
  expect_true(all(ids_multi %in% ids_single))
})

test_that("get_transcript_id narrows across multiple topics (AND logic)", {
  ids_media      <- get_transcript_id(topic = "media")
  ids_reelection <- get_transcript_id(topic = "reelection")
  ids_both       <- get_transcript_id(topic = c("media", "reelection"))

  expect_true(all(ids_both %in% ids_media))
  expect_true(all(ids_both %in% ids_reelection))
  # Pin the exact overlap so the semantics cannot silently flip back to OR
  expect_equal(length(ids_media), 37)
  expect_equal(length(ids_reelection), 26)
  expect_equal(length(ids_both), 8)
})

test_that("get_transcript_id combines speaker and topic with AND", {
  ids_speaker <- get_transcript_id(speaker = "crousillat carreno")
  ids_topic   <- get_transcript_id(topic = "media")
  ids_both    <- get_transcript_id(speaker = "crousillat carreno", topic = "media")

  expect_true(all(ids_both %in% ids_speaker))
  expect_true(all(ids_both %in% ids_topic))
  expect_equal(length(ids_both), 2)
})

test_that("get_transcript_id returns an empty vector when filters never co-occur", {
  # Morote appears only in transcript 81; no Ecuador transcript includes him
  ids <- get_transcript_id(topic = "ecuador", speaker = "morote")
  expect_type(ids, "double")
  expect_length(ids, 0)
})

test_that("get_transcript_id errors on invalid speaker", {
  expect_error(
    get_transcript_id(speaker = "nonexistent_person_xyz"),
    "not found in transcript_index"
  )
})

test_that("get_transcript_id distinguishes silent actors from unknown names", {
  # valenzuela is in `actors` with is_speaker == 0
  expect_error(
    get_transcript_id(speaker = "valenzuela"),
    "listed in `actors` but never recorded speaking"
  )
  expect_error(
    get_transcript_id(speaker = "nonexistent_person_xyz"),
    "not found in transcript_index"
  )
})

test_that("get_transcript_id can filter on desconocido", {
  ids <- get_transcript_id(speaker = "desconocido")
  expect_type(ids, "double")
  expect_gt(length(ids), 0)
})

test_that("get_transcript_id errors on invalid topic", {
  expect_error(
    get_transcript_id(topic = "nonexistent_topic_xyz"),
    "not found in transcript_index"
  )
})














