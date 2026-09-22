#' Retrieve Available Transcript IDs
#'
#' Returns all available transcript IDs (the unique values of `n`) from the
#' bundled Vladivideos transcript dataset. Optionally filters to only those
#' transcripts that include any of the specified speakers or topics, using
#' the bundled `transcript_index` dataset.
#'
#' When multiple speakers and/or topics are provided, all filters are
#' combined with AND logic: a transcript is included only if **every**
#' specified speaker appears in it **and** **every** specified topic is
#' flagged. Requesting a combination that never co-occurs returns an empty
#' vector.
#'
#' @param speaker Optional character vector of one or more standardized speaker
#'   names (e.g., `"montesinos"`, `c("alex kouri", "crousillat")`). If provided,
#'   only transcripts where all of these speakers are present are included.
#' @param topic Optional character vector of one or more topic names (e.g.,
#'   `"media"`, `c("reelection", "state_capture")`). The `topic_` prefix is
#'   added automatically if not included. Only transcripts where all of these
#'   topics are flagged are included.
#'
#' @return A sorted numeric vector of matching transcript IDs, or `numeric(0)`
#'   if no transcript satisfies every filter.
#'
#' @examples
#' # Retrieve all available transcript IDs
#' ids <- get_transcript_id()
#' head(ids)
#'
#' # Retrieve transcript IDs where Montesinos appears
#' get_transcript_id(speaker = "montesinos")
#'
#' # Retrieve transcript IDs where both Alex Kouri and Crousillat appear
#' get_transcript_id(speaker = c("alex kouri", "crousillat"))
#'
#' # Retrieve transcript IDs about both media and reelection
#' get_transcript_id(topic = c("media", "reelection"))
#'
#' # Combine: transcripts with Alex Kouri that are also about media
#' get_transcript_id(speaker = "alex kouri", topic = "media")
#'
#' @seealso [read_transcripts()], [get_transcripts_raw()], [get_transcript_speakers()]
#' @export
get_transcript_id <- function(speaker = NULL, topic = NULL) {

  env <- new.env(parent = emptyenv())
  utils::data("compiled_transcripts", package = "BribeR", envir = env)
  data <- env$compiled_transcripts

  if (!"id" %in% names(data)) {
    stop("Column 'id' not found in the dataset.", call. = FALSE)
  }

  all_ids <- sort(unique(as.numeric(data$id)), na.last = NA)

  # If no filters, return all IDs
  if (is.null(speaker) && is.null(topic)) {
    return(all_ids)
  }

  # Load transcript_index for filtering
  env2 <- new.env(parent = emptyenv())
  utils::data("transcript_index", package = "BribeR", envir = env2)
  index <- env2$transcript_index

  # Restrict to IDs that exist in the transcripts
  index <- index[index$id %in% all_ids, ]

  # Collect matching row indices (AND across all filters). Starts all TRUE and
  # narrows with each condition, so a transcript survives only if it satisfies
  # every speaker and every topic requested.
  matched <- rep(TRUE, nrow(index))

  # Match speakers
  if (!is.null(speaker)) {
    speaker_cols <- paste0("speaker_", tolower(speaker))
    available_speakers <- grep("^speaker_", names(index), value = TRUE)

    missing <- speaker_cols[!speaker_cols %in% names(index)]
    if (length(missing) > 0) {
      available_names <- sub("^speaker_", "", available_speakers)
      missing_names <- sub("^speaker_", "", missing)

      # Separate names that are in the actors roster but never recorded
      # speaking from names that are not in the roster at all, so the message
      # says which of the two problems the caller has.
      env3 <- new.env(parent = emptyenv())
      utils::data("actors", package = "BribeR", envir = env3)
      silent <- env3$actors$speaker_std[env3$actors$is_speaker == 0]
      in_roster <- missing_names[missing_names %in% silent]
      unknown   <- setdiff(missing_names, in_roster)

      msg <- character(0)
      if (length(in_roster) > 0) {
        msg <- c(msg, paste0(
          "Speaker(s) listed in `actors` but never recorded speaking: ",
          paste(in_roster, collapse = ", "),
          ". These have no transcripts to filter on."
        ))
      }
      if (length(unknown) > 0) {
        msg <- c(msg, paste0(
          "Speaker(s) not found in transcript_index: ",
          paste(unknown, collapse = ", "), ". ",
          "Available speakers include: ",
          paste(utils::head(available_names, 10), collapse = ", "),
          if (length(available_names) > 10) ", ..." else ""
        ))
      }
      stop(paste(msg, collapse = " "), call. = FALSE)
    }

    for (sc in speaker_cols) {
      matched <- matched & (!is.na(index[[sc]]) & index[[sc]] != 0)
    }
  }

  # Match topics
  if (!is.null(topic)) {
    topic_cols <- ifelse(grepl("^topic_", topic), topic, paste0("topic_", tolower(topic)))
    available_topics <- grep("^topic_", names(index), value = TRUE)

    missing <- topic_cols[!topic_cols %in% names(index)]
    if (length(missing) > 0) {
      available_names <- sub("^topic_", "", available_topics)
      stop(
        "Topic(s) not found in transcript_index: ",
        paste(sub("^topic_", "", missing), collapse = ", "), ". ",
        "Available topics: ",
        paste(available_names, collapse = ", "),
        call. = FALSE
      )
    }

    for (tc in topic_cols) {
      matched <- matched & (!is.na(index[[tc]]) & index[[tc]] != 0)
    }
  }

  filtered_ids <- sort(as.numeric(index$id[matched]), na.last = NA)
  filtered_ids
}
