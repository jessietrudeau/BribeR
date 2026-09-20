#' Vladivideos Detailed Transcripts
#'
#' The main corpus of the Vladivideos recordings. Each row represents a single
#' speech turn within a transcript, with the speaker's words and metadata.
#'
#' @format A tibble with 46,597 rows and 6 variables:
#' \describe{
#'   \item{id}{Numeric transcript identifier.}
#'   \item{row_id}{Row number within the transcript.}
#'   \item{date}{Date of the recording (character).}
#'   \item{speaker_std}{Standardized speaker identifier (lowercase surname).}
#'   \item{speaker}{Raw speaker label as it appears in the original transcript.}
#'   \item{speech}{Text of the speaker's turn (in Spanish).}
#' }
#' @source Vladimiro Montesinos Torres secret recordings, transcribed and
#'   compiled from the public Vladivideos archive.
"compiled_transcripts"


#' Transcript Index
#'
#' A wide-format lookup table with one row per transcript, combining
#' descriptive metadata with binary indicator columns for topics and
#' speakers, enabling fast filtering without loading the full corpus. This
#' is the single source of transcript-level metadata for the package; there
#' is no separate `descriptions` dataset.
#'
#' @format A tibble with 99 rows. Descriptive columns first, followed by the
#'   `n_speakers` and `n_topics` summary counts, followed by the boolean (1/0)
#'   `speaker_*` and `topic_*` indicator columns. The counts are deliberately
#'   named with an `n_` prefix so that they are not picked up by code selecting
#'   indicator columns with `speaker_` or `topic_`:
#' \describe{
#'   \item{id}{Numeric transcript identifier (BribeR internal numbering).}
#'   \item{file}{Source transcript filename, e.g. \code{"14.csv"}.}
#'   \item{format}{File format of the source transcript (e.g. \code{"csv"}).}
#'   \item{date}{Date of the recording.}
#'   \item{original_id}{Original transcript identifier from the source archive.}
#'   \item{in_book}{1 if the transcript is cited in published work, 0 otherwise.}
#'   \item{in_online_archive}{1 if available in the online archive, 0 otherwise.}
#'   \item{type}{Recording medium (\code{"audio"} or \code{"video"}).}
#'   \item{summary}{Plain-language English summary of the transcript content.}
#'   \item{speakers}{Free-text description of participants.}
#'   \item{n_speakers}{Total number of distinct speakers in the transcript.}
#'   \item{n_topics}{Total number of topics flagged for the transcript.}
#'   \item{speaker_SURNAME}{Integer indicator (1/0) for each standardized
#'     speaker. One column per unique speaker, named \code{speaker_} followed
#'     by the speaker's standardized surname.}
#'   \item{topic_referendum, topic_ecuador, topic_lucchetti_factory,
#'     topic_municipal98, topic_reelection, topic_miraflores, topic_canal4,
#'     topic_media, topic_promotions, topic_ivcher, topic_foreign, topic_wiese,
#'     topic_public_officials, topic_security, topic_state_capture}{Integer
#'     indicator (1/0) for each topic.}
#' }
#' @source Derived from the Vladivideos transcripts and accompanying metadata.
"transcript_index"


#' Speakers Per Transcript
#'
#' A wide-format table listing the standardized speaker identifiers present in
#' each transcript, with one row per transcript and one column per speaker slot.
#'
#' @format A tibble with 101 rows and 20 variables:
#' \describe{
#'   \item{id}{Numeric transcript identifier.}
#'   \item{speaker_std_1 ... speaker_std_19}{Standardized speaker identifier
#'     for the 1st through 19th speaker slot. \code{NA} if the slot is unused
#'     for that transcript.}
#' }
#' @source Derived from the Vladivideos transcripts.
"speakers_per_transcript"


#' Actor Roster
#'
#' Biographical and institutional metadata for individuals who appear in the
#' Vladivideos transcripts.
#'
#' @format A tibble with 125 rows and 6 variables:
#' \describe{
#'   \item{speaker}{Full name of the individual.}
#'   \item{position}{Institutional role or title at the time of the recordings.}
#'   \item{type}{Broad institutional category (lowercase). One of
#'     \code{"montesinos"} (Vladimiro Montesinos himself, kept separate from
#'     \code{"security"}), \code{"security"}, \code{"congress"},
#'     \code{"judiciary"}, \code{"media"}, \code{"businessperson"},
#'     \code{"elected official"}, \code{"bureaucrat"}, \code{"foreign"},
#'     \code{"illicit"}, or \code{"unknown"}.}
#'   \item{party}{Political party affiliation, where applicable.}
#'   \item{speaker_std}{Standardized identifier matching the \code{speaker_std}
#'     column in the transcripts corpus.}
#'   \item{notes}{Additional notes on the individual.}
#' }
#' @source Manually compiled from the Vladivideos archive and related
#'   published research.
"actors"


#' Actor Descriptions
#'
#' Short biographical descriptions for a subset of individuals who appear in
#' the Vladivideos transcripts.
#'
#' @format A tibble with 79 rows and 2 variables:
#' \describe{
#'   \item{speaker_std}{Standardized speaker identifier, matching
#'     \code{speaker_std} in the transcripts corpus.}
#'   \item{description}{Brief description of the individual's role.}
#' }
#' @source Manually compiled from the Vladivideos archive and related
#'   published research.
"actors_description"


#' Topic Descriptions
#'
#' Human-readable labels and descriptions for each topic tag used in the
#' Vladivideos corpus.
#'
#' @format A tibble with 15 rows and 2 variables:
#' \describe{
#'   \item{topics}{Topic identifier, matching the \code{topic_*} column names
#'     in \code{transcript_index}.}
#'   \item{descriptions}{Plain-language description of what the topic covers.}
#' }
#' @source Manually compiled as part of the BribeR package development.
"topic_descriptions"