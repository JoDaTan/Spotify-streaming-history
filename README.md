# Overview
This project explores personal Spotify listening data using PostgreSQL to uncover listening patterns, preferences, and habits. The analysis identifies favorite artists, albums, and tracks, while examining listening behaviors such as peak listening hours, shuffle patterns, and platform preferences. I built this project to:
- Apply SQL data analysis skills on a real-world personal dataset
- Practice dimensional modeling with star schema design
- Discover insights about my music listening habits
- Transform unstructured JSON data into an analytical database structure

# The Dataset
Spotify listening data captures detailed user activity, including what (songs, podcasts, videos), when (timestamps in UTC), how long (milliseconds played), and where (country, platform) content was consumed, plus technical details like skip rates, shuffle usage, and unique identifiers (URIs) for tracks/episodes. The data is a JSON file.
## To get your Spotify data
1. Log in to your Spotify account
2. Go to [Spotify Privacy Settings](https://www.spotify.com/ng/account/privacy/)
3. Check ✅ "Extended Streaming History"
4. Wait for Spotify to email you the data (usually takes a few days)
5. Download and extract the JSON file

# Database Schema
The project implements a star schema with one fact table and three dimension tables:

**Dimension Tables**
- artists: Artist information (artist_id, artist_name)
- albums: Album details with artist relationships (album_id, album_title, album_artist)
- songs: Song metadata including Spotify URI and type classification (song_id, song_title, spotify_uri, artist_id, album_id, song_type)

**Fact Table**
- streams: Listening events with metrics (stream_id, song_id, stream_date, ms_played, platform, country_code, reason_start, reason_end, shuffle, skipped, offline)

[See database ERD](https://github.com/JoDaTan/Spotify-streaming-history/blob/95b5bd9778e480b7831a0b2c60acd821770375e9/Database%20Schema.png)

# Data Pipeline
1. **Data Extraction & Loading**
```
-- Create staging table for raw JSON data
CREATE TABLE IF NOT EXISTS spotify_raw (
    id SERIAL PRIMARY KEY,
    data JSONB
);

-- Load JSON data using PostgreSQL's JSONB functions
INSERT INTO spotify_raw (data)
SELECT jsonb_array_elements(pg_read_file('Streaming_History_Audio_2022-2025.json')::jsonb);
```

2.  **Data Transformation**
The raw JSON is parsed and loaded into the star schema using SQL INSERT statements with JOIN operations to maintain referential integrity across dimension and fact tables.

3.  **Data Cleaning**
    - Standardized platform names (consolidated Android variants)
    - Added song type classification (Music vs. Podcast) based on Spotify URI patterns

# Key Insights  
-----
