# BribeR Data Guide

The data available in **BribeR** includes cleaned and processed versions
of the raw transcript data described in the Raw Data Guide, as well as
companion metadata files to facilitate analysis. This vignette explains
what each dataset contains and how to combine them.

## Included data

### `compiled_transcripts`

This is the main dataset, containing every spoken line from all 101
transcripts, indexed by (OUR/THEIR) transcript number. Each row
corresponds to one speech turn within a transcript.

``` r

library(BribeR)
library(dplyr)

transcripts <- read_transcripts()
glimpse(transcripts)
#> Rows: 47,375
#> Columns: 7
#> $ n           <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ row_id      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,…
#> $ date        <chr> "3/25/1997", "3/25/1997", "3/25/1997", "3/25/1997", "3/25/…
#> $ speaker     <chr> "BACKGROUND", "BACKGROUND", "La señora", "El señor Javier …
#> $ speech      <chr> "﻿Declaraciones de Víctor Andrés García Belaunde y Javier …
#> $ speaker_std <chr> "BACKGROUND", "BACKGROUND", "ALVA", "ALVA", "LEWIS", "ALVA…
#> $ topic       <chr> "topic_foreign", "topic_foreign", "topic_foreign", "topic_…
```

| Column        | Type      | Description                             |
|---------------|-----------|-----------------------------------------|
| `id`          | numeric   | Transcript identifier                   |
| `row_id`      | numeric   | Row number within the transcript        |
| `date`        | character | Recording date                          |
| `speaker_std` | character | Standardized speaker identifier         |
| `speaker`     | character | Raw speaker label from the source       |
| `speech`      | character | Speech text (Spanish)                   |
| `topic`       | character | Primary(?) topic tag for the transcript |

`id`, `date`, and `topic` are transcript-level variables, while `row_id`
corresponds to the within-conversation turn identifier, and
`speaker_std` and `speaker` correspond to the standardized and unedited
text label for the speaker, respectively. The `speech` variable is
unedited and in its original Spanish-language format.

### `transcript_index`

This wide-format file contains transcript-level metadata, including date
of the recording, recording type (AUDIO OR VIDEO?), short English
summaries, topic indicators, speaker indicators.

``` r

head(descriptions[, c("n", "date", "type", "summary")])
#> # A tibble: 6 × 4
#>       n date      type  summary                                                 
#>   <dbl> <chr>     <chr> <chr>                                                   
#> 1   104 7/1/2000  audio Montesinos convenes a meeting with police and military …
#> 2    19 4/21/1998 video This transcript covers General Barry McCaffrey’s third …
#> 3    11 2/10/1998 audio Montesinos and Lucchetti share lunch and discuss politi…
#> 4    12 2/10/1998 audio Montesinos and Lucchetti share lunch and discuss politi…
#> 5     5 1/8/1998  video Montesinos meets with Daniel Borobio and Sr. Gonzalo, a…
#> 6     7 1/15/1998 video Montesinos, Luz Salgado, and Absalón Vásquez discuss st…
```

| Column      | Type    | Description                  |
|-------------|---------|------------------------------|
| `id`        | numeric | Transcript identifier        |
| `id_raw`    | numeric | Source transcript identifier |
| ….          | numeric | FILL IN THE REST OF TABLE…   |
| ….          | numeric | FILL IN THE REST OF TABLE…   |
| ….          | numeric | FILL IN THE REST OF TABLE…   |
| `topic_*`   | numeric | Topic indicators             |
| `speaker_*` | numeric | Speaker indicators           |

The 15 `topic_*` and 125 `speaker_*` columns take on a value of 1 if the
topic or speaker is present and a value of 0 otherwise. They are
designed for fast filtering for specific actors or topics without
loading the full corpus.

``` r

names(descriptions)[grepl("^topic_", names(descriptions))] 
#>  [1] "topic_referendum"        "topic_ecuador"          
#>  [3] "topic_lucchetti_factory" "topic_municipal98"      
#>  [5] "topic_reelection"        "topic_miraflores"       
#>  [7] "topic_canal4"            "topic_media"            
#>  [9] "topic_promotions"        "topic_ivcher"           
#> [11] "topic_foreign"           "topic_wiese"            
#> [13] "topic_public_officials"  "topic_safety"           
#> [15] "topic_state_capture"
```

### `speakers_per_transcript`

This file contains one row per transcript, allowing users to quickly
search for the speakers present during any one conversation. The
standardized speaker name `speaker_std` is used to indicate which actors
are present for each conversation, sorted by chronological speaking
order (?).

