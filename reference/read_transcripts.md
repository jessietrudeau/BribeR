# Read and Optionally Filter a Transcript-Formatted RDA File

This function loads a pre-processed `.rda` file containing compiled
transcript data. It supports loading from:

- A **local file path** on your computer,

- A **remote URL** (e.g., a GitHub raw link), or

- An **installed package’s** `data/` directory (optional).

## Usage

``` r
read_transcripts(path, package = NULL, transcripts = NULL)
```

## Arguments

- path:

  Character string specifying one of:

  - The **name** of an `.rda` file within a package (without extension),

  - A **local file path** to an `.rda`,

  - Or a **URL** (e.g., GitHub raw link) pointing to an `.rda` file.

- package:

  Optional. Character string naming the package containing the RDA (if
  loading from a package’s `data/` directory). Defaults to `NULL`.

- transcripts:

  Optional numeric or character vector specifying transcript IDs (`n`)
  to filter. If `NULL`, all transcripts are returned.

## Value

A data frame (or tibble) with columns `n`, `row_id`, `speaker`,
`speech`, and `speaker_std`. If `transcripts` is specified, only
matching transcripts are returned.

## Details

Optionally, users can specify one or multiple transcript IDs (`n`) to
filter only those transcripts of interest. If no filter is provided, the
full dataset is returned.

## See also

[`get_transcripts_raw()`](https://github.com/jessietrudeau/BribeR/reference/get_transcripts_raw.md),
[`get_transcript_id()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_id.md),
[`get_transcript_speakers()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_speakers.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# 1. Load the full dataset
all_transcripts <- read_transcripts(
  "https://raw.githubusercontent.com/jessietrudeau/BribeRdata/main/data/vladivideos_transcripts.rda"
)

# 2. Retrieve only transcript 1
t1 <- read_transcripts(
  "https://raw.githubusercontent.com/jessietrudeau/BribeRdata/main/data/vladivideos_transcripts.rda",
  transcripts = 1
)

# 3. Retrieve transcripts 5, 7, and 13
subset_transcripts <- read_transcripts(
  "https://raw.githubusercontent.com/jessietrudeau/BribeRdata/main/data/vladivideos_transcripts.rda",
  transcripts = c(5, 7, 13)
)
} # }
```
