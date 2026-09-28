# Actor Roster

Biographical and institutional metadata for individuals who appear in
the Vladivideos transcripts.

## Usage

``` r
actors
```

## Format

A tibble with 140 rows and 6 variables:

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
  `"illicit"`, or `"other"` (private individuals with no institutional
  role, including the `"desconocido"` placeholder).

- party:

  Political party affiliation for elected officials, `NA` otherwise.
  Given as the V-Party abbreviation (`v2pashname`) for Peru: `"NM"`,
  `"PAP"`, `"RN"`, `"PP"`, `"PPC"`, `"FIM"` or `"AP"`.

- notes:

  Additional notes on the individual.

## Source

Manually compiled from the Vladivideos archive and related published
research.
