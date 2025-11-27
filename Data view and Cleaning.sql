-- Data view of the tables
SELECT *
FROM albums_dim;

SELECT *
FROM artists_dim;

SELECT *
FROM songs_dim;

SELECT *
FROM streams_fct;


-- Update platform in Streams so the values are consistent
UPDATE streams_fct
SET platform = 
	CASE
		WHEN LOWER(platform) LIKE 'android%' THEN 'android' ELSE LOWER(platform)
	END 
WHERE platform IN ('Android OS 11 API 30 (vivo, V2109)', 'windows', 'android');


-- Update songs_dim table, add stream_type column to distinguish between music and podcast stream
ALTER TABLE songs_dim
ADD COLUMN song_type TEXT;

UPDATE songs_dim
SET song_type = 
	CASE
		WHEN spotify_uri LIKE '%:track:%' THEN 'Music'
		ELSE 'Podcast'
	END
WHERE spotify_uri IS NOT NULL;
