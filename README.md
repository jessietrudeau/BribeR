# BribeR <img src="inst/images/montesinos.PNG" align="right" height="138" alt="Montesinos" />

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/BribeR)](https://CRAN.R-project.org/package=BribeR)
[![R-CMD-check](https://github.com/jessietrudeau/BribeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jessietrudeau/BribeR/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**{BribeR}** is an R package for accessing and analyzing the *Vladivideos* —
secret recordings documenting Vladimiro Montesinos, Peru's intelligence chief
under President Alberto Fujimori, bribing politicians, judges, military
officers, media owners, and businesspeople throughout the 1990s. The
recordings became public in 2000 and triggered the collapse of the Fujimori
government. They remain one of the most extensively documented cases of
systemic corruption in Latin American history.

The package provides structured, machine-readable access to 101 transcripts,
along with metadata on the 125 named actors, 15 topic categories, and
47,375 individual speech turns in the corpus.

## Installation

```r
# Install from CRAN
install.packages("BribeR")

# Or install the development version from GitHub
# install.packages("remotes")
remotes::install_github("jessietrudeau/BribeR")
```

## Core Functions

**Reading transcripts**

| Function | Description |
|---|---|
| `read_transcripts()` | Load the full corpus, optionally filtered by transcript ID |
| `get_transcripts_raw()` | Load the original source CSV files |

**Finding transcripts**

| Function | Description |
|---|---|
| `get_transcript_id()` | Return transcript IDs matching speakers or topics |
| `get_transcript_speakers()` | Return speakers appearing in each transcript |

**Metadata**

| Function | Description |
|---|---|
| `read_transcript_meta_data()` | Build a tidy one-row-per-transcript summary |

**Visualization**

| Function | Description |
|---|---|
| `run_transcript_network_app()` | Launch an interactive Speaker–Topic network app |

## Datasets

BribeR includes seven bundled datasets:

| Dataset | Description |
|---|---|
| `compiled_transcripts` | Full corpus: 47,375 speech turns across 101 transcripts |
| `transcript_index` | Wide-format boolean lookup by speaker and topic |
| `speakers_per_transcript` | Speaker roster per transcript |
| `descriptions` | Transcript-level metadata with dates, topics, and summaries |
| `actors` | Biographical and institutional metadata for 125 individuals |
| `actors_description` | Short descriptions for a subset of actors |
| `topic_descriptions` | Labels and descriptions for the 15 topic categories |

## Basic Usage

```r
library(BribeR)

# Load all transcripts
transcripts <- read_transcripts()

# Find transcripts about media manipulation
media_ids <- get_transcript_id(topic = "media")

# Get the metadata summary
meta <- read_transcript_meta_data()

# Launch the network visualization app
run_transcript_network_app()
```

## Citation

If you use BribeR in your research, please cite it as:

> Soto Plaza, A. (2025). *BribeR: Tools for Analyzing the Vladivideos
> Corruption Transcripts*. R package version 0.1.0.
> https://github.com/jessietrudeau/BribeR

The underlying data is derived from the Vladivideos archive. For the
original recordings, see:

> McMillan, J., & Zoido, P. (2004). How to subvert democracy: Montesinos in
> Peru. *Journal of Economic Perspectives*, 18(4), 69–92.

## Contributing

Contributions are welcome. Please open an issue or pull request on
[GitHub](https://github.com/jessietrudeau/BribeR/issues).

## Code of Conduct

Please note that the BribeR project is released with a [Contributor Code of Conduct](https://jessietrudeau.github.io/BribeR/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.