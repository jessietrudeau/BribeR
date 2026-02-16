# Get transcripts each speaker appears in

Loads the bundled `speakers_per_transcript` dataset and returns one row
per unique speaker with a list-column of transcript IDs (`n`) where that
speaker appears.

## Usage

``` r
get_transcript_speakers()
```

## Value

A tibble with columns:

- `speaker_std` (character): standardized speaker identifier

- `transcripts` (list): sorted numeric vector of transcript IDs where
  the speaker appears

## See also

[`read_transcripts()`](https://github.com/jessietrudeau/BribeR/reference/read_transcripts.md),
[`get_transcript_id()`](https://github.com/jessietrudeau/BribeR/reference/get_transcript_id.md),
[`get_transcripts_raw()`](https://github.com/jessietrudeau/BribeR/reference/get_transcripts_raw.md)

## Examples

``` r
# Get all speakers and their transcript appearances
speakers <- get_transcript_speakers()
head(speakers)
#> # A tibble: 6 × 2
#>   speaker_std   transcripts
#>   <chr>         <list>     
#> 1 ALBARRACíN    <dbl [2]>  
#> 2 ALBERTO KOURI <dbl [1]>  
#> 3 ALEX KOURI    <dbl [4]>  
#> 4 ALVA          <dbl [1]>  
#> 5 AMERICANO     <dbl [2]>  
#> 6 AMOIN         <dbl [1]>  
```
