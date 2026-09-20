# Read transcript-level metadata (id, date, speakers, duration, topics)

Builds a tidy data frame of transcript metadata from bundled package
data. Combines information from three internal sources:

1.  **transcript_index** (transcript identifiers, dates, topic flags),

2.  **speakers_per_transcript** (speaker roster per transcript), and

3.  **compiled_transcripts** (word counts derived from the `speech`
    column).

## Usage

``` r
read_transcript_meta_data(id = NULL, quiet = TRUE)
```

## Arguments

- id:

  Optional numeric vector of transcript IDs to return metadata for
  (e.g., `5`, or `c(5, 12, 47)`). If `NULL` (the default), metadata for
  every transcript is returned. IDs with no matching transcript are
  dropped with a warning naming them.

- quiet:

  Logical; if `FALSE`, prints progress messages. Default `TRUE`.

## Value

A tibble with one row per transcript and columns:

- `id` (numeric): transcript identifier.

- `date` (character): date associated with the transcript (or `NA` if
  absent).

- `speakers` (list of character): unique, sorted vector of speakers for
  the transcript.

- `n_words` (integer): total word count across the transcript's `speech`
  column.

- `topics` (list of character): vector of topic names inferred from
  `topic_*` flags.

## Details

- **Transcript ID (`id`) and `date`:** Read from the bundled
  `transcript_index` dataset.

- **Topics (`topics` list-column):** Columns in `transcript_index` whose
  names start with `topic_` are interpreted as topic flags (1/0
  integers). Topic names are normalized by removing the `topic_` prefix
  and replacing `_` with spaces.

- **Speakers (`speakers` list-column):** Read from the bundled
  `speakers_per_transcript` dataset. Speaker columns are collapsed to a
  unique, sorted character vector per transcript.

- **Duration (`n_words`):** Computed from the bundled
  `compiled_transcripts` dataset by summing whitespace-delimited tokens
  in the `speech` column for each unique transcript `n`.

## See also

[`read_transcripts()`](https://jessietrudeau.github.io/BribeR/reference/read_transcripts.md),
[`get_transcript_speakers()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_speakers.md)

## Examples

``` r
# \donttest{
# Load metadata for all transcripts
meta <- read_transcript_meta_data()
head(meta)
#> # A tibble: 6 × 5
#>      id date       speakers  n_words topics   
#>   <dbl> <chr>      <list>      <int> <list>   
#> 1     1 1997-03-25 <chr [4]>   10375 <chr [2]>
#> 2     2 1997-03-26 <chr [2]>    7120 <chr [3]>
#> 3     3 1997-03-26 <chr [3]>    7006 <chr [3]>
#> 4     4 1997-06-13 <chr [2]>     175 <chr [3]>
#> 5     5 1998-01-08 <chr [5]>    9391 <chr [3]>
#> 6     6 1998-01-12 <chr [2]>   13035 <chr [3]>

# Metadata for a single transcript
read_transcript_meta_data(5)
#> # A tibble: 1 × 5
#>      id date       speakers  n_words topics   
#>   <dbl> <chr>      <list>      <int> <list>   
#> 1     5 1998-01-08 <chr [5]>    9391 <chr [3]>

# Metadata for several transcripts
read_transcript_meta_data(c(5, 12, 47))
#> # A tibble: 3 × 5
#>      id date       speakers  n_words topics   
#>   <dbl> <chr>      <list>      <int> <list>   
#> 1     5 1998-01-08 <chr [5]>    9391 <chr [3]>
#> 2    12 1998-02-10 <chr [2]>    1283 <chr [2]>
#> 3    47 1998-11-23 <chr [2]>   15941 <chr [4]>
# }
```
