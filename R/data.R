#' Vladivideos Detailed Transcripts
#'
#' The main corpus of the Vladivideos recordings. Each row represents a single
#' speech turn within a transcript, with the speaker's words and metadata.
#'
#' @format A tibble with 47,375 rows and 7 variables:
#' \describe{
#'   \item{n}{Numeric transcript identifier.}
#'   \item{row_id}{Row number within the transcript.}
#'   \item{date}{Date of the recording (character).}
#'   \item{speaker}{Raw speaker label as it appears in the original transcript.}
#'   \item{speech}{Text of the speaker's turn (in Spanish).}
#'   \item{speaker_std}{Standardized speaker identifier (uppercase surname).}
#'   \item{topic}{Primary topic tag assigned to the transcript.}
#' }
#' @source Vladimiro Montesinos Torres secret recordings, transcribed and
#'   compiled from the public Vladivideos archive.
"compiled_transcripts"


#' Transcript Index
#'
#' A wide-format lookup table with one row per transcript. Contains boolean
#' indicator columns for each topic and each speaker, enabling fast filtering
#' without loading the full corpus.
#'
#' @format A tibble with 101 rows and 134 variables. Key variables:
#' \describe{
#'   \item{n}{Numeric transcript identifier.}
#'   \item{file}{Relative path to the source CSV file.}
#'   \item{format}{File format of the source transcript (e.g. \code{"csv"}).}
#'   \item{date}{Date of the recording.}
#'   \item{topic_referendum, topic_ecuador, topic_lucchetti_factory,
#'     topic_municipal98, topic_reelection, topic_miraflores, topic_canal4,
#'     topic_media, topic_promotions, topic_ivcher, topic_foreign, topic_wiese,
#'     topic_public_officials, topic_safety, topic_state_capture}{Integer
#'     indicator (1/0) for each topic.}
#'   \item{speaker_SURNAME}{Integer indicator (1/0) for each standardized
#'     speaker. One column per unique speaker, named \code{speaker_} followed
#'     by the speaker's standardized surname.}
#'   \item{topic_count}{Total number of topics flagged for the transcript.}
#'   \item{speaker_count}{Total number of distinct speakers in the transcript.}
#' }
#' @source Derived from the Vladivideos transcripts and the package's
#'   descriptions and speakers datasets.
"transcript_index"


#' Speakers Per Transcript
#'
#' A wide-format table listing the standardized speaker identifiers present in
#' each transcript, with one row per transcript and one column per speaker slot.
#'
#' @format A tibble with 101 rows and 20 variables:
#' \describe{
#'   \item{n}{Numeric transcript identifier.}
#'   \item{speakrer_std_1 ... speakrer_std_19}{Standardized speaker identifier
#'     for the 1st through 19th speaker slot. \code{NA} if the slot is unused
#'     for that transcript. Note: column names contain a known typo
#'     (\code{speakrer} instead of \code{speaker}) preserved from the source
#'     data.}
#' }
#' @source Derived from the Vladivideos transcripts.
"speakers_per_transcript"


#' Transcript Descriptions
#'
#' Transcript-level metadata including dates, topic flags, availability
#' information, and plain-language summaries.
#'
#' @format A tibble with 104 rows and 24 variables:
#' \describe{
#'   \item{n}{Numeric transcript identifier.}
#'   \item{date}{Date of the recording.}
#'   \item{speakers}{Free-text description of participants.}
#'   \item{original_n}{Original transcript number from the source archive.}
#'   \item{Missing Topic}{Flag indicating the transcript has no assigned topic.}
#'   \item{in_book}{Flag indicating the transcript is cited in published work.}
#'   \item{in_online_archive}{Flag indicating availability in the online archive.}
#'   \item{type}{Recording medium (e.g. \code{"audio"}, \code{"video"}).}
#'   \item{topic_referendum, topic_ecuador, topic_lucchetti_factory,
#'     topic_municipal98, topic_reelection, topic_miraflores, topic_canal4,
#'     topic_media, topic_promotions, topic_ivcher, topic_foreign, topic_wiese,
#'     topic_public_officials, topic_safety, topic_state_capture}{Topic
#'     indicator flags. A cell value of \code{"x"} indicates the topic is
#'     present in that transcript.}
#'   \item{summary}{Plain-language English summary of the transcript's content.}
#' }
#' @source Manually compiled from the Vladivideos archive and related
#'   published research.
"descriptions"


#' Actor Roster
#'
#' Biographical and institutional metadata for individuals who appear in the
#' Vladivideos transcripts.
#'
#' @format A tibble with 125 rows and 6 variables:
#' \describe{
#'   \item{speaker}{Full name of the individual.}
#'   \item{Position}{Institutional role or title at the time of the recordings.}
#'   \item{Type}{Broad institutional category. One of \code{"Security"},
#'     \code{"Congress"}, \code{"Judiciary"}, \code{"Media"},
#'     \code{"Businessperson"}, \code{"Elected Official"}, \code{"Bureaucrat"},
#'     \code{"Foreign"}, \code{"Illicit"}, or \code{"Unknown"}.}
#'   \item{Party}{Political party affiliation, where applicable.}
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
#'     in \code{descriptions} and \code{transcript_index}.}
#'   \item{descriptions}{Plain-language description of what the topic covers.}
#' }
#' @source Manually compiled as part of the BribeR package development.
"topic_descriptions"