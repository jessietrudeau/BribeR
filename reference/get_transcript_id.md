# Retrieve Available Transcript IDs

This function lists all available transcript IDs (or *n* values) based
on the `.csv` files stored in the `data-raw/transcripts` folder of the
**BribeRdata** package.

## Usage

``` r
get_transcript_id(package = "BribeRdata")
```

## Arguments

- package:

  Character string naming the package that stores the transcripts.
  Defaults to `"BribeRdata"`.

## Value

A numeric vector of available transcript IDs.

## Details

Each transcript is named numerically (e.g., `1.csv`, `19.csv`,
`104.csv`), and its ID corresponds directly to that number.

For reference, see the BribeRdata repository:
<https://github.com/jessietrudeau/BribeRdata/tree/main/data-raw/transcripts>

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve all available transcript IDs
ids <- get_transcript_id()

# Use those IDs to load specific transcripts
subset <- get_transcripts_raw(n = ids[1:3])
} # }
```
