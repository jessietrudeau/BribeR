# Vladivideos Detailed Transcripts

The main corpus of the Vladivideos recordings. Each row represents a
single speech turn within a transcript, with the speaker's words and
metadata.

## Usage

``` r
compiled_transcripts
```

## Format

A tibble with 47,375 rows and 7 variables:

- n:

  Numeric transcript identifier.

- row_id:

  Row number within the transcript.

- date:

  Date of the recording (character).

- speaker:

  Raw speaker label as it appears in the original transcript.

- speech:

  Text of the speaker's turn (in Spanish).

- speaker_std:

  Standardized speaker identifier (uppercase surname).

- topic:

  Primary topic tag assigned to the transcript.

## Source

Vladimiro Montesinos Torres secret recordings, transcribed and compiled
from the public Vladivideos archive.
