# Visualizing BribeR (Shiny)

### SHINY

## Network Visualization App

[`run_transcript_network_app()`](https://jessietrudeau.github.io/BribeR/reference/run_transcript_network_app.md)
launches an interactive Shiny application with two network views:

- **Speaker–Topic Network**: connects speakers to the topics discussed
  in their transcripts. Node size reflects the number of transcripts a
  speaker appears in; color reflects institutional type.
- **Speaker Co-Appearance Network**: connects speakers who appear in the
  same transcript, with edge weight proportional to co-appearance
  frequency.

``` r

run_transcript_network_app()
```
