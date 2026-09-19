# Speakers Per Transcript

A wide-format table listing the standardized speaker identifiers present
in each transcript, with one row per transcript and one column per
speaker slot.

## Usage

``` r
speakers_per_transcript
```

## Format

A tibble with 101 rows and 20 variables:

- id:

  Numeric transcript identifier.

- speaker_std_1 ... speaker_std_19:

  Standardized speaker identifier for the 1st through 19th speaker slot.
  `NA` if the slot is unused for that transcript.

## Source

Derived from the Vladivideos transcripts.
