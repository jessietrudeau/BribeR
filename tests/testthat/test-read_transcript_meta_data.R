test_that("read_transcript_meta_data builds expected structure and values", {
  tmpdir <- tempfile("meta_")
  dir.create(tmpdir, recursive = TRUE)

  # --- Descriptions.csv (n, date, topic_* flags)
  desc_path <- file.path(tmpdir, "Descriptions.csv")
  desc <- data.frame(
    n = c("1", "2"),
    date = c("2020-01-01", "2020-01-02"),
    topic_referendum = c("x", ""),
    topic_ecuador = c("", "TRUE"),
    topic_fakeflag = c("0", "no"),  # should be treated as FALSE
    stringsAsFactors = FALSE
  )
  readr::write_csv(desc, desc_path)

  # --- speakers_per_transcript.csv (wide, misspelling accepted)
  spt_path <- file.path(tmpdir, "speakers_per_transcript.csv")
  spt <- data.frame(
    n = c("1", "2"),
    speakrer_std_1 = c("Montesinos", "Fujimori"),
    speakrer_std_2 = c("  Montesinos  ", "Advisor"), # duplicate after trim for n=1
    speakrer_std_3 = c("", NA),
    stringsAsFactors = FALSE
  )
  readr::write_csv(spt, spt_path)

  # --- transcripts directory with transcript files (word counts from speech column)
  transcripts_dir <- file.path(tmpdir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)

  # 1.csv has 2 rows, 2 + 3 words = 5 words total
  t1 <- data.frame(speech = c("hello world", "one two three"), stringsAsFactors = FALSE)
  readr::write_csv(t1, file.path(transcripts_dir, "1.csv"))

  # 2.tsv has 1 row, 4 words total
  t2 <- data.frame(speech = c("this is four words"), stringsAsFactors = FALSE)
  readr::write_tsv(t2, file.path(transcripts_dir, "2.tsv"))

  meta <- read_transcript_meta_data(
    descriptions_path = desc_path,
    speakers_per_transcript_path = spt_path,
    transcripts_dir = transcripts_dir,
    quiet = TRUE
  )

  # --- structure
  expect_s3_class(meta, "tbl_df")
  expect_equal(names(meta), c("n", "date", "speakers", "n_words", "topics"))
  expect_equal(nrow(meta), 2)

  # --- speakers list-column (trim, unique, sorted)
  row1_speakers <- meta$speakers[meta$n == "1"][[1]]
  row2_speakers <- meta$speakers[meta$n == "2"][[1]]

  expect_equal(row1_speakers, sort(unique(c("Montesinos"))))
  expect_equal(row2_speakers, sort(unique(c("Advisor", "Fujimori"))))

  # --- topics list-column (truthy rules + name normalization)
  row1_topics <- meta$topics[meta$n == "1"][[1]]
  row2_topics <- meta$topics[meta$n == "2"][[1]]

  expect_true("referendum" %in% row1_topics)
  expect_false("ecuador" %in% row1_topics)

  expect_true("ecuador" %in% row2_topics)
  expect_false("fakeflag" %in% row2_topics)

  # --- word counts
  expect_equal(meta$n_words[meta$n == "1"], 5L)
  expect_equal(meta$n_words[meta$n == "2"], 4L)
})

test_that("read_transcript_meta_data sets date to NA if missing and quiet=FALSE warns", {
  tmpdir <- tempfile("meta_")
  dir.create(tmpdir, recursive = TRUE)

  desc_path <- file.path(tmpdir, "Descriptions.csv")
  desc <- data.frame(
    n = c("1"),
    topic_test = c("x"),
    stringsAsFactors = FALSE
  )
  readr::write_csv(desc, desc_path)

  spt_path <- file.path(tmpdir, "speakers_per_transcript.csv")
  spt <- data.frame(
    n = c("1"),
    speaker_std_1 = c("A"),
    stringsAsFactors = FALSE
  )
  readr::write_csv(spt, spt_path)

  transcripts_dir <- file.path(tmpdir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)
  readr::write_csv(data.frame(speech = "hi", stringsAsFactors = FALSE),
                   file.path(transcripts_dir, "1.csv"))

  expect_warning(
    meta <- read_transcript_meta_data(
      descriptions_path = desc_path,
      speakers_per_transcript_path = spt_path,
      transcripts_dir = transcripts_dir,
      quiet = FALSE
    ),
    "no 'date' column",
    fixed = FALSE
  )

  expect_true("date" %in% names(meta))
  expect_true(is.na(meta$date[[1]]))
})