``` r

# Who was present in conversation 3? 
speakers_per_transcript[3, ]
#> # A tibble: 1 × 20
#>       n speakrer_std_1 speakrer_std_2 speakrer_std_3 speakrer_std_4
#>   <dbl> <chr>          <chr>          <chr>          <chr>         
#> 1   100 DE LOPEZ       SMITH          NA             NA            
#> # ℹ 15 more variables: speakrer_std_5 <chr>, speakrer_std_6 <chr>,
#> #   speakrer_std_7 <chr>, speakrer_std_8 <chr>, speakrer_std_9 <chr>,
#> #   speakrer_std_10 <chr>, speakrer_std_11 <chr>, speakrer_std_12 <chr>,
#> #   speakrer_std_13 <chr>, speakrer_std_14 <chr>, speakrer_std_15 <chr>,
#> #   speakrer_std_16 <chr>, speakrer_std_17 <chr>, speakrer_std_18 <chr>,
#> #   speakrer_std_19 <chr>
```

**ANDRES: FIX THIS IN THE RAW DATA – Note: the column names contain a
known typo (`speakrer` instead of `speaker`) preserved from the source
data. The package handles this automatically in all functions.**

### `actors`

This file contains biographical and institutional metadata for 125
individuals named in the transcripts.

``` r

head(actors[, c("speaker", "Position", "Type", "speaker_std")])
#> # A tibble: 6 × 4
#>   speaker                         Position                     Type  speaker_std
#>   <chr>                           <chr>                        <chr> <chr>      
#> 1 Vladimir Montesinos             Alberto Fujimori's Chief os… Secu… MONTESINOS 
#> 2 Desconocido                     NA                           NA    DESCONOCIDO
#> 3 Alexander Martin Kouri Bumachar Elected Constituent Congres… Cong… ALEX KOURI 
#> 4 Lucchetti                       Company specialized in past… Busi… LUCCHETTI  
#> 5 Carlos Eduardo Ferrero Costa    Congressman (1995-2000)      Cong… FERRERO    
#> 6 Alberto Fujimori                President of Peru (1990-200… Elec… FUJIMORI
```

The `Type` column references the categories described in the Raw Data
Guide: `Montesinos`, `Security`, `Congress`, `Judiciary`, `Media`,
`Businessperson`, `Elected Official`, `Bureaucrat`, `Foreign`, and
`Illicit`.

For elected officials, the political party at the time of the recording
is also included, **CONSISTENT WITH V-DEM PARTY LABELS(?)**

``` r

actors %>% 
  filter(Type == "Congress") %>% 
  select(speaker_std, Type, Party) %>% 
  slice_head()
#> # A tibble: 1 × 3
#>   speaker_std Type     Party                          
#>   <chr>       <chr>    <chr>                          
#> 1 ALEX KOURI  Congress Partido Popular Cristiano (PPC)
```

## Linking datasets

Full-text transcript data and metadata can be linked by using `id` or
`speaker_std` as a crosswalk. The table below shows which columns
connect the datasets:

| From                   | To                        | Key column    |
|------------------------|---------------------------|---------------|
| `compiled_transcripts` | `transcript_index`        | `id`          |
| `compiled_transcripts` | `speakers_per_transcript` | `id`          |
| `compiled_transcripts` | `actors`                  | `speaker_std` |

### `id`

The `id` column is unique to **BribeR** and assigns a unique numeric
identifier to each transcript. The original transcript numbers (e.g.,
from the the Peruvian Congress’ numbering system) are included in the
`transcript_index` metadata file, but given that many are alphanumeric
identifiers, **BribeR** generates new a new `id` variable for
simplicity.

``` r

## id column, crossed with original id and source
descriptions %>% 
  select(n, original_n, in_book, in_online_archive) %>% 
  slice_head()
#> # A tibble: 1 × 4
#>       n original_n in_book in_online_archive
#>   <dbl> <chr>      <chr>   <chr>            
#> 1   104 353        x       NA
```

### `speaker_std`

The `speaker_std` column resolves naming variation from the original
source material, which often varies from transcript to transcript and
can frustrate attempts at string matching (e.g. “el Señor Montesinos
Torres” to “El Señor M. Torres”). It is a standardized lowercase
identifier for each speaker, consistent across all transcripts. Use
`speaker_std` rather than the raw `speaker` column for joins and
filters.

``` r

## add comment 
transcripts |>
  filter(speaker_std == "MONTESINOS") |>
  summarise(n_turns = n())
#> # A tibble: 1 × 1
#>   n_turns
#>     <int>
#> 1   16609
```

## Accessing data directly

All datasets are lazily loaded when the package is attached, so you can
reference them by name after
[`library(BribeR)`](https://jessietrudeau.github.io/BribeR):

``` r

nrow(compiled_transcripts)
#> [1] 47375
names(actors)
#> [1] "speaker"     "Position"    "Type"        "Party"       "speaker_std"
#> [6] "notes"
```
