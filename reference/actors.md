# Actor Roster

Biographical and institutional metadata for individuals who appear in
the Vladivideos transcripts.

## Usage

``` r
actors
```

## Format

A tibble with 118 rows and 7 variables:

- speaker:

  Full name of the individual.

- speaker_std:

  Standardized identifier matching the `speaker_std` column in the
  transcripts corpus.

- position:

  Institutional role or title at the time of the recordings.

- type:

  Broad institutional category (lowercase). One of `"montesinos"`
  (Vladimiro Montesinos himself, kept separate from `"security"`),
  `"security"`, `"congress"`, `"judiciary"`, `"media"`,
  `"businessperson"`, `"elected official"`, `"bureaucrat"`, `"foreign"`,
  `"illicit"`, or `"unknown"`.

- party:

  Political party affiliation for elected officials, `NA` otherwise.
  Given as the V-Party abbreviation (`v2pashname`) for Peru: `"NM"`,
  `"PAP"`, `"RN"`, `"PP"`, `"PPC"`, `"FIM"` or `"AP"`.

- notes:

  Additional notes on the individual.

- is_speaker:

  Integer indicator: 1 if the individual has at least one speech turn in
  the transcript corpus, 0 if they are named in the archive but never
  recorded speaking. Only individuals with `is_speaker == 1` can be used
  to filter with
  [`get_transcript_id`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_id.md).

## Source

Manually compiled from the Vladivideos archive and related published
research.
