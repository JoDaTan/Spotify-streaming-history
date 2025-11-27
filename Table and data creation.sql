-- create table to store json object (spotify data)
CREATE TABLE IF NOT EXISTS spotify_raw (
	id SERIAL PRIMARY KEY,
	data JSONB
);

-- Populate table with spotify data
INSERT INTO spotify_raw (data)
SELECT jsonb_array_elements(pg_read_file('Streaming_History_Audio_2022-2025.json')::jsonb);

-- Data preview
SELECT 
	id, data
FROM spotify_raw
LIMIT 5;


-- Define dimension tables: artists, albums, songs, and fact table streams
CREATE TABLE IF NOT EXISTS artists_dim (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS albums_dim (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	artist_id INT REFERENCES artists_dim(id),
	UNIQUE(name, artist_id)
);

CREATE TABLE IF NOT EXISTS songs_dim (
	id SERIAL PRIMARY KEY,
	title TEXT NOT NULL,
	spotify_uri TEXT,
	artist_id INT REFERENCES artists_dim(id),
	album_id INT REFERENCES albums_dim(id),
	UNIQUE (title, album_id)
);

CREATE TABLE IF NOT EXISTS streams_fct (
	id SERIAL PRIMARY KEY,
	track_id INT REFERENCES songs_dim(id),
	stream_date TIMESTAMP,
	ms_played INT,
	platform TEXT,
	country_code VARCHAR(5),
	reason_start TEXT,
	reason_end TEXT,
	shuffle BOOLEAN,
	skipped BOOLEAN,
	offline BOOLEAN
);


/*
EXTRACT & LOAD DATA
*/

-- populate artists
INSERT INTO artists_dim(name)
SELECT DISTINCT
	r.data ->> 'master_metadata_album_artist_name'
FROM spotify_raw r
WHERE r.data ->> 'master_metadata_album_artist_name' IS NOT NULL
ON CONFLICT (name) DO NOTHING;


-- populate albums
INSERT INTO albums_dim(name, artist_id)
SELECT DISTINCT
	r.data ->> 'master_metadata_album_album_name',
	a.id
FROM spotify_raw r
JOIN artists_dim a ON a.name = r.data ->> 'master_metadata_album_artist_name'
WHERE r.data ->> 'master_metadata_album_album_name' IS NOT NULL
ON CONFLICT (name, artist_id) DO NOTHING;

-- populate songs
INSERT INTO songs_dim(title, spotify_uri, album_id, artist_id)
SELECT DISTINCT
	r.data ->> 'master_metadata_track_name',
	r.data ->> 'spotify_track_uri',
	al.id,
	ar.id
FROM spotify_raw r
JOIN artists_dim ar ON ar.name = r.data ->> 'master_metadata_album_artist_name'
JOIN albums_dim al ON al.name = r.data ->> 'master_metadata_album_album_name' AND al.artist_id = ar.id
WHERE r.data ->> 'master_metadata_track_name' IS NOT NULL
ON CONFLICT (title, album_id) DO NOTHING;

-- populate streams
INSERT INTO streams_fct(
	track_id, 
	stream_date,
	ms_played,
	platform,
	country_code,
	reason_start,
	reason_end,
	shuffle,
	skipped,
	offline
)
SELECT
	s.id,
	(r.data ->> 'ts')::TIMESTAMP,
	(r.data ->> 'ms_played')::INT,
	r.data ->> 'platform',
	r.data ->> 'conn_country',
	r.data ->> 'reason_start',
	r.data ->> 'reason_end',
	(r.data ->> 'shuffle')::BOOLEAN,
    (r.data ->> 'skipped')::BOOLEAN,
    (r.data ->> 'offline')::BOOLEAN
FROM spotify_raw r
JOIN artists_dim ar ON ar.name = r.data ->> 'master_metadata_album_artist_name'
JOIN albums_dim al ON al.name = r.data ->>  'master_metadata_album_album_name' AND al.artist_id = ar.id
JOIN songs_dim s ON s.title = r.data ->> 'master_metadata_track_name' AND s.album_id = al.id
WHERE r.data ->> 'master_metadata_track_name' IS NOT NULL;