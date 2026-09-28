# Read Vladivideos Transcript Data

Loads the bundled `compiled_transcripts` dataset and optionally filters
by transcript ID(s).

## Usage

``` r
read_transcripts(transcripts = NULL)
```

## Arguments

- transcripts:

  Optional numeric vector of transcript IDs to keep. If `NULL` (the
  default), all transcripts are returned.

## Value

A data frame with columns `id`, `row_id`, `date`, `speaker_std`,
`speaker`, and `speech`.

## See also

[`get_transcripts_raw()`](https://jessietrudeau.github.io/BribeR/reference/get_transcripts_raw.md),
[`get_transcript_id()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_id.md),
[`get_transcript_speakers()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_speakers.md)

## Examples

``` r
# Load all transcripts
all <- read_transcripts()
head(all)
#> # A tibble: 6 × 6
#>      id row_id date      speaker_std speaker                              speech
#>   <dbl>  <int> <chr>     <chr>       <chr>                                <chr> 
#> 1    10      1 1/28/1998 background  background                           Depar…
#> 2    10      2 1/28/1998 alex kouri  el señor kouri bumachar, alexander.— Tú lo…
#> 3    10      3 1/28/1998 ibarcena    el señor ibárcena amico.—            (Inin…
#> 4    10      4 1/28/1998 alex kouri  el señor kouri bumachar, alexander.— Me pa…
#> 5    10      5 1/28/1998 ibarcena    el señor ibárcena amico.—            (Inin…
#> 6    10      6 1/28/1998 alex kouri  el señor kouri bumachar, alexander.— Con m…

# Load only transcript 1
t1 <- read_transcripts(transcripts = 1)
#> Warning: No transcripts found matching IDs: 1

# Load transcripts 5, 7, and 13
subset <- read_transcripts(transcripts = c(5, 7, 13))
```
