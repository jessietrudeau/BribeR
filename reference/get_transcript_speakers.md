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
#>   speaker_std   transcripts
#>   <chr>         <list>     
#> 1 albarracin    <dbl [2]>  
#> 2 alberto kouri <dbl [1]>  
#> 3 alex kouri    <dbl [11]> 
#> 4 alva          <dbl [1]>  
#> 5 americano     <dbl [2]>  
#> 6 amoin         <dbl [1]>  

# Get speakers from specific transcripts
get_transcript_speakers(n = c(1, 5))
#> # A tibble: 9 × 2
#>   speaker_std      transcripts
#>   <chr>            <list>     
#> 1 alva             <dbl [1]>  
#> 2 borobio          <dbl [1]>  
#> 3 burnet           <dbl [1]>  
#> 4 garcia           <dbl [1]>  
#> 5 hernandez canelo <dbl [1]>  
#> 6 lewis            <dbl [1]>  
#> 7 montesinos       <dbl [1]>  
#> 8 serpa            <dbl [1]>  
#> 9 valle riestra    <dbl [1]>  

# Get speakers from transcripts about media
get_transcript_speakers(topic = "media")
#> # A tibble: 51 × 2
#>    speaker_std   transcripts
#>    <chr>         <list>     
#>  1 alberto kouri <dbl [1]>  
#>  2 alex kouri    <dbl [3]>  
#>  3 arancibia     <dbl [1]>  
#>  4 arce          <dbl [2]>  
#>  5 bello vazquez <dbl [1]>  
#>  6 borobio       <dbl [3]>  
#>  7 bringas       <dbl [1]>  
#>  8 calmell       <dbl [4]>  
#>  9 campos        <dbl [1]>  
#> 10 chirinos      <dbl [1]>  
#> # ℹ 41 more rows

# Get speakers from transcripts about both media and reelection
get_transcript_speakers(topic = c("media", "reelection"))
#> # A tibble: 20 × 2
#>    speaker_std       transcripts
#>    <chr>             <list>     
#>  1 alberto kouri     <dbl [1]>  
#>  2 alex kouri        <dbl [1]>  
#>  3 arce              <dbl [2]>  
#>  4 bello vazquez     <dbl [1]>  
#>  5 bringas           <dbl [1]>  
#>  6 chirinos          <dbl [1]>  
#>  7 crousillat        <dbl [1]>  
#>  8 delgado parker    <dbl [1]>  
#>  9 doufour           <dbl [1]>  
#> 10 hernandez canelo  <dbl [2]>  
#> 11 ibarcena          <dbl [2]>  
#> 12 joy way           <dbl [1]>  
#> 13 locutor           <dbl [1]>  
#> 14 manuel lopez      <dbl [1]>  
#> 15 montes de oca     <dbl [1]>  
#> 16 montesinos        <dbl [8]>  
#> 17 romero seminario  <dbl [1]>  
#> 18 serpa             <dbl [1]>  
#> 19 tudela            <dbl [1]>  
#> 20 villanueva ruesta <dbl [1]>  

# Get speakers from transcript 4, which is also about media
get_transcript_speakers(n = 4, topic = "media")
#> # A tibble: 2 × 2
#>   speaker_std transcripts
#>   <chr>       <list>     
#> 1 locutor     <dbl [1]>  
#> 2 moncayo     <dbl [1]>  
```
