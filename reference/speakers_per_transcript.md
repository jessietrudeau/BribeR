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

- n:

  Numeric transcript identifier.

- speakrer_std_1 ... speakrer_std_19:

  Standardized speaker identifier for the 1st through 19th speaker slot.
  `NA` if the slot is unused for that transcript. Note: column names
  contain a known typo (`speakrer` instead of `speaker`) preserved from
  the source data.

## Source

Derived from the Vladivideos transcripts.
