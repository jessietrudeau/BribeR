# Transcript Index

A wide-format lookup table with one row per transcript. Contains boolean
indicator columns for each topic and each speaker, enabling fast
filtering without loading the full corpus.

## Usage

``` r
transcript_index
```

## Format

A tibble with 101 rows and 134 variables. Key variables:

- n:

  Numeric transcript identifier.

- file:

  Relative path to the source CSV file.

- format:

  File format of the source transcript (e.g. `"csv"`).

- date:

  Date of the recording.

- topic_referendum, topic_ecuador, topic_lucchetti_factory,
  topic_municipal98, topic_reelection, topic_miraflores, topic_canal4,
  topic_media, topic_promotions, topic_ivcher, topic_foreign,
  topic_wiese, topic_public_officials, topic_safety,
  topic_state_capture:

  Integer indicator (1/0) for each topic.

- speaker_SURNAME:

  Integer indicator (1/0) for each standardized speaker. One column per
  unique speaker, named `speaker_` followed by the speaker's
  standardized surname.

- topic_count:

  Total number of topics flagged for the transcript.

- speaker_count:

  Total number of distinct speakers in the transcript.

## Source

Derived from the Vladivideos transcripts and the package's descriptions
and speakers datasets.
