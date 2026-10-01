# bribeR 0.1.0

* Initial release.
* Provides access to 95 Vladivideos transcripts, holding 45,337 speech turns,
  via `read_transcripts()`, `get_transcript_id()`, `get_transcript_speakers()`,
  `get_transcripts_raw()`, and `read_transcript_meta_data()`. All five functions 
  take transcript numbers through an `id` argument.
* Includes `run_transcript_network_app()`, an interactive Shiny application
  for visualizing Speaker-Topic and Speaker Co-Appearance networks.
* Bundles five datasets: `compiled_transcripts`, `transcript_index`,
  `speakers_per_transcript`, `speakers`, and `topic_descriptions`.
