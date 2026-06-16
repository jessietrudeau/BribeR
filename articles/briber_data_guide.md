# BribeR Data Guide

## Overview

BribeR bundles seven datasets that together describe the Vladivideos
corpus from different angles. This article explains what each dataset
contains, which columns they share, and how to combine them for
analysis.

## The Seven Datasets

### `compiled_transcripts` — Full Corpus

The main dataset. Each row is one speech turn within a transcript.

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

| Column        | Type      | Description                          |
|---------------|-----------|--------------------------------------|
| `n`           | numeric   | Transcript identifier                |
| `row_id`      | numeric   | Row number within the transcript     |
| `date`        | character | Recording date                       |
| `speaker`     | character | Raw speaker label from the source    |
| `speech`      | character | Speech text (Spanish)                |
| `speaker_std` | character | Standardized speaker identifier      |
| `topic`       | character | Primary topic tag for the transcript |

The `speaker_std` column is the key linking column across all datasets.
It uses uppercase surnames and is consistent with the `actors`,
`speakers_per_transcript`, and `transcript_index` datasets.

### `descriptions` — Transcript Metadata

One row per transcript. Contains dates, topic flags, availability
information, and plain-language English summaries.

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

The `topic_*` columns use `"x"` to indicate a topic is present:

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

### `transcript_index` — Fast Lookup Table

A wide-format boolean table with one row per transcript and one column
per speaker and per topic. Designed for fast filtering without loading
the full corpus.

``` r

dim(transcript_index)
#> [1] 101 134
```

The `speaker_*` and `topic_*` columns contain `1` (present) or `0`
(absent). This is the dataset used internally by
[`get_transcript_id()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_id.md).

### `speakers_per_transcript` — Speaker Roster

One row per transcript, with up to 19 speaker slots as separate columns.

``` r

speakers_per_transcript[1, ]
#> # A tibble: 1 × 20
#>       n speakrer_std_1 speakrer_std_2 speakrer_std_3 speakrer_std_4
#>   <dbl> <chr>          <chr>          <chr>          <chr>         
#> 1     1 ALVA           LEWIS          BURNET         GARCIA        
#> # ℹ 15 more variables: speakrer_std_5 <chr>, speakrer_std_6 <chr>,
#> #   speakrer_std_7 <chr>, speakrer_std_8 <chr>, speakrer_std_9 <chr>,
#> #   speakrer_std_10 <chr>, speakrer_std_11 <chr>, speakrer_std_12 <chr>,
#> #   speakrer_std_13 <chr>, speakrer_std_14 <chr>, speakrer_std_15 <chr>,
#> #   speakrer_std_16 <chr>, speakrer_std_17 <chr>, speakrer_std_18 <chr>,
#> #   speakrer_std_19 <chr>
```

Note: the column names contain a known typo (`speakrer` instead of
`speaker`) preserved from the source data. The package handles this
automatically in all functions.

### `actors` — Actor Roster

Biographical and institutional metadata for 125 individuals named in the
transcripts.

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

The `Type` column classifies actors into institutional categories:
`Security`, `Congress`, `Judiciary`, `Media`, `Businessperson`,
`Elected Official`, `Bureaucrat`, `Foreign`, and `Illicit`.

The `speaker_std` column links to `compiled_transcripts`,
`transcript_index`, and `speakers_per_transcript`.

### `actors_description` — Actor Descriptions

Short biographical descriptions for 79 actors, keyed by `speaker_std`.

``` r

head(actors_description)
#> # A tibble: 6 × 2
#>   speaker_std description                                                       
#>   <chr>       <chr>                                                             
#> 1 MONTESINOS  Fujimori's Chief of Staff                                         
#> 2 DESCONOCIDO NA                                                                
#> 3 KOURI       Elected Constituent Congressman (1992 - 1995) for the Partido Pop…
#> 4 LUCCHETTI   Company specialized in pasta manufacturing                        
#> 5 FERRERO     Congressman (1995-2000)                                           
#> 6 FUJIMORI    President of Peru (1990-2000)
```

### `topic_descriptions` — Topic Reference

Human-readable labels and descriptions for each of the 15 topic tags.

``` r

topic_descriptions
#> # A tibble: 15 × 2
#>    topics                  descriptions                                         
#>    <chr>                   <chr>                                                
#>  1 topic_referendum        Referendum to Preuvian consitution that was supporte…
#>  2 topic_ecuador           Ensuring end to Peru-Ecuador war, while maintaining …
#>  3 topic_reelection        Extended discussions involving ensured reelection of…
#>  4 topic_media             Key transcripts highlighting control that Montesinos…
#>  5 topic_foreign           Conversations regarding Peru’s relations with foreig…
#>  6 topic_safety            Discussions on internal armed conflict, drug traffic…
#>  7 topic_lucchetti_factory Legal battle over whether Lucchetti Pasta could lega…
#>  8 topic_municipal98       Discussions involving Alex Kouri, Alberto Andrade an…
#>  9 topic_miraflores        Discussions about the elections for mayor in Lima an…
#> 10 topic_canal4            Key transcripts highlighting control that Montesinos…
#> 11 topic_promotions        Promotions being granted to different members of the…
#> 12 topic_ivcher            Conversations regarding Ivcher providing information…
#> 13 topic_wiese             Conversations Montesinos had with members of Wiese B…
#> 14 topic_public_officials  Conversations in which Montesinos reassigns, plans, …
#> 15 topic_state_capture     Discussions about capturing Congress, military bodie…
```

## Linking Datasets

The table below shows which columns connect the datasets:

| From                   | To                        | Key column         |
|------------------------|---------------------------|--------------------|
| `compiled_transcripts` | `actors`                  | `speaker_std`      |
| `compiled_transcripts` | `transcript_index`        | `n`                |
| `compiled_transcripts` | `speakers_per_transcript` | `n`                |
| `compiled_transcripts` | `descriptions`            | `n`                |
| `actors`               | `actors_description`      | `speaker_std`      |
| `descriptions`         | `topic_descriptions`      | topic column names |

## Using `speaker_std` as a Linking Key

The `speaker_std` column is the consistent identifier linking actors
across all datasets. It uses uppercase surnames and resolves naming
variation in the original source material. When writing analysis code,
always use `speaker_std` rather than the raw `speaker` column for joins
and filters.

``` r

transcripts |>
  filter(speaker_std == "MONTESINOS") |>
  summarise(n_turns = n(), n_words = sum(nchar(speech)))
#> # A tibble: 1 × 2
#>   n_turns n_words
#>     <int>   <int>
#> 1   16609      NA
```

[`get_transcript_id()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_id.md)
expects lowercase values for the `speaker` argument, which it matches
against lowercase `speaker_std` values internally:

``` r

get_transcript_id(speaker = "montesinos")
#>  [1]   5   6   7   8   9  10  11  12  13  14  15  16  17  19  20  21  22  23  24
#> [20]  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  44  45
#> [39]  46  47  48  49  50  51  52  56  57  58  59  60  61  62  63  64  65  66  67
#> [58]  68  69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86
#> [77]  87  88  89  90  94  95  96  97  98 102 103 104
```

## Accessing Data Directly

All datasets are lazily loaded when the package is attached, so you can
reference them by name after
[`library(BribeR)`](https://jessietrudeau.github.io/BribeR):

``` r

nrow(compiled_transcripts)
#> [1] 47375
nrow(actors)
#> [1] 125
nrow(topic_descriptions)
#> [1] 15
```
