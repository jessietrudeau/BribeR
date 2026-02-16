# Retrieve Raw Transcript Files from BribeR

Retrieves one or more raw transcript `.csv` files from the
`data-raw/transcripts` folder of the **BribeR** package.

## Usage

``` r
get_transcripts_raw(n = NULL, combine = FALSE)
```

## Arguments

- n:

  Optional integer or vector of integers specifying which transcript(s)
  to load. If `NULL` (default), all transcripts are loaded.

- combine:

  Logical; if `TRUE`, combines all transcripts into a single tibble with
  an added column `n` (the transcript ID). Defaults to `FALSE`.

## Value

If `combine = FALSE`, returns a named list of data frames (tibbles). If
`combine = TRUE`, returns a combined tibble with an added column `n`.

## Details

Transcripts are named by their numeric ID (e.g., `1.csv`, `19.csv`,
`104.csv`). You can load all transcripts or specify a subset by
transcript ID.

## See also

[`read_transcripts()`](https://github.com/jessietrudeau/BribeR/reference/read_transcripts.md),
[`get_transcript_id()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_id.md),
[`get_transcript_speakers()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_speakers.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Load all transcripts (as a list)
all_transcripts <- get_transcripts_raw()

# Load a specific transcript by ID
t3 <- get_transcripts_raw(n = 3)

# Load multiple transcripts and combine them
subset_combined <- get_transcripts_raw(n = c(3, 19, 104), combine = TRUE)
} # }
```
