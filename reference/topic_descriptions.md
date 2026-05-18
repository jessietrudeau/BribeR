# Topic Descriptions

Human-readable labels and descriptions for each topic tag used in the
Vladivideos corpus.

## Usage

``` r
topic_descriptions
```

## Format

A tibble with 15 rows and 2 variables:

- topics:

  Topic identifier, matching the `topic_*` column names in
  `descriptions` and `transcript_index`.

- descriptions:

  Plain-language description of what the topic covers.

## Source

Manually compiled as part of the BribeR package development.
