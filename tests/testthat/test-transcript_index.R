test_that("transcript_index has the expected descriptive columns", {
  expected <- c(
    "id", "file", "format", "date", "original_id", "in_book",
    "in_online_archive", "type", "summary", "speakers",
    "speaker_count", "topic_count"
  )
  expect_true(all(expected %in% names(transcript_index)))
})

test_that("transcript_index does not include a separate descriptions dataset", {
  expect_warning(
    utils::data("descriptions", package = "BribeR"),
    "not found"
  )
})

test_that("transcript_index does not include id_raw or in_audio", {
  expect_false(any(c("id_raw", "in_audio") %in% names(transcript_index)))
})

test_that("transcript_index orders descriptive columns before counts before indicators", {
  nm <- names(transcript_index)
  last_desc  <- match("speakers", nm)
  count_cols <- match(c("speaker_count", "topic_count"), nm)
  indicator_cols <- setdiff(grep("^(speaker|topic)_", nm, value = TRUE), c("speaker_count", "topic_count"))
  first_ind <- min(match(indicator_cols, nm))

  expect_true(all(count_cols > last_desc))
  expect_true(first_ind > max(count_cols))
})

test_that("transcript_index puts all speaker_* indicators before all topic_* indicators", {
  nm <- names(transcript_index)
  speaker_ind <- setdiff(grep("^speaker_", nm, value = TRUE), "speaker_count")
  topic_ind   <- setdiff(grep("^topic_", nm, value = TRUE), "topic_count")

  expect_true(max(match(speaker_ind, nm)) < min(match(topic_ind, nm)))
})

test_that("metadata indicators and topic_*/speaker_* columns are strictly 0/1", {
  nm <- names(transcript_index)
  bool_cols <- c(
    "in_book", "in_online_archive",
    setdiff(grep("^speaker_", nm, value = TRUE), "speaker_count"),
    setdiff(grep("^topic_", nm, value = TRUE), "topic_count")
  )
  all_binary <- vapply(transcript_index[bool_cols], function(x) all(x %in% c(0L, 1L)), logical(1))
  expect_true(all(all_binary))
})
