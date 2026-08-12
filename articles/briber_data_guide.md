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
#> Rows: 46,597
#> Columns: 6
#> $ id          <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ row_id      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,…
#> $ date        <chr> "3/25/1997", "3/25/1997", "3/25/1997", "3/25/1997", "3/25/…
#> $ speaker_std <chr> "background", "background", "alva", "alva", "lewis", "alva…
#> $ speaker     <chr> "background", "background", "la señora", "el señor javier …
#> $ speech      <chr> "﻿Declaraciones de Víctor Andrés García Belaunde y Javier …
```

| Column        | Type      | Description                       |
|---------------|-----------|-----------------------------------|
| `id`          | numeric   | Transcript identifier             |
| `row_id`      | numeric   | Row number within the transcript  |
| `date`        | character | Recording date                    |
| `speaker_std` | character | Standardized speaker identifier   |
| `speaker`     | character | Raw speaker label from the source |
| `speech`      | character | Speech text (Spanish)             |

`id` and `date` are transcript-level variables, while `row_id`
corresponds to the within-conversation turn identifier, and
`speaker_std` and `speaker` correspond to the standardized (lowercase)
and unedited text label for the speaker, respectively. The `speech`
variable is unedited and in its original Spanish-language format.

### `transcript_index`

This wide-format file contains one row per transcript, combining
descriptive metadata with binary indicator columns for topics and
speakers. It is the primary lookup table for filtering the corpus, and
the single source of transcript-level metadata in **BribeR** — there is
no separate `descriptions` dataset. Descriptive columns come first,
followed by speaker/topic counts, followed by the `speaker_*` and
`topic_*` indicator columns.

``` r

head(transcript_index[, c("id", "file", "format", "date", "original_id", "type", "summary")])
#> # A tibble: 6 × 7
#>      id file  format date       original_id type  summary                       
#>   <int> <chr> <chr>  <date>     <chr>       <chr> <chr>                         
#> 1     1 1.csv csv    1997-03-25 1014-1015   audio "In Florida, Javier Alva Orla…
#> 2     2 2.csv csv    1997-03-26 1016        video "Former Prime Minister Luis P…
#> 3     3 3.csv csv    1997-03-26 1017        video "Pablo Lupis Cid, manager of …
#> 4     4 4.csv csv    1997-06-13 s/n         video "This official propaganda vid…
#> 5     5 5.csv csv    1998-01-08 864         video "Montesinos meets with Daniel…
#> 6     6 6.csv csv    1998-01-12 1312        video "Montesinos records a prison …
```

| Column | Type | Description |
|----|----|----|
| `id` | numeric | Transcript identifier (BribeR internal numbering) |
| `file` | character | Source transcript filename (e.g. `"14.csv"`) |
| `format` | character | File format of the source transcript (e.g. `"csv"`) |
| `date` | date | Recording date |
| `original_id` | character | Original source archive identifier |
| `in_book` | integer | 1 if cited in published work, 0 otherwise |
| `in_online_archive` | integer | 1 if available in the online archive, 0 otherwise |
| `type` | character | Recording medium (`"audio"` or `"video"`) |
| `summary` | character | Plain-language English summary |
| `speakers` | character | Free-text description of participants |
| `speaker_count` | integer | Total distinct speakers in the transcript |
| `topic_count` | integer | Total topics flagged for the transcript |
| `speaker_*` | integer | Speaker indicators (1/0) |
| `topic_*` | integer | Topic indicators (1/0) |

The 15 `topic_*` and 113 `speaker_*` columns take on a value of 1 if the
topic or speaker is present and a value of 0 otherwise. They are
designed for fast filtering for specific actors or topics without
loading the full corpus.

``` r

