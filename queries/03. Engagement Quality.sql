/*
ACT 3: Measuring Engagement Quality (Subqueries and CTEs)

Here I'll answer questions that give more information on user engagement;
- Which songs have above-average total listening time relative to all songs?
- Which artists outperform the average artist in terms of engagement?
- Are there artists I listen to often but rarely finish songs from?
- Which albums have high completion rates compared to others?
- How many songs appear frequently in my history but fall below my personal average play length?
*/

-- Act 3 Scene I: Which songs have above-average total listening time relative to all songs?
WITH total_plays AS (
	SELECT 
		so.song_title,
		SUM(play_length_ms) total_listening_time,
		CONCAT(
			(SUM(st.play_length_ms) / (1000 * 60 * 60)), 
			'h ',
			((SUM(st.play_length_ms) / (1000 * 60)) % 60),
			'm'
		) AS total_listening_time_text
	FROM streams st
	JOIN songs so ON so.song_id = st.song_id
	GROUP BY so.song_title
)
SELECT 
	song_title, total_listening_time_text
FROM total_plays
WHERE total_listening_time > (SELECT AVG(total_listening_time) FROM total_plays)
ORDER BY total_listening_time DESC;
/*
Insight:
The result show dominance of progressive and long-form artists (Tool, A Perfect Circle, Soen, David Gilmour, Nad Sylvan) suggests a strong preference for extended compositions that reward sustained attention.
Alongside this, a subset of tracks (That Home, Quietly, The Grocery, Fake Plastic Trees) function as emotional anchors. 
Their repeated, long-duration listening indicates periods where music served a regulatory role, supporting mood and emotional processing rather than passive entertainment.
*/


-- Act 3 Scene II: Which artists outperform the average artist in terms of engagement?
WITH artist_engagement AS (SELECT 
	ar.artist_name, 
	COUNT(st.stream_id) total_plays,
	SUM(st.play_length_ms) total_listen_time,
	CONCAT(
		(SUM(st.play_length_ms) / (1000 * 60 * 60)), 'h ', ((SUM(st.play_length_ms) / (1000 * 60)) % 60), 'm'
	) AS total_listen_time_text
FROM streams st
JOIN songs so ON so.song_id = st.song_id
JOIN artists ar ON ar.artist_id = so.artist_id
GROUP BY ar.artist_name
)
SELECT 
	artist_name, total_plays, total_listen_time_text
FROM artist_engagement
WHERE (
	total_plays > (SELECT AVG(total_plays) FROM artist_engagement)
	OR 
	total_listen_time > (SELECT AVG(total_listen_time) FROM artist_engagement)
)
ORDER BY 2 DESC;
/*
My engagement is anchored by progressive and alternative rock artists, with Manchester Orchestra as the clear centerpiece.
A Perfect Circle, TOOL, and Soen form a strong progressive spine, while Half Moon Run and Sleeping At Last add emotional depth.
While my core is rooted in rock/prog, my listening identity is enriched by eclectic, immersive outliers — from AfroBeats, Amapiano, and Highlife — with artists like;
Asa, Burna Boy, Kabza De Small, Chief Osita Osadebe, and Asake making rare but above‑average appearances in my listening time.
*/

-- Act 3 Scene III: Are there artists I listen to often but rarely finish songs from?
WITH artist_engagement AS (
-- aggregates the number of listens and total listening time for each artists
	SELECT
		ar.artist_name,
		SUM(st.play_length_ms) total_listen_time,
		COUNT(st.stream_id) total_plays
	FROM streams st
	JOIN songs so ON so.song_id = st.song_id
	JOIN artists ar ON ar.artist_id = so.artist_id
	GROUP BY ar.artist_name
),
above_avg_artists AS (
-- defines artists I enjoy as artists that have above the average artist engagement
	SELECT artist_name
	FROM artist_engagement
	WHERE total_plays > (SELECT AVG(total_plays) FROM artist_engagement)
		OR total_listen_time > (SELECT AVG(total_listen_time) FROM artist_engagement)
)
-- Get the completion rate for the artists I enjoy 
SELECT
	ar.artist_name, 
	COUNT(st.stream_id) total_plays,
	ROUND(100 * COUNT(CASE WHEN st.reason_end = 'trackdone' THEN 1 END) / COUNT(st.stream_id), 2) AS completion_rate
