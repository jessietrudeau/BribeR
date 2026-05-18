# Transcript Descriptions

Transcript-level metadata including dates, topic flags, availability
information, and plain-language summaries.

## Usage

``` r
descriptions
```

## Format

A tibble with 104 rows and 24 variables:

- n:

  Numeric transcript identifier.

- date:

  Date of the recording.

- speakers:

  Free-text description of participants.

- original_n:

  Original transcript number from the source archive.

- Missing Topic:

  Flag indicating the transcript has no assigned topic.

- in_book:

  Flag indicating the transcript is cited in published work.

- in_online_archive:

  Flag indicating availability in the online archive.

- type:

  Recording medium (e.g. `"audio"`, `"video"`).

- topic_referendum, topic_ecuador, topic_lucchetti_factory,
  topic_municipal98, topic_reelection, topic_miraflores, topic_canal4,
  topic_media, topic_promotions, topic_ivcher, topic_foreign,
  topic_wiese, topic_public_officials, topic_safety,
  topic_state_capture:

  Topic indicator flags. A cell value of `"x"` indicates the topic is
  present in that transcript.

- summary:

  Plain-language English summary of the transcript's content.

## Source

Manually compiled from the Vladivideos archive and related published
research.
