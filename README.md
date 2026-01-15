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
1. **Listening Behavior (Device, Connectivity, Completion/Skip Rate):** My listening habits are mobile-first (~98% of all streams), online-driven, with frequent skips (42.6% of streams). 50% of streams end early and due to user interaction (forward skip - 55%, backward skip / remote - 8%).

2. **Engagement & Frequency:** Listening is genre-loyal, artist-concentrated and highly interactive dominated by progressive/alternative rock, concentrated among a few core artists, with repeat returns to favorite albums, frequent skips on certain songs, and minimal engagement with non‑music audio.

3. 
-----