names(transcript_index)[grepl("^topic_", names(transcript_index))]
#>  [1] "topic_count"             "topic_referendum"       
#>  [3] "topic_ecuador"           "topic_lucchetti_factory"
#>  [5] "topic_municipal98"       "topic_reelection"       
#>  [7] "topic_miraflores"        "topic_canal4"           
#>  [9] "topic_media"             "topic_promotions"       
#> [11] "topic_ivcher"            "topic_foreign"          
#> [13] "topic_wiese"             "topic_public_officials" 
#> [15] "topic_security"          "topic_state_capture"
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
#>      id speaker_std_1 speaker_std_2 speaker_std_3 speaker_std_4 speaker_std_5
#>   <dbl> <chr>         <chr>         <chr>         <chr>         <chr>        
#> 1   100 de lopez      smith         NA            NA            NA           
#> # ℹ 14 more variables: speaker_std_6 <chr>, speaker_std_7 <chr>,
#> #   speaker_std_8 <chr>, speaker_std_9 <chr>, speaker_std_10 <chr>,
#> #   speaker_std_11 <chr>, speaker_std_12 <chr>, speaker_std_13 <chr>,
#> #   speaker_std_14 <chr>, speaker_std_15 <chr>, speaker_std_16 <chr>,
#> #   speaker_std_17 <chr>, speaker_std_18 <chr>, speaker_std_19 <chr>
```

### `actors`

This file contains biographical and institutional metadata for 125
individuals named in the transcripts.

``` r

head(actors[, c("speaker", "position", "type", "speaker_std")])
#> # A tibble: 6 × 4
#>   speaker                         position                     type  speaker_std
#>   <chr>                           <chr>                        <chr> <chr>      
#> 1 vladimir montesinos             Head of National Intelligen… mont… montesinos 
#> 2 desconocido                     NA                           NA    desconocido
#> 3 alexander martin kouri bumachar Elected Constituent Congres… cong… alex kouri 
#> 4 lucchetti                       Company specialized in past… busi… lucchetti  
#> 5 carlos eduardo ferrero costa    Congressman (1995-2000)      cong… ferrero    
#> 6 alberto fujimori                President of Peru (1990-200… elec… fujimori
```

The `type` column references the categories described in the Raw Data
Guide: `montesinos`, `security`, `congress`, `judiciary`, `media`,
`businessperson`, `elected official`, `bureaucrat`, `foreign`, and
`illicit`. Vladimiro Montesinos is kept in his own `montesinos` category
rather than being grouped under `security`.

For elected officials, the political party at the time of the recording
is also included, **CONSISTENT WITH V-DEM PARTY LABELS(?)**

``` r

actors %>%
  filter(type == "congress") %>%
  select(speaker_std, type, party) %>%
  slice_head()
#> # A tibble: 1 × 3
#>   speaker_std type     party                          
#>   <chr>       <chr>    <chr>                          
#> 1 alex kouri  congress Partido Popular Cristiano (PPC)
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
| `transcript_index`     | `speakers_per_transcript` | `id`          |

### `id`

The `id` column is unique to **BribeR** and assigns a unique numeric
identifier to each transcript. The original transcript numbers (e.g.,
from the the Peruvian Congress’ numbering system) are included in the
`transcript_index` metadata file, but given that many are alphanumeric
identifiers, **BribeR** generates new a new `id` variable for
simplicity.

``` r

## id column, crossed with original id and source
transcript_index %>%
  select(id, original_id, in_book, in_online_archive) %>%
  slice_head()
#> # A tibble: 1 × 4
#>      id original_id in_book in_online_archive
#>   <int> <chr>         <int>             <int>
#> 1     1 1014-1015         1                 0
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

# Count Montesinos's speaking turns across all transcripts
transcripts |>
  filter(speaker_std == "montesinos") |>
  summarise(n_turns = n())
#> # A tibble: 1 × 1
#>   n_turns
#>     <int>
#> 1   16335
```

## Accessing data directly

All datasets are lazily loaded when the package is attached, so you can
reference them by name after
[`library(BribeR)`](https://jessietrudeau.github.io/BribeR):

``` r

nrow(compiled_transcripts)
#> [1] 46597
names(actors)
#> [1] "speaker"     "position"    "type"        "party"       "speaker_std"
#> [6] "notes"
```
