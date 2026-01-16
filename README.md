# Spotify Listening Behavior Analysis
This project analyzes my personal Spotify listening history using SQL to uncover listening behavior, engagement, and preferences over time. Rather than treating this as a set of isolated queries, the analysis is structured as a behavioral narrative that explores how songs, albums, and artists gain, sustain, or lose attention.

The goal is to demonstrate analytical thinking, SQL proficiency, and data storytelling, not just query syntax.

# The Dataset
- Source: Spotify Streaming History (JSON file) _[How to download your Spotify data](https://www.jamwise.org/p/i-downloaded-my-spotify-user-data)_
- Time range: 2022 - 2025
- Records: ~10,600 streaming events

The raw data was extracted, normalized and modeled into a star schema for analysis

# Data Model
The database consists of:

**Dimension Tables**
- artists: Artist information (artist_id, artist_name)
- albums: Album details with artist relationships (album_id, album_title, album_artist)
- songs: Song metadata including Spotify URI and type classification (song_id, song_title, spotify_uri, artist_id, album_id, song_type)

**Fact Table**
- streams: Listening events with metrics (stream_id, song_id, stream_date, ms_played, platform, country_code, reason_start, reason_end, shuffle, skipped, offline)

[Database ERD](https://github.com/JoDaTan/Spotify-streaming-history/blob/95b5bd9778e480b7831a0b2c60acd821770375e9/Database%20Schema.png)

# Key Definitions
To ensure analytical clarity, the following definitions are used:
- Stream: A single play event of song on a device(`platform`), recorded with timestamp (`stream_time`), duration (`play_length_ms`) and associated metadata
- Completed stream: a stream with `reason_end = 'trackdone'`
- Frequent plays: a song with a stream count >= 10
- Favourite artist/song/album: artist/song/album with above average engagment (total stream/total listen time)

# Analytical Themes & Insight
1. **Listening Behavior**
   - Mobile-first consumption (~98% of streams)
   - Predmoninantly online listening
   - High interaction rate with frequent skipping
     - 42.6% of streams skipped
     - ~50% end early due to user interaction (forward skip dominates - 55%, followed by bakward/remote skips - 8%)

2. **Listening Engagement & Concentration**
   - My listening is heavily skewed towards progressive rock/metal and alternative rock, anchored by a small set of artists; TOOL, A Perfect Circle, Soen, Porcupine Tree, The Pineapple Thief, Manchester Orchestra, Half Moon Run
   - My top 20 artists account for 47.5% of all streams (5,039 v 10,610)
   - High replay intensity: Manchester Orchestra, A Perfect Circle, TOOL, Soen, and Half Moon Run drive repeat engagement, with Manchester Orchestra exceeding 540 plays across three albums.
   - Selective track engagement: Frequently replayed songs still show 70–100% skip rates, indicating album revisits with selective track-level disengagement (e.g., Deceiver never completed; The Wolf by Ben Howard 88% skipped).
   - Music-first platform usage: Streams are overwhelmingly music-focused, averaging ~3 minutes per play with a 49% overall skip rate. Non-music audio shows minimal engagement, with 100% of podcast streams skipped, reinforcing music as the primary consumption intent.
  
3. **Listening Engagement Quality & Patterns**
   - 
