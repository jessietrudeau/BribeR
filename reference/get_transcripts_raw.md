# Retrieve Raw Transcript Files from bribeR

This function retrieves one or more raw transcript `.csv` files from the
`data-raw/transcripts` folder of the **bribeR** package. It supports
both installed and development versions of the package.

## Usage

``` r
get_transcripts_raw(n = NULL, combine = FALSE, package = "bribeR")
```

## Arguments

- n:

  Optional integer or vector of integers specifying which transcript(s)
  to load. If `NULL` (default), all transcripts are loaded.

- combine:

  Logical; if `TRUE`, combines all transcripts into a single tibble with
  an added column `n` (the transcript ID). Defaults to `FALSE`.

- package:

  Character string naming the package that stores the transcripts.
  Defaults to `"bribeR"`. (Kept for flexibility/testing.)

## Value

If `combine = FALSE`, returns a named list of data frames (tibbles). If
`combine = TRUE`, returns a combined tibble with an added column `n`.

## Details

Transcripts are named by their numeric ID (e.g., `1.csv`, `19.csv`,
`104.csv`). You can load all transcripts or specify a subset by
transcript ID.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load all transcripts (as a list)
all_transcripts <- get_transcripts_raw()

# Load a specific transcript by ID
t3 <- get_transcripts_raw(n = 3)

# Load multiple transcripts and combine them
subset_combined <- get_transcripts_raw(
  n = c(3, 19, 104),
  combine = TRUE
)
} # }
```
