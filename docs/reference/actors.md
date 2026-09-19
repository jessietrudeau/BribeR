# Actor Roster

Biographical and institutional metadata for individuals who appear in
the Vladivideos transcripts.

## Usage

``` r
actors
```

## Format

A tibble with 125 rows and 6 variables:

- speaker:

  Full name of the individual.

- position:

  Institutional role or title at the time of the recordings.

- type:

  Broad institutional category (lowercase). One of `"montesinos"`
  (Vladimiro Montesinos himself, kept separate from `"security"`),
  `"security"`, `"congress"`, `"judiciary"`, `"media"`,
  `"businessperson"`, `"elected official"`, `"bureaucrat"`, `"foreign"`,
  `"illicit"`, or `"unknown"`.

- party:

  Political party affiliation, where applicable.

- speaker_std:

  Standardized identifier matching the `speaker_std` column in the
  transcripts corpus.

- notes:

  Additional notes on the individual.

## Source

Manually compiled from the Vladivideos archive and related published
research.