FROM streams st
JOIN songs so ON so.song_id = st.song_id
JOIN artists ar ON ar.artist_id = so.artist_id
WHERE artist_name IN (SELECT artist_name FROM above_avg_artists)
GROUP BY artist_name
ORDER BY completion_rate DESC;
/*
Insight:
Among the artists I engage with most, several show high play counts but low completion rates.
Manchester Orchestra (662 plays, 55% completion), A Perfect Circle (550 plays, 61%), and Soen (460 plays, 38%) dominate my listening in volume but are frequently skipped before the end. 
Similarly, immersive artists like TOOL (317 plays, 47%) and Porcupine Tree (216 plays, 41%) reflect the same pattern, likely due to their long track lengths.

By contrast, artists such as Dan Deacon (94% completion), Novo Amor (78%), and City Boys Band (85%) show that when I play them, I almost always let the track run to completion — highlighting a different, more immersive listening mode.

Takeaway
My listening splits into two modes:
- Exploration mode → Progressive/alt‑rock staples I play often but skip midway.
- Immersion mode → Select artists I finish almost every time, even if play counts are lower.
*/


-- Act 3 Scene IV: Which albums have high completion rates compared to others?
WITH song_stat AS (
	SELECT
		ar.artist_id,
		so.song_title,
		al.album_title,
		COUNT(st.stream_id) play_count,
		COUNT(
			CASE WHEN st.reason_end = 'trackdone' THEN 1 END
		) completed_stream
	FROM streams st
	JOIN songs so ON so.song_id = st.song_id
	JOIN albums al ON al.album_id = so.album_id
	JOIN artists ar ON ar.artist_id = al.album_artist
	GROUP BY song_title, album_title, ar.artist_id
),
album_completion AS(
	SELECT 
		ss.album_title,
		ar.artist_name,
		COUNT(DISTINCT song_title) distinct_songs,
		SUM(play_count) album_play_count,
		SUM(completed_stream) * 100 / NULLIF(SUM(play_count), 0) weighted_completion_rate
	FROM song_stat ss
	JOIN artists ar ON ar.artist_id = ss.artist_id
	GROUP BY album_title, ar.artist_name
)
SELECT
	artist_name,
	album_title,
	distinct_songs,
	ROUND(weighted_completion_rate, 2) album_completion_rate
FROM album_completion
WHERE weighted_completion_rate > (SELECT AVG(weighted_completion_rate) FROM album_completion)
	AND distinct_songs > 1 -- to exclude singles and EPs
ORDER BY weighted_completion_rate DESC, distinct_songs DESC;
/*
Insight:
- Folk, Indie and Ambient albums show a high completion rate of about 70%+ although the albums are often smaller with 2-7 distinct songs
- Rock and Afrobeat albums have moderate completion with about 6-13 distinct songs
- Progressive albums are larger (10 - 15 distinct songs) and have low completion rate which tells of selective listening.
*/


-- Act 3 Scene V: How many songs appear frequently in my history but fall below my personal average play length?
/*
Songs that appear frequently in play history are song with above average play count
*/
WITH song_stat AS (
	SELECT
		so.song_title,
		COUNT(st.stream_id) play_count,
		AVG(st.play_length_ms) avg_play_length,
		CONCAT(
			FLOOR(AVG(st.play_length_ms) / 60000), 'm ',
			FLOOR(AVG((st.play_length_ms) / 1000) % 60), 's'
		) avg_play_length_str
	FROM streams st
	JOIN songs so ON so.song_id = st.song_id
	GROUP BY so.song_title
),
averages AS(
	SELECT
		AVG(play_count) avg_play_count,
		AVG(avg_play_length) AS avg_play_time
	FROM song_stat
)
SELECT
	song_title,
	play_count,
	avg_play_length_str
FROM song_stat
JOIN averages ON 1 = 1
WHERE play_count > averages.avg_play_count
	AND avg_play_length < averages.avg_play_time
ORDER BY avg_play_length DESC;

