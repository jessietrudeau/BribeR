# BribeR ![Montesinos](inst/images/montesinos.PNG)

**{BribeR}** is an R package for accessing and analyzing the
*Vladivideos* — secret recordings documenting Vladimiro Montesinos,
Peru’s intelligence chief under President Alberto Fujimori, bribing
politicians, judges, military officers, media owners, and businesspeople
throughout the 1990s. The recordings became public in 2000 and triggered
the collapse of the Fujimori government. They remain one of the most
extensively documented cases of systemic corruption in Latin American
history.

The package provides structured, machine-readable access to 101
transcripts, along with metadata on the 125 named actors, 15 topic
categories, and 47,375 individual speech turns in the corpus.

## Installation

``` r

# Install from CRAN
install.packages("BribeR")

# Or install the development version from GitHub
# install.packages("remotes")
remotes::install_github("jessietrudeau/BribeR")
```

## Core Functions

**Reading transcripts**

| Function | Description |
|----|----|
| [`read_transcripts()`](https://jessietrudeau.github.io/BribeR/reference/read_transcripts.md) | Load the full corpus, optionally filtered by transcript ID |
| [`get_transcripts_raw()`](https://jessietrudeau.github.io/BribeR/reference/get_transcripts_raw.md) | Load the original source CSV files |

**Finding transcripts**

| Function | Description |
|----|----|
| [`get_transcript_id()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_id.md) | Return transcript IDs matching speakers or topics |
| [`get_transcript_speakers()`](https://jessietrudeau.github.io/BribeR/reference/get_transcript_speakers.md) | Return speakers appearing in each transcript |

**Metadata**

| Function | Description |
|----|----|
| [`read_transcript_meta_data()`](https://jessietrudeau.github.io/BribeR/reference/read_transcript_meta_data.md) | Build a tidy one-row-per-transcript summary |

**Visualization**

| Function | Description |
|----|----|
| [`run_transcript_network_app()`](https://jessietrudeau.github.io/BribeR/reference/run_transcript_network_app.md) | Launch an interactive Speaker–Topic network app |

## Datasets

BribeR includes seven bundled datasets:

| Dataset | Description |
|----|----|
| `compiled_transcripts` | Full corpus: 47,375 speech turns across 101 transcripts |
| `transcript_index` | Wide-format boolean lookup by speaker and topic |
| `speakers_per_transcript` | Speaker roster per transcript |
| `descriptions` | Transcript-level metadata with dates, topics, and summaries |
| `actors` | Biographical and institutional metadata for 125 individuals |
| `actors_description` | Short descriptions for a subset of actors |
| `topic_descriptions` | Labels and descriptions for the 15 topic categories |

## Basic Usage

``` r

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
> <https://github.com/jessietrudeau/BribeR>

The underlying data is derived from the Vladivideos archive. For the
original recordings, see:

> McMillan, J., & Zoido, P. (2004). How to subvert democracy: Montesinos
> in Peru. *Journal of Economic Perspectives*, 18(4), 69–92.

## Contributing

Contributions are welcome. Please open an issue or pull request on
[GitHub](https://github.com/jessietrudeau/BribeR/issues).
