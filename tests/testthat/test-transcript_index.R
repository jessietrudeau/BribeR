test_that("transcript_index has the expected descriptive columns", {
  expected <- c(
    "id", "file", "format", "date", "original_id", "in_book",
    "in_online_archive", "type", "summary", "speakers",
    "n_speakers", "n_topics"
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
  count_cols <- match(c("n_speakers", "n_topics"), nm)
  indicator_cols <- grep("^(speaker|topic)_", nm, value = TRUE)
  first_ind <- min(match(indicator_cols, nm))

  expect_true(all(count_cols > last_desc))
  expect_true(first_ind > max(count_cols))
})

test_that("transcript_index puts all speaker_* indicators before all topic_* indicators", {
  nm <- names(transcript_index)
  speaker_ind <- grep("^speaker_", nm, value = TRUE)
  topic_ind   <- grep("^topic_", nm, value = TRUE)

  expect_true(max(match(speaker_ind, nm)) < min(match(topic_ind, nm)))
})

test_that("summary counts do not share a prefix with the indicator columns", {
  nm <- names(transcript_index)

  expect_true(all(c("n_speakers", "n_topics") %in% nm))
  expect_false(any(c("speaker_count", "topic_count") %in% nm))

  # Selecting indicators by prefix must return only real speakers and topics.
  expect_equal(length(grep("^topic_", nm)), 15)
  expect_false(any(grepl("^(speaker|topic)_count$", nm)))
})

test_that("metadata indicators and topic_*/speaker_* columns are strictly 0/1", {
  nm <- names(transcript_index)
  bool_cols <- c(
    "in_book", "in_online_archive",
    grep("^speaker_", nm, value = TRUE),
    grep("^topic_", nm, value = TRUE)
  )
  all_binary <- vapply(transcript_index[bool_cols], function(x) all(x %in% c(0L, 1L)), logical(1))
  expect_true(all(all_binary))
})
