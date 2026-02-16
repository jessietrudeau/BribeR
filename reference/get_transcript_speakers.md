# Get speakers present in each transcript

Reads the canonical "speakers per transcript.csv" file and returns one
row per transcript `n` with a list-column of unique speakers present in
that transcript.

## Usage

``` r
get_transcript_speakers(
  path = file.path("data-raw", "Inventory & Descriptions", "speakers per transcript.csv")
)
```

## Arguments

- path:

  Optional. Path to the speakers-per-transcript file. Defaults to
  "data-raw/Inventory & Descriptions/speakers per transcript.csv".

## Value

A tibble with columns:

- `n` (character): transcript id

- `speakers` (list): unique, sorted character vector of speakers for
  that transcript

## Examples

``` r
# Load in all unique speakers in each transcript
speakers <- get_transcript_speakers()
#> Error: Speakers-per-transcript file not found at: data-raw/Inventory & Descriptions/speakers per transcript.csv

```