test_that("read_transcript_meta_data errors if descriptions lacks n", {
  tmpdir <- tempfile("meta_")
  dir.create(tmpdir, recursive = TRUE)

  desc_path <- file.path(tmpdir, "Descriptions.csv")
  readr::write_csv(data.frame(date = "2020-01-01"), desc_path)

  spt_path <- file.path(tmpdir, "speakers_per_transcript.csv")
  readr::write_csv(data.frame(n = "1", speaker_std_1 = "A"), spt_path)

  transcripts_dir <- file.path(tmpdir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)

  expect_error(
    read_transcript_meta_data(desc_path, spt_path, transcripts_dir),
    "must include column 'n'",
    fixed = FALSE
  )
})

test_that("read_transcript_meta_data errors if speakers_per_transcript lacks n", {
  tmpdir <- tempfile("meta_")
  dir.create(tmpdir, recursive = TRUE)

  desc_path <- file.path(tmpdir, "Descriptions.csv")
  readr::write_csv(data.frame(n = "1", date = "2020-01-01"), desc_path)

  spt_path <- file.path(tmpdir, "speakers_per_transcript.csv")
  readr::write_csv(data.frame(speaker_std_1 = "A"), spt_path)

  transcripts_dir <- file.path(tmpdir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)

  expect_error(
    read_transcript_meta_data(desc_path, spt_path, transcripts_dir),
    "must include column 'n'",
    fixed = FALSE
  )
})

test_that("read_transcript_meta_data errors if no speaker_std columns are present", {
  tmpdir <- tempfile("meta_")
  dir.create(tmpdir, recursive = TRUE)

  desc_path <- file.path(tmpdir, "Descriptions.csv")
  readr::write_csv(data.frame(n = "1", date = "2020-01-01"), desc_path)

  spt_path <- file.path(tmpdir, "speakers_per_transcript.csv")
  # has n but no speakrer_std_# or speaker_std_# columns
  readr::write_csv(data.frame(n = "1", other = "x"), spt_path)

  transcripts_dir <- file.path(tmpdir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)

  expect_error(
    read_transcript_meta_data(desc_path, spt_path, transcripts_dir),
    "must include columns like 'speakrer_std_1' or 'speaker_std_1'",
    fixed = FALSE
  )
})

test_that("read_transcript_meta_data sets n_words to NA when transcript file missing or speech missing", {
  tmpdir <- tempfile("meta_")
  dir.create(tmpdir, recursive = TRUE)

  desc_path <- file.path(tmpdir, "Descriptions.csv")
  readr::write_csv(data.frame(n = c("1", "2"), date = c("d1", "d2")), desc_path)

  spt_path <- file.path(tmpdir, "speakers_per_transcript.csv")
  readr::write_csv(
    data.frame(n = c("1", "2"), speaker_std_1 = c("A", "B"), stringsAsFactors = FALSE),
    spt_path
  )

  transcripts_dir <- file.path(tmpdir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)

  # Only create 1.csv but WITHOUT speech column
  readr::write_csv(data.frame(not_speech = "x"), file.path(transcripts_dir, "1.csv"))
  # No file for 2 at all

  meta <- read_transcript_meta_data(desc_path, spt_path, transcripts_dir, quiet = TRUE)

  expect_true(is.na(meta$n_words[meta$n == "1"]))
  expect_true(is.na(meta$n_words[meta$n == "2"]))
})

