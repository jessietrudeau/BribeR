# Read transcript-level metadata (n, date, speakers, duration, topics)

Builds a tidy data frame of transcript metadata from bundled package
data. Combines information from three internal sources:

1.  **descriptions** (transcript identifiers, dates, topic flags),

2.  **speakers_per_transcript** (speaker roster per transcript), and

3.  **vladivideos_detailed** (word counts derived from the `speech`
    column).

## Usage

``` r
read_transcript_meta_data(quiet = TRUE)
```

## Arguments

- quiet:

  Logical; if `FALSE`, prints progress messages. Default `TRUE`.

## Value

A tibble with one row per transcript and columns:

- `n` (numeric): transcript identifier.

- `date` (character): date associated with the transcript (or `NA` if
  absent).

- `speakers` (list of character): unique, sorted vector of speakers for
  the transcript.

- `n_words` (integer): total word count across the transcript's `speech`
  column.

- `topics` (list of character): vector of topic names inferred from
  `topic_*` flags.

## Details

- **Transcript ID (`n`) and `date`:** Read from the bundled
  `descriptions` dataset.

- **Topics (`topics` list-column):** Columns in `descriptions` whose
  names start with `topic_` are interpreted as topic flags. A topic is
  considered present if the cell is "truthy" (e.g., `x`/`X`, non-empty
  string, `1`, `TRUE`). Topic names are normalized by removing the
  `topic_` prefix and replacing `_` with spaces.

- **Speakers (`speakers` list-column):** Read from the bundled
  `speakers_per_transcript` dataset. Speaker columns are collapsed to a
  unique, sorted character vector per transcript.

- **Duration (`n_words`):** Computed from the bundled
  `vladivideos_detailed` dataset by summing whitespace-delimited tokens
  in the `speech` column for each unique transcript `n`.

## See also

[`read_transcripts()`](https://github.com/jessietrudeau/BribeR/reference/read_transcripts.md),
[`get_transcript_speakers()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_speakers.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Load metadata for all transcripts
meta <- read_transcript_meta_data()
head(meta)
} # }
```
