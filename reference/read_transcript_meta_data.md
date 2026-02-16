# Read transcript-level metadata (n, date, speakers, duration, topics)

Builds a tidy data frame of transcript metadata from three sources:

1.  **Descriptions.csv** (transcript identifiers, dates, topic flags),

2.  **speakers_per_transcript.csv** (speaker roster per transcript), and

3.  the **finalized transcripts folder** (word-count duration from the
    `speech` column).

## Usage

``` r
read_transcript_meta_data(
  descriptions_path,
  speakers_per_transcript_path,
  transcripts_dir,
  pattern = "\\.(csv|tsv)$",
  recursive = FALSE,
  quiet = TRUE
)
```

## Arguments

- descriptions_path:

  Character path to *Descriptions.csv* containing at least column `n`;
  ideally also `date` and topic flag columns prefixed with `topic_`.

- speakers_per_transcript_path:

  Character path to *speakers_per_transcript.csv* containing column `n`
  and wide speaker columns named `speakrer_std_#` or `speaker_std_#`.

- transcripts_dir:

  Character path to the folder containing finalized transcript files
  (`.csv`/`.tsv`) with a `speech` column used for word counts. Filenames
  (without extension) must match `n` in *Descriptions.csv*.

- pattern:

  Regex used to match transcript files in `transcripts_dir`. Default
  `"\\.(csv|tsv)$"`.

- recursive:

  Logical; search `transcripts_dir` subfolders. Default `FALSE`.

- quiet:

  Logical; if `FALSE`, prints progress messages. Default `TRUE`.

## Value

A tibble with one row per transcript and columns:

- `n` (character): transcript identifier (from *Descriptions.csv*).

- `date` (character): date from *Descriptions.csv* (or `NA` if absent).

- `speakers` (list of character): unique, sorted vector of speakers for
  the transcript.

- `n_words` (integer): total word count across the transcript’s `speech`
  column (or `NA` if the file is not found / lacks `speech`).

- `topics` (list of character): vector of topic names inferred from
  `topic_*` flags.

## Details

- **Transcript ID (`n`) and `date`:** Read from *Descriptions.csv*. The
  first column `n` identifies the transcript; `date` is taken as-is
  (coerced to character).

- **Topics (`topics` list-column):** Any columns in *Descriptions.csv*
  whose names start with `topic_` are interpreted as topic flags. A
  topic is considered present if the cell is “truthy” (e.g., `x`/`X`,
  non-empty string, `1`, `TRUE`). Topic names are normalized by removing
  the `topic_` prefix and replacing `_` with spaces.

- **Speakers (`speakers` list-column):** Read from
  *speakers_per_transcript.csv*. The file is expected to store speakers
  in wide form with columns named like `speakrer_std_1` **(source
  misspelling accepted)** or `speaker_std_1`, `..._2`, etc. These are
  collapsed to a unique, sorted character vector per transcript.

- **Duration (`n_words`):** If a matching transcript file exists in
  `transcripts_dir`, the function sums whitespace-delimited tokens
  across the `speech` column to produce a total word count. A transcript
  file is matched by basename (e.g., `12.csv` or `12.tsv` corresponds to
  `n == "12"`). If no file is found, `n_words` is `NA`.

## Examples

``` r
if (FALSE) { # \dontrun{
meta <- read_transcript_meta_data(
   descriptions_path = "data-raw/Inventory & Descriptions/Descriptions.csv",
   speakers_per_transcript_path = "data-raw/Inventory & Descriptions/speakers per transcript.csv",
    transcripts_dir = "data-raw/transcripts",
   recursive = TRUE
    )

view(meta)
} # }
```
