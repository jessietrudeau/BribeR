## R CMD check results

0 errors | 0 warnings | 0 notes

Checked locally with `R CMD check --as-cran`. Two further notes are expected
from CRAN's incoming checks, which do not run locally:

**New submission**
This is a new submission.

**Installed package size**
The installed size is 10.5 Mb: 6.8 Mb of raw transcript CSV files in
`inst/data-raw/transcripts/`, read by `get_transcripts_raw()`, and 1.9 Mb of
compiled datasets in `data/`. The corpus is the purpose of the package. It is
95 transcripts of the Peruvian *Vladivideos*, holding 45,337 speech turns, and
is not available elsewhere in a structured, machine-readable form.

## Test environments

- macOS 26.6.2, aarch64, R 4.6.1 (local)
- macOS, Windows and Ubuntu, R release, via GitHub Actions
- Ubuntu, R devel and R oldrel-1, via GitHub Actions

## Downstream dependencies

None.
