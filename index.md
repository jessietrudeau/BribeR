# BribeR ![Montesinos](inst/images/montesinos.PNG)

**{BribeR}** is an R package for accessing and analyzing text transcript
data from the *Vladivideos,* covert recordings documenting bribery and
corruption during Alberto Fujimori’s presidency in Peru (1990-2000).
This package provides user-friendly access to a large digital archive of
*Vladivideo* transcripts and metadata, including data about 125
individual speakers in the files and 15 topics of importance during the
Fujimori presidency.

(PICTURE)

------------------------------------------------------------------------

## Installation

To install the package in your console, run one of the two below
commands:

``` r

# Install from CRAN
install.packages("BribeR")

# Or install the development version from GitHub
# install.packages("remotes")
remotes::install_github("jessietrudeau/BribeR")
```

------------------------------------------------------------------------

## Core Functions

This package provides three families of functions to access, organize,
and analyze *Vladivideo* data. For a full online guide, see the [BribeR
User
Guide](https://jessietrudeau.com/BribeR/articles/using_briber.html).

**1. Read transcripts**

These functions load transcript data as tibbles(?) or load original
source .csv files.

**2. Find transcripts**

These functions allow the user to filter transcripts by specific
speakers, topics, or transcript ID numbers.

**3. Integrate with transcript metadata**

These functions allow the user to find metadata and combine it with
transcripts or their speakers.

------------------------------------------------------------------------

## Basic Usage

The syntax of `BribeR` is designed to help users easily find and
download transcripts relevant to their interest. For example, a user
interested in obtaining transcript text data and metadata about all
conversations where media manipulation would run the following lines of
code:

``` r

# Load data 
library(BribeR)

# Find specific transcripts about media manipulation
media_ids <- get_transcript_id(topic = "media")

# Get the metadata summary of the transcripts about media manipulation
meta <- read_transcript_meta_data(media_ids)

# Load full-text transcripts about media manipulation
media_transcripts <- read_transcripts(media_ids)
```

------------------------------------------------------------------------

## Datasets

BribeR includes four datasets:

| Dataset | Description |
|----|----|
| `compiled_transcripts` | Full text corpus: 47,375 speech turns across 101 transcripts |
| `transcript_index` | Wide-format transcript-level metadata, searchable by speaker and topic |
| `transcript_descriptions` | Transcript-level metadata with dates, topics, and summaries |
| `speakers_per_transcript` | Speaker roster per transcript |

A full description of the raw data is in the [Raw Data
Guide](https://jessietrudeau.com/BribeR/articles/raw_data_guide.html),
as well as a description of additional actor- and topic-level metadata
accessible in **BribeR.** A full description of the datasets included in
the package is in the [BribeR Data
Guide](https://jessietrudeau.com/BribeR/articles/briber_data_guide.html).

------------------------------------------------------------------------

## Contributing

Contributions are welcome. Please create a new branch for a feature, to
open an issue, or for a pull request on
[GitHub](https://github.com/jessietrudeau/BribeR/issues).

Document exported functions with roxygen2 comments. Add or update tests
in tests/testthat/.

------------------------------------------------------------------------

## Credits

All *Vladivideo* transcript data included in this package are drawn from
publicly available materials, including print volumes published by the
Peruvian Truth and Reconciliation Commission (*Comisión de la Verdad e
Reconciliación*) and online Congressional archives from
[LUM/CDI](https://lum.cultura.pe/cdi/busqueda/colecciones?field_coleccion=55&field_palabra_clave%5B%5D=13462&field_year=)
(*Lugar de la Memoria, la Tolerancia y la Inclusión Social*), the
Ministry of Culture’s Place of Memory, Tolerance, and Social Inclusion.
In accordance with LUM’s guidance, we understand these official
documentary materials to fall outside copyright protection under Article
9(b) of Peru’s [Legislative Decree
No. 822](https://www.leyes.congreso.gob.pe/Documentos/DecretosLegislativos/00822.pdf),
which excludes official legislative, administrative, and judicial texts,
since the original entity that provided the *Vladivideo* data was the
Congress of the Republic of Peru.

This research was generously supported by Syracuse University’s [Open
Source Program Office](https://opensource.syracuse.edu/%22) (OSPO) and
the Sloan Foundation.

## Citation

If you use **BribeR** in your research, please cite it as:

> Trudeau, Jessie, and Soto Plaza, Andrés. 2026. *BribeR: Tools for
> Analyzing Vladivideo Transcript Data*. R package version 0.1.0.
> <https://github.com/jessietrudeau/BribeR>
