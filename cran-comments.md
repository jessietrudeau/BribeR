## R CMD check results

0 errors | 0 warnings | 5 notes

### Notes

**New submission**
This is a new CRAN submission.

**Installed package size (10.1 MB)**
The package includes 101 raw transcript CSV files in `inst/data-raw/transcripts/`
(7.1 MB) that are required for the `get_transcripts_raw()` function, plus
compiled datasets in `data/` (2.0 MB). The data are the primary value of the
package — they represent a unique corpus of corruption transcripts not
available elsewhere in a structured, machine-readable form.

**`LICENSE.md` at top level**
`LICENSE.md` is standard practice for MIT-licensed packages and is generated
automatically by `usethis::use_mit_license()`.

**Unable to verify current time**
This is a transient check environment issue unrelated to the package.

**HTML validation warnings in manual**
The HTML checker flags `<main>` as unrecognized and warns about missing
`summary` attributes on tables. These are known artifacts of the system `tidy`
HTML validator on macOS being too old to recognize current HTML5 elements. The
underlying `.Rd` documentation is valid and the rendered help pages display
correctly. These warnings are not actionable.

## Test environments

- macOS Ventura 13.7.8, R 4.4.1 (local)

## Downstream dependencies

None.
