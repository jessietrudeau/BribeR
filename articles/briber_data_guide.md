# BribeR Data Guide

The data available in **BribeR** includes cleaned and processed versions
of the raw transcript data described in the Raw Data Guide, as well as
companion metadata files to facilitate analysis. This vignette explains
what each dataset contains and how to combine them.

## Included data

### `compiled_transcripts`

This is the main dataset, containing every spoken line from all 99
transcripts, indexed by transcript number.[^1] Each row corresponds to
one speech turn within a transcript.

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

| Column        | Type      | Description                            |
|---------------|-----------|----------------------------------------|
| `id`          | numeric   | Transcript number                      |
| `row_id`      | numeric   | Row number within the transcript       |
| `date`        | character | Recording date                         |
| `speaker_std` | character | Standardized speaker identifier        |
| `speaker`     | character | Raw speaker label from the source file |
| `speech`      | character | Speech text (Spanish)                  |

`id` and `date` are transcript-level variables, while `row_id`
corresponds to the within-conversation turn identifier, and
`speaker_std` and `speaker` correspond to the standardized and unedited
text label for the speaker, respectively. The `speech` variable is
unedited and in its original Spanish-language format.

### `transcript_index`

This wide-format file contains one row per transcript, combining
descriptive metadata with binary indicator columns that take a value of
1 if the transcript is about the topics or if the speakers are present.
This file contains all transcript-level metadata in **BribeR**. Metadata
variable descriptions are shown in the below table.

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
| `id` | numeric | Transcript number |
| `file` | character | Source transcript filename (e.g. `"14.csv"`) |
| `format` | character | File format of the source transcript (e.g. `"csv"`) |
| `date` | date | Recording date |
| `original_id` | character | Original transcript number |
| `in_book` | integer | 1 if available in print book, 0 otherwise |
| `in_online_archive` | integer | 1 if available in the LUM online archive, 0 otherwise |
| `type` | character | Recording medium (`"audio"` or `"video"`) |
| `summary` | character | Transcript summary (in English, XXXX) |
| `speakers` | character | List of speaker names in the transcript |
| `n_speakers` | integer | Number of speakers in the transcript |
| `n_topics` | integer | Number of topics discussed in the transcript |
| `speaker_*` | integer | Speaker indicators (1/0) |
| `topic_*` | integer | Topic indicators (1/0) |

The 15 `topic_*` and 108 `speaker_*` columns take on a value of 1 if the
topic or speaker is present and a value of 0 otherwise. They are
designed for fast filtering for specific actors or topics without
loading the full corpus.

``` r

# 15 topics in the corpus
names(transcript_index)[grepl("^topic_", names(transcript_index))]
#>  [1] "topic_referendum"        "topic_ecuador"          
#>  [3] "topic_lucchetti_factory" "topic_municipal98"      
#>  [5] "topic_reelection"        "topic_miraflores"       
#>  [7] "topic_canal4"            "topic_media"            
#>  [9] "topic_promotions"        "topic_ivcher"           
#> [11] "topic_foreign"           "topic_wiese"            
#> [13] "topic_public_officials"  "topic_security"         
#> [15] "topic_state_capture"
```

### `speakers_per_transcript`

This file contains one row per transcript, allowing users to quickly
search for the speakers present during any one conversation. The
standardized speaker name `speaker_std` is used to indicate which actors
are present for each conversation, sorted by chronological speaking
order. There is a minimum of 1 speaker per conversation and a maximum of
19.

``` r

# Who was present in the first three conversations?
speakers_per_transcript %>% 
  slice(1:3)
#> # A tibble: 3 × 20
#>      id speaker_std_1 speaker_std_2 speaker_std_3 speaker_std_4 speaker_std_5
#>   <dbl> <chr>         <chr>         <chr>         <chr>         <chr>        
#> 1     1 alva          lewis         burnet        garcia        NA           
#> 2    10 alex kouri    ibarcena      montesinos    serpa         santander    
#> 3   100 de lopez      smith         NA            NA            NA           
#> # ℹ 14 more variables: speaker_std_6 <chr>, speaker_std_7 <chr>,
#> #   speaker_std_8 <chr>, speaker_std_9 <chr>, speaker_std_10 <chr>,
#> #   speaker_std_11 <chr>, speaker_std_12 <chr>, speaker_std_13 <chr>,
#> #   speaker_std_14 <chr>, speaker_std_15 <chr>, speaker_std_16 <chr>,
#> #   speaker_std_17 <chr>, speaker_std_18 <chr>, speaker_std_19 <chr>
```

### `actors`

This file contains biographical and institutional metadata for 118
individuals named in the transcripts. The variable names are shown in
the below table.

``` r

head(actors)
#> # A tibble: 6 × 7
#>   speaker                      position type  party speaker_std notes is_speaker
#>   <chr>                        <chr>    <chr> <chr> <chr>       <chr>      <int>
#> 1 vladimir montesinos          Head of… mont… NA    montesinos   NA            1
#> 2 desconocido                  NA       NA    NA    desconocido  NA            1
#> 3 alexander martin kouri buma… Elected… cong… Part… alex kouri   NA            1
#> 4 lucchetti                    Company… busi… NA    lucchetti   "Luc…          1
#> 5 carlos eduardo ferrero costa Congres… cong… Camb… ferrero     "Mul…          1
#> 6 alberto fujimori             Preside… elec… NA    fujimori     NA            1
```

| Column | Type | Description |
|----|----|----|
| `speaker` | character | Speaker’s full name |
| `speaker_std` | character | Standardized speaker identifier |
| `position` | character | Short description of the speaker’s position |
| `type` | charater | One of 11 categories described in the [Raw Data Guide](https://jessietrudeau.com/BribeR/articles/raw_data_guide.html): `montesinos`, `security`, `congress`, `judiciary`, `media`, `businessperson`, `elected official`, `bureaucrat`, `foreign`,`illicit`, and unknown (`NA`). |
| `party` | character | For elected officials, the political party at the time of the recording (consistent with [V-Dem](https://www.v-dem.net/) party labels) |
| `notes` | character | Miscellaneous notes for actors that were difficult to identify |
| `is_speaker` | integer | 1 if the individual has at least one speech turn in the corpus, 0 if they are named in the archive but never recorded speaking. Only those with `is_speaker == 1` can be filtered with [`get_transcript_id()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_id.md) |

For example, the file contains this biographical information about some
of the speakers from Fujimori’s party:

``` r

actors %>%
  filter(type == "congress") %>%
  select(speaker, speaker_std, position, type, party) %>% 
  slice(3:5)
#> # A tibble: 3 × 5
#>   speaker               speaker_std position              type     party        
#>   <chr>                 <chr>       <chr>                 <chr>    <chr>        
#> 1 rafael urrelo guerra  urrelo      Congressman 1995-2000 congress Cambio 90_Nu…
#> 2 carlos blanco oropeza blanco      Congressman 1995-2000 congress Cambio 90_Nu…
#> 3 jorge trelles montero trelles     Congressman 1995-2000 congress Cambio 90_Nu…
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
Torres” and “El Señor M. Torres” both correspond to `montesinos`). It is
a standardized lowercase identifier for each speaker, consistent across
all transcripts. Use `speaker_std` rather than the raw `speaker` column
for joins and filters.

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
#> [6] "notes"       "is_speaker"
```

[^1]: We generate a new number within the BribeR package, see the
    [id](https://jessietrudeau.com/BribeR/articles/briber_data_guide.html#id)
    subsection for more information.
