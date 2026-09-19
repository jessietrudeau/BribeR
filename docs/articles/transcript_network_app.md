# Transcript Network App

## Overview

[`run_transcript_network_app()`](https://jessietrudeau.github.io/BribeR/reference/run_transcript_network_app.md)
launches an interactive Shiny application visualizing the relationships
between speakers and topics across the Vladivideos transcript corpus. It
provides two network views:

- **Speaker-Topic Network** – connects speakers to the topics discussed
  in their transcripts.
- **Speaker Co-Appearance Network** – connects speakers who appear in
  the same transcript.

On the package website, the app below runs live in your browser via
[shinylive](https://posit-dev.github.io/r-shinylive/) – a WebAssembly
build of R that needs no Shiny server. It behaves the same as calling
[`run_transcript_network_app()`](https://jessietrudeau.github.io/BribeR/reference/run_transcript_network_app.md)
in RStudio or VS Code: select a speaker from the dropdown, drag nodes,
zoom, and hover for details.

First load takes a few seconds while the in-browser R runtime and
packages initialize.

``` r

# To run the same app locally instead:
library(BribeR)
run_transcript_network_app()
```

If you’re reading this vignette outside the package website (e.g. via
[`browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html)),
the embedded app above won’t load – run
[`run_transcript_network_app()`](https://jessietrudeau.github.io/BribeR/reference/run_transcript_network_app.md)
directly instead.
