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


-- Act 3 Scene IV: Which albums have high completion rates compared to others?
SELECT 
	al.album_title,
	COUNT(st.stream_id) total_streams,
	ROUND(100 * (COUNT(CASE WHEN st.reason_end = 'trackdone' THEN 1 END)::numeric / COUNT(st.stream_id)) , 2) AS completion_rate
FROM streams st
JOIN songs so ON so.song_id = st.song_id
JOIN artists ar ON ar.artist_id = so.artist_id
JOIN albums al ON al.album_artist = ar.artist_id
GROUP BY al.album_title
ORDER BY completion_rate DESC;


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