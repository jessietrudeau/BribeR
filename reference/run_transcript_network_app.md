# Run the Transcript-Topic-Speaker Shiny app (fixed project paths)

Launch an interactive Shiny application that visualizes the
relationships between speakers and topics in a transcript collection,
using fixed project-relative paths for metadata and transcripts.

## Usage

``` r
run_transcript_network_app(transcript_dir = NULL)
```

## Arguments

- transcript_dir:

  Optional path to a directory of transcript CSV/TSV files (with a
  `speaker_std` column). If `NULL`, the app will use
  `data-raw/transcripts` under the current working directory.

## Value

A `shiny.appobj` that, when printed, launches the
Transcript-Topic-Speaker Shiny application.

## Details

This version assumes your working directory is set to the project root
and uses the following fixed subdirectories:

- `data-raw/Inventory & Descriptions` for:

  - `Descriptions.csv`

  - `speakers per transcript.csv`

  - `Topic Descriptions.csv`

  - `Actors.csv`

- `data-raw/transcripts` for transcript CSV/TSV files

- `inst/images/montesinos.PNG` (optional image for the "montesinos"
  node)

This function expects the metadata CSVs to have the following structure:

- `Descriptions.csv` contains a column `n` (transcript ID) and multiple
  `topic_...` columns with `"x"` indicating topic inclusion.

- `speakers per transcript.csv` contains a column `n` and wide-format
  speaker columns with speaker names.

- `Topic Descriptions.csv` contains a column `topics` and a column
  `descriptions` describing each topic.

- `Actors.csv` contains information on actors, including `speaker`,
  `speaker_std`, `Type`, and `Position`.

Transcript files in `data-raw/transcripts` (or in `transcript_dir`) must
contain a `speaker_std` column used to compute speaker frequency across
conversations.

## Examples

``` r
if (FALSE) { # \dontrun{
# Run using the default data-raw/ structure:
run_transcript_network_app()

# Run using a custom transcript directory:
run_transcript_network_app("other/transcripts/path")
} # }
```
