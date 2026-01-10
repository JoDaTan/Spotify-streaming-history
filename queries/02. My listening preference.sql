/* ACT 2: MY CORE PREFERENCES
In the section I will be identifying what I consistently choose to listen to with the following question;
- Which artists account for the largest share of my total listening time?
- How concentrated is my listening? Do a few artists dominate or is it spread out?
- Which albums do I return to the most?
- Are there songs I play frequently but rarely finish?
- How does my listening differ between songs and other audio types (e.g. episodes)?
*/

-- Act 2 Scene I: Which artists account for the largest share of my total listening time?
SELECT 
	ar.artist_name,
	(SUM(st.play_length_ms) / (1000 * 60 * 60)) || 'h ' ||
    ((SUM(st.play_length_ms) / (1000 * 60)) % 60) || 'm' AS total_listening_time
FROM streams st
JOIN songs so ON so.song_id = st.song_id
JOIN artists ar ON ar.artist_id = so.artist_id
GROUP BY ar.artist_name
ORDER BY SUM(st.play_length_ms) DESC;

/*
Insight: My music taste is heavily skewed towards progressive/alternative rock with: 
	TOOL, A Perfect Circle, Soen, Porcupine Tree, Pineapple Thief (progressive),
	Manchester Orchestra, Half Moon Run, Doves, Sleeping At Last anchoring these genres.
*/


-- Act 2 Scene II: How concentrated is my listening? Do a few artists dominate or is it spread out?
SELECT
	ar.artist_name,
	COUNT(st.stream_id) play_count
FROM streams st
JOIN songs so ON so.song_id = st.song_id
JOIN artists ar ON ar.artist_id = so.artist_id
GROUP BY ar.artist_name
ORDER BY play_count DESC;

/*
Insight: Listening is fairly concentrated - 
The top 20 artists make up almost half (47.5%) of all streams (5,039 of 10,610 streams)
*/


-- Act 2 Scene III: Which albums do I return to the most?
SELECT
	al.album_title,
	ar.artist_name,
	COUNT(st.stream_id) play_count
FROM streams st
JOIN songs so ON so.song_id = st.song_id
JOIN albums al ON al.album_id = so.album_id
JOIN artists ar ON ar.artist_id = al.album_artist
GROUP BY al.album_title, artist_name
ORDER BY play_count DESC;

/*
Insight: 

*/


-- Act 2 Scene IV: Are there songs I play frequently but rarely finish?
	-- Songs played frequently are defined by total_plays >= 10
SELECT 
    so.song_title,
    COUNT(st.stream_id) AS total_plays,
    COUNT(CASE WHEN st.reason_end <> 'trackdone' THEN 1 END) AS incomplete_plays,
    ROUND(
        100.0 * COUNT(CASE WHEN st.reason_end <> 'trackdone' THEN 1 END) 
        / COUNT(st.stream_id), 2
    ) AS skip_rate_percentage
FROM streams st
JOIN songs so ON so.song_id = st.song_id
GROUP BY so.song_title
HAVING COUNT(st.stream_id) >= 10
ORDER BY skip_rate_percentage DESC;


-- Act 2 Scene V: How does my listening differ between songs and other audio types (e.g. episodes)?
SELECT
	so.song_type,
	COUNT(st.stream_id) total_plays,
	ROUND(AVG(st.play_length_ms) / 60000, 2) || ' mins' AS avg_play_length_minutes,
	COUNT(
		CASE 
			WHEN st.reason_end <> 'trackdone' THEN 1 END
	) AS incomplete_plays,
	ROUND(100 * COUNT(CASE WHEN st.reason_end <> 'trackdone' THEN 1 END) / COUNT(st.stream_id), 2) AS skip_rate
FROM streams st
JOIN songs so ON st.song_id = so.song_id
GROUP BY so.song_type;

/* 
Insight: 
Streams are overwhelmingly dominated by music, averaging about 3 minutes with a 49% skip rate, 
while every podcast listen is skipped.
*/