pkgname <- "BribeR"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "BribeR-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('BribeR')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("get_transcript_id")
### * get_transcript_id

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: get_transcript_id
### Title: Retrieve Available Transcript IDs
### Aliases: get_transcript_id

### ** Examples

# Retrieve all available transcript IDs
ids <- get_transcript_id()
head(ids)

# Retrieve transcript IDs where Montesinos appears
get_transcript_id(speaker = "montesinos")

# Retrieve transcript IDs where either Kouri or Crousillat appears
get_transcript_id(speaker = c("kouri", "crousillat"))

# Retrieve transcript IDs about media or reelection
get_transcript_id(topic = c("media", "reelection"))

# Combine: transcripts with Kouri OR about media
get_transcript_id(speaker = "kouri", topic = "media")




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("get_transcript_id", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("get_transcript_speakers")
### * get_transcript_speakers

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: get_transcript_speakers
### Title: Get transcripts each speaker appears in
### Aliases: get_transcript_speakers

### ** Examples

# Get all speakers and their transcript appearances
speakers <- get_transcript_speakers()
head(speakers)

# Get speakers from specific transcripts
get_transcript_speakers(n = c(1, 5))

# Get speakers from transcripts about media
get_transcript_speakers(topic = "media")

# Get speakers from transcript 1 that is also about media
get_transcript_speakers(n = 1, topic = "media")




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("get_transcript_speakers", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("get_transcripts_raw")
### * get_transcripts_raw

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: get_transcripts_raw
### Title: Retrieve Raw Transcript Files from BribeR
### Aliases: get_transcripts_raw

### ** Examples

## No test: 
# Load all transcripts (as a list)
all_transcripts <- get_transcripts_raw()

# Load a specific transcript by ID
t3 <- get_transcripts_raw(n = 3)

# Load multiple transcripts and combine them
subset_combined <- get_transcripts_raw(n = c(3, 19, 104), combine = TRUE)
## End(No test)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("get_transcripts_raw", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("read_transcript_meta_data")
### * read_transcript_meta_data

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: read_transcript_meta_data
### Title: Read transcript-level metadata (n, date, speakers, duration,
###   topics)
### Aliases: read_transcript_meta_data

### ** Examples

## No test: 
# Load metadata for all transcripts
meta <- read_transcript_meta_data()
head(meta)
## End(No test)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("read_transcript_meta_data", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("read_transcripts")
### * read_transcripts

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: read_transcripts
### Title: Read Vladivideos Transcript Data
### Aliases: read_transcripts

### ** Examples

# Load all transcripts
all <- read_transcripts()
head(all)

# Load only transcript 1
t1 <- read_transcripts(transcripts = 1)

# Load transcripts 5, 7, and 13
subset <- read_transcripts(transcripts = c(5, 7, 13))




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("read_transcripts", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("run_transcript_network_app")
### * run_transcript_network_app

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: run_transcript_network_app
### Title: Run the Transcript-Topic-Speaker Shiny app
### Aliases: run_transcript_network_app

### ** Examples

## Not run: 
##D # Run the network app
##D run_transcript_network_app()
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("run_transcript_network_app", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
