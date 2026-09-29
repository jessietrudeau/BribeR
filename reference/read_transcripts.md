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
#>      id row_id date     speaker_std speaker                      speech         
#>   <dbl>  <int> <chr>    <chr>       <chr>                        <chr>          
#> 1     1      1 1/8/1998 background  background                   Departamento d…
#> 2     1      2 1/8/1998 montesinos  el señor montesinos torres.- Un gusto en co…
#> 3     1      3 1/8/1998 menendez    el señor gonzalo.-           Encantado de c…
#> 4     1      4 1/8/1998 montesinos  el señor montesinos torres.- Siéntese.      
#> 5     1      5 1/8/1998 menendez    el señor gonzalo.-           Gracias， muy a…
#> 6     1      6 1/8/1998 montesinos  el señor montesinos torres.- Señor Borobio. 

# Load only transcript 1
t1 <- read_transcripts(transcripts = 1)

# Load transcripts 1, 8, and 13
subset <- read_transcripts(transcripts = c(1, 8, 13))
```
