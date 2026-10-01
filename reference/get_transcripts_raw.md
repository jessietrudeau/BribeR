# Retrieve Raw Transcript Files from bribeR

Retrieves one or more raw transcript `.csv` files from the
`data-raw/transcripts` folder of the **bribeR** package.

## Usage

``` r
get_transcripts_raw(id = NULL, combine = FALSE)
```

## Arguments

- id:

  Optional integer or vector of integers specifying which transcript(s)
  to load. If `NULL` (default), all transcripts are loaded.

- combine:

  Logical; if `TRUE`, combines all transcripts into a single tibble with
  an added column `id` (the transcript ID). Defaults to `FALSE`.

## Value

If `combine = FALSE`, returns a named list of data frames (tibbles). If
`combine = TRUE`, returns a combined tibble with an added column `id`.

## Details

Transcripts are named by their numeric ID (e.g., `1.csv`, `19.csv`,
`104.csv`). You can load all transcripts or specify a subset by
transcript ID.

## See also

[`read_transcripts()`](https://jessietrudeau.com/bribeR/reference/read_transcripts.md),
[`get_transcript_id()`](https://jessietrudeau.com/bribeR/reference/get_transcript_id.md),
[`get_transcript_speakers()`](https://jessietrudeau.com/bribeR/reference/get_transcript_speakers.md)

## Examples

``` r
# \donttest{
# Load all transcripts (as a list)
all_transcripts <- get_transcripts_raw()

# Load a specific transcript by ID
t1 <- get_transcripts_raw(id = 1)

# Load multiple transcripts and combine them
subset_combined <- get_transcripts_raw(id = c(1, 13, 86), combine = TRUE)
# }
```
