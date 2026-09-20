# Retrieve Available Transcript IDs

Returns all available transcript IDs (the unique values of `n`) from the
bundled Vladivideos transcript dataset. Optionally filters to only those
transcripts that include any of the specified speakers or topics, using
the bundled `transcript_index` dataset.

## Usage

``` r
get_transcript_id(speaker = NULL, topic = NULL)
```

## Arguments

- speaker:

  Optional character vector of one or more standardized speaker names
  (e.g., `"montesinos"`, `c("alex kouri", "crousillat")`). If provided,
  only transcripts where all of these speakers are present are included.

- topic:

  Optional character vector of one or more topic names (e.g., `"media"`,
  `c("reelection", "state_capture")`). The `topic_` prefix is added
  automatically if not included. Only transcripts where all of these
  topics are flagged are included.

## Value

A sorted numeric vector of matching transcript IDs, or `numeric(0)` if
no transcript satisfies every filter.

## Details

When multiple speakers and/or topics are provided, all filters are
combined with AND logic: a transcript is included only if **every**
specified speaker appears in it **and** **every** specified topic is
flagged. Requesting a combination that never co-occurs returns an empty
vector.

## See also

[`read_transcripts()`](https://jessietrudeau.github.io/BribeR/reference/read_transcripts.md),
[`get_transcripts_raw()`](https://jessietrudeau.github.io/BribeR/reference/get_transcripts_raw.md),
[`get_transcript_speakers()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_speakers.md)

## Examples

``` r
# Retrieve all available transcript IDs
ids <- get_transcript_id()
head(ids)
#> [1] 1 2 3 4 5 6

# Retrieve transcript IDs where Montesinos appears
get_transcript_id(speaker = "montesinos")
#>  [1]   5   6   8   9  10  11  12  13  14  15  16  17  19  20  21  22  23  24  25
#> [20]  26  27  28  29  30  31  32  33  34  35  36  38  39  40  41  44  45  46  47
#> [39]  48  49  50  51  52  56  57  58  59  60  61  62  63  64  65  66  67  68  69
#> [58]  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88
#> [77]  89  90  94  95  96  97  98 102 103 104

# Retrieve transcript IDs where both Alex Kouri and Crousillat appear
get_transcript_id(speaker = c("alex kouri", "crousillat"))
#> [1] 76 82

# Retrieve transcript IDs about both media and reelection
get_transcript_id(topic = c("media", "reelection"))
#> [1]  35  39  62  79  87  88  97 103

# Combine: transcripts with Alex Kouri that are also about media
get_transcript_id(speaker = "alex kouri", topic = "media")
#> [1] 39 41 86
```
