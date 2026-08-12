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
#>      id row_id date      speaker_std speaker              speech                
#>   <dbl>  <int> <chr>     <chr>       <chr>                <chr>                 
#> 1     1      1 3/25/1997 background  background           ﻿Declaraciones de Víc… 
#> 2     1      2 3/25/1997 background  background           [La entrevista se rea…
#> 3     1      3 3/25/1997 alva        la señora            Levante su mano derec…
#> 4     1      4 3/25/1997 alva        el señor javier alva Sí.                   
#> 5     1      5 3/25/1997 lewis       el señor neil lewis  Señor Alva, mi nombre…
#> 6     1      6 3/25/1997 alva        el señor javier alva Javier Alva Orlandini.

# Load only transcript 1
t1 <- read_transcripts(transcripts = 1)

# Load transcripts 5, 7, and 13
subset <- read_transcripts(transcripts = c(5, 7, 13))
```
