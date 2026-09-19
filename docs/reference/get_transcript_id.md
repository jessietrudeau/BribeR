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
  (e.g., `"montesinos"`, `c("kouri", "crousillat")`). If provided,
  transcripts where any of these speakers are present will be included.

- topic:

  Optional character vector of one or more topic names (e.g., `"media"`,
  `c("reelection", "state_capture")`). The `topic_` prefix is added
  automatically if not included. Transcripts where any of these topics
  are flagged will be included.

## Value

A sorted numeric vector of matching transcript IDs.

## Details

When multiple speakers and/or topics are provided, all filters are
combined with OR logic: a transcript is included if **any** of the
specified speakers appear in it **or** **any** of the specified topics
are flagged.

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

# Retrieve transcript IDs where either Kouri or Crousillat appears
get_transcript_id(speaker = c("kouri", "crousillat"))
#> Error: Speaker(s) not found in transcript_index: kouri. Available speakers include: count, alva, lewis, burnet, garcia, alex kouri, ibarcena, montesinos, serpa, santander, ...

# Retrieve transcript IDs about media or reelection
get_transcript_id(topic = c("media", "reelection"))
#>  [1]   4   5   6   8   9  16  21  24  25  26  30  31  32  33  34  35  39  40  41
#> [20]  42  43  44  45  46  48  50  55  56  58  59  62  63  70  71  72  73  74  75
#> [39]  77  78  79  80  81  82  83  85  86  87  88  90  94  95  97 102 103

# Combine: transcripts with Kouri OR about media
get_transcript_id(speaker = "kouri", topic = "media")
#> Error: Speaker(s) not found in transcript_index: kouri. Available speakers include: count, alva, lewis, burnet, garcia, alex kouri, ibarcena, montesinos, serpa, santander, ...
```
