# Get transcripts each speaker appears in

Loads the bundled `speakers_per_transcript` dataset and returns one row
per unique speaker with a list-column of transcript IDs (`n`) where that
speaker appears. Optionally filters to only transcripts matching
specific IDs and/or topics.

## Usage

``` r
get_transcript_speakers(n = NULL, topic = NULL)
```

## Arguments

- n:

  Optional numeric vector of transcript IDs to restrict results to
  (e.g., `1`, `c(1, 5, 10)`).

- topic:

  Optional character vector of one or more topic names (e.g., `"media"`,
  `c("reelection", "state_capture")`). The `topic_` prefix is added
  automatically if not included. Only transcripts where all of these
  topics are flagged are included.

## Value

A tibble with columns:

- `speaker_std` (character): standardized speaker identifier

- `transcripts` (list): sorted numeric vector of transcript IDs where
  the speaker appears

## Details

All filters are combined with AND logic: a transcript contributes
speakers only if it matches the specified IDs **and** has **every**
specified topic flagged. When only one filter is provided, it is applied
alone. When neither is provided, all speakers across all transcripts are
returned. Requesting a combination that never co-occurs returns a
zero-row tibble.

## See also

[`read_transcripts()`](https://jessietrudeau.github.io/BribeR/reference/read_transcripts.md),
[`get_transcript_id()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_id.md),
[`get_transcripts_raw()`](https://jessietrudeau.github.io/BribeR/reference/get_transcripts_raw.md)

## Examples

``` r
# Get all speakers and their transcript appearances
speakers <- get_transcript_speakers()
head(speakers)
#> # A tibble: 6 × 2
#>   speaker_std      transcripts
#>   <chr>            <list>     
#> 1 aguirre          <dbl [1]>  
#> 2 albarracin       <dbl [2]>  
#> 3 alberto kouri    <dbl [1]>  
#> 4 alex kouri       <dbl [7]>  
#> 5 alvarado cabrera <dbl [1]>  
#> 6 americano        <dbl [1]>  

# Get speakers from specific transcripts
get_transcript_speakers(n = c(1, 5))
#> # A tibble: 9 × 2
#>   speaker_std transcripts
#>   <chr>       <list>     
#> 1 alex kouri  <dbl [1]>  
#> 2 borobio     <dbl [1]>  
#> 3 colunge     <dbl [1]>  
#> 4 desconocido <dbl [2]>  
#> 5 huaman      <dbl [1]>  
#> 6 ibarcena    <dbl [1]>  
#> 7 menendez    <dbl [1]>  
#> 8 montesinos  <dbl [2]>  
#> 9 solis       <dbl [1]>  

# Get speakers from transcripts about media
get_transcript_speakers(topic = "media")
#> # A tibble: 60 × 2
#>    speaker_std   transcripts
#>    <chr>         <list>     
#>  1 alex kouri    <dbl [4]>  
#>  2 arancibia     <dbl [1]>  
#>  3 arce          <dbl [1]>  
#>  4 bedoya        <dbl [2]>  
#>  5 bello vasquez <dbl [3]>  
#>  6 bertini       <dbl [2]>  
#>  7 bolona        <dbl [1]>  
#>  8 borobio       <dbl [3]>  
#>  9 bringas       <dbl [1]>  
#> 10 calmell       <dbl [5]>  
#> # ℹ 50 more rows

# Get speakers from transcripts about both media and reelection
get_transcript_speakers(topic = c("media", "reelection"))
#> # A tibble: 23 × 2
#>    speaker_std        transcripts
#>    <chr>              <list>     
#>  1 alex kouri         <dbl [2]>  
#>  2 arce               <dbl [1]>  
#>  3 bello vasquez      <dbl [3]>  
#>  4 bolona             <dbl [1]>  
#>  5 bringas            <dbl [1]>  
#>  6 calmell            <dbl [1]>  
#>  7 campos             <dbl [1]>  
#>  8 chirinos           <dbl [1]>  
#>  9 crnl ramirez       <dbl [1]>  
#> 10 crousillat carreno <dbl [1]>  
#> # ℹ 13 more rows

# Get speakers from transcript 2, which is also about media
get_transcript_speakers(n = 2, topic = "media")
#> # A tibble: 2 × 2
#>   speaker_std transcripts
#>   <chr>       <list>     
#> 1 montesinos  <dbl [1]>  
#> 2 ricketts    <dbl [1]>  
```
