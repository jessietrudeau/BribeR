# Vladivideos Detailed Transcripts

The main corpus of the Vladivideos recordings. Each row represents a
single speech turn within a transcript, with the speaker's words and
metadata.

## Usage

``` r
compiled_transcripts
```

## Format

A tibble with 46,597 rows and 6 variables:

- id:

  Numeric transcript identifier.

- row_id:

  Row number within the transcript.

- date:

  Date of the recording (character).

- speaker_std:

  Standardized speaker identifier (lowercase surname).

- speaker:

  Raw speaker label as it appears in the original transcript.

- speech:

  Text of the speaker's turn (in Spanish).

## Source

Vladimiro Montesinos Torres secret recordings, transcribed and compiled
from the public Vladivideos archive.
