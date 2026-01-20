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
   - Dominant genre: Progressive rock/metal and alternative rock anchored by a small set of artists; TOOL, A Perfect Circle, Soen, Porcupine Tree, The Pineapple Thief, Manchester Orchestra, Half Moon Run
   - Top 20 artists account for 47.5% of all streams (5,039 v 10,610)
   - High replay intensity
   - Selective track engagement: Frequently replayed songs show 70–100% skip rates
   - Streams are overwhelmingly music-focused (~3 minutes per play and 49% overall skip rate). 
  
3. **Listening Engagement Quality & Patterns**
   - Listening engagement split between exploration and immersion
     - Exploration: high plays and frequent skips (35 - 65% completion) - Progressive and Alternative rock
     - Immersion: lower play count but near perfect completion rate (70%+) - ambient and indie
   - Above‑average songs: Favourite Boy, That Home, Quietly, The Grocery, Fake Plastic Trees
   - Artist engagement: Manchester Orchestra (662 plays, 55% completion), A Perfect Circle (550, 61%), Soen (460, 38%) show high play counts but low completion. By contrast, Dan Deacon (94%), Novo Amor (78%), City Boys Band (85%) are almost always finished.
  
4. **Listening Trends, My Favourites and Binge Behaviour**
   - Favourite artists: Manchester Orchestra (top 3 artist every year), TOOL & A Perfect Circle (steady top 8 ranks across years),
   - Growing favourite: Novo Amor (Indie)
   - One to watch: Hans Zimmer
   - Favourite songs: The Alien, The Sunshine, The Grocery (Manchester Orchestra), Descending (TOOL), Favourite Boy (Half Moon Run)
   - Peak listening year: 2023 (17days listen time in total)
   - Very artist attached (when binging an artist, ccan listen to 12 songs in a row).
  
# Limitations
- Insights reflect one user (mine) listening behaviour.
- User interaction (skips, end) lacks context
- Cross platform switch: In December 2023, I switched streaming platforms from Spotify to YouTube Music. As a result, the data for 2024 and 2025 is sparse
- No genre metadata

# Future Improvement
- time based analysis: break down listening by month/week/day for seasonal patterns
- genre metadata integration
- Visualization

# Takeaway
This project reveals a dual pattern of listening behavior:
- Exploration mode → Progressive/alt‑rock staples (Manchester Orchestra, TOOL, A Perfect Circle) dominate play counts but often show lower completion rates due to long track lengths.
- Immersion mode → Select artists (Novo Amor, Dan Deacon, City Boys Band) and smaller folk/indie/ambient albums are played less often but almost always completed, reflecting deeper engagement.

Across 2022–2025, I streamed ~20 days of music, with a peak in 2023 (17 days) before declining after switching platforms. 
Stable favourites (Manchester Orchestra, TOOL, A Perfect Circle) anchor my listening identity, while new interests (Novo Amor, Hans Zimmer) highlight evolving tastes.
Overall, the project shows that my listening is both anchored by consistent favourites and shaped by emerging explorations, balancing breadth with depth.

