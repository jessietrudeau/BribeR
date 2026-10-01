# Changelog

## bribeR 0.1.0

- Initial release.
- Provides access to 95 Vladivideos transcripts, holding 45,337 speech
  turns, via
  [`read_transcripts()`](https://jessietrudeau.com/bribeR/reference/read_transcripts.md),
  [`get_transcript_id()`](https://jessietrudeau.com/bribeR/reference/get_transcript_id.md),
  [`get_transcript_speakers()`](https://jessietrudeau.com/bribeR/reference/get_transcript_speakers.md),
  [`get_transcripts_raw()`](https://jessietrudeau.com/bribeR/reference/get_transcripts_raw.md),
  and
  [`read_transcript_meta_data()`](https://jessietrudeau.com/bribeR/reference/read_transcript_meta_data.md).
  All five functions take transcript numbers through an `id` argument.
- Includes
  [`run_transcript_network_app()`](https://jessietrudeau.com/bribeR/reference/run_transcript_network_app.md),
  an interactive Shiny application for visualizing Speaker-Topic and
  Speaker Co-Appearance networks.
- Bundles five datasets: `compiled_transcripts`, `transcript_index`,
  `speakers_per_transcript`, `speakers`, and `topic_descriptions`.
