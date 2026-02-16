# Run the Transcript-Topic-Speaker Shiny app

Launch an interactive Shiny application that visualizes the
relationships between speakers and topics in a transcript collection.
All data is loaded from the bundled package datasets and the
`data-raw/transcripts` folder.

## Usage

``` r
run_transcript_network_app(transcript_dir = NULL)
```

## Arguments

- transcript_dir:

  Optional path to a directory of transcript CSV/TSV files (with a
  `speaker_std` column). If `NULL`, the app will use
  `data-raw/transcripts` from the BribeR package.

## Value

A `shiny.appobj` that, when printed, launches the
Transcript-Topic-Speaker Shiny application.

## Details

The app provides two network views:

- **Speaker-Topic Network**: connects speakers to the topics discussed
  in their transcripts.

- **Speaker Co-Appearance Network**: connects speakers who appear in the
  same transcript.

## See also

[`read_transcripts()`](https://github.com/jessietrudeau/BribeR/reference/read_transcripts.md),
[`read_transcript_meta_data()`](https://github.com/jessietrudeau/BribeR/reference/read_transcript_meta_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Run the network app
run_transcript_network_app()
} # }
```
