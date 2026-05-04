## R CMD check results

0 errors | 0 warnings | 5 notes

### Notes

**New submission**
This is the first submission of this package to CRAN.

**Installed package size (10.1 MB)**
The package includes 101 raw transcript CSV files in `inst/data-raw/transcripts/`
(7.1 MB) that are required for the `get_transcripts_raw()` function, plus
compiled datasets in `data/` (2.0 MB). The data are the primary value of the
package — they represent a unique corpus of corruption transcripts not
available elsewhere in a structured, machine-readable form.

**`LICENSE.md` at top level**
This is standard practice for MIT-licensed packages and is generated
automatically by `usethis::use_mit_license()`.

**Unable to verify current time**
This is a transient check environment issue unrelated to the package.

**HTML validation problems**
These warnings originate from the version of `tidy` installed on the check
system and reflect its handling of modern HTML5 elements (`<main>`). The
rendered help pages display correctly in R.

## Test environments

- macOS Ventura 13.6.7, R 4.4.1 (local)

## Downstream dependencies

None.