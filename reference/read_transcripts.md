# Read Vladivideos Transcript Data

Loads the bundled `vladivideos_detailed` dataset and optionally filters
by transcript ID(s).

## Usage

``` r
read_transcripts(transcripts = NULL)
```

## Arguments

- transcripts:

  Optional numeric vector of transcript IDs (`n`) to keep. If `NULL`
  (the default), all transcripts are returned.

## Value

A data frame with columns `n`, `row_id`, `date`, `speaker`, `speech`,
`speaker_std`, and `topic`.

## See also

[`get_transcripts_raw()`](https://github.com/jessietrudeau/BribeR/reference/get_transcripts_raw.md),
[`get_transcript_id()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_id.md),
[`get_transcript_speakers()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_speakers.md)

## Examples

``` r
# Load all transcripts
all <- read_transcripts()
head(all)
#> # A tibble: 6 × 7
#>       n row_id date      speaker              speech           speaker_std topic
#>   <dbl>  <int> <chr>     <chr>                <chr>            <chr>       <chr>
#> 1     1      1 3/25/1997 BACKGROUND           ﻿Declaraciones …  BACKGROUND  topi…
#> 2     1      2 3/25/1997 BACKGROUND           [La entrevista … BACKGROUND  topi…
#> 3     1      3 3/25/1997 La señora            Levante su mano… ALVA        topi…
#> 4     1      4 3/25/1997 El señor Javier Alva Sí.              ALVA        topi…
#> 5     1      5 3/25/1997 El señor Neil Lewis  Señor Alva, mi … LEWIS       topi…
#> 6     1      6 3/25/1997 El señor Javier Alva Javier Alva Orl… ALVA        topi…

# Load only transcript 1
t1 <- read_transcripts(transcripts = 1)

# Load transcripts 5, 7, and 13
subset <- read_transcripts(transcripts = c(5, 7, 13))
```
