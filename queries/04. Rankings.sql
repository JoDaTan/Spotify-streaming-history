/*
ACT 4 - Ranking and Behavioural Patterns
Questions
- 4.1: How do artists rank by listening time within each year?
- 4.2: Which songs rise or fall in rank over time?
- 4.3: What does my cumulative listening time look like across a year?
- 4.4: For my top artists, which songs dominate my listening?
- 4.5: How often do I binge the same artist or album consecutively?
*/

-- Act 4 Scene I: How do artists rank by listening time within each year?
WITH artist_listen_stat AS (
	SELECT 
		ar.artist_name,
		EXTRACT(year FROM st.stream_time) listen_year,
		SUM(st.play_length_ms) total_listen_time,
		CONCAT(
			SUM(st.play_length_ms) / (1000 * 60 * 60), 'h ',
			(SUM(st.play_length_ms) / (1000 * 60) % 60), 'm '
		) total_listen_time_str
	FROM streams st
	JOIN songs so ON so.song_id = st.song_id
	JOIN artists ar ON ar.artist_id = so.artist_id
	GROUP BY ar.artist_name, listen_year
),
ranking AS(
	SELECT
		artist_name,
		listen_year,
		total_listen_time,
		total_listen_time_str,
		DENSE_RANK() OVER(
			PARTITION BY listen_year 
			ORDER BY total_listen_time DESC
		) AS listen_rank
	FROM artist_listen_stat
)
SELECT 
	artist_name, listen_year, total_listen_time_str, listen_rank
FROM ranking
WHERE listen_rank <= 10
ORDER BY listen_year, total_listen_time DESC;

/*
Insight:
Consistent Favourites: 
	- Manchester Orchestra (top 3 across all years), 
	- TOOL and A Perfect Circle (consisten top 8 rank) confirming my taste for Alternative and Progressive rock
	- Novo Amor appears in 2023, 2024 and 2025 indicating a more recent but growing favourite

New Interest: 
	- Hans Zimmer emerging as a new interest (top artist in 2025)
*/


-- Act 4 Scene II: Which songs rise or fall in rank over time?
/*
Metric used to judge song rank will be listen count
Why? Progressive songs are typically 8-12 minutes long which is almost 2x the listen time of the average song from other genre
*/
WITH song_ranking AS (
    SELECT
        so.song_title,
        EXTRACT(year FROM st.stream_time) AS listen_year,
        COUNT(st.stream_id) AS play_count,
        DENSE_RANK() OVER (
            PARTITION BY EXTRACT(year FROM st.stream_time)
            ORDER BY COUNT(st.stream_id) DESC
        ) AS song_rank
    FROM streams st
    JOIN songs so ON so.song_id = st.song_id
    GROUP BY so.song_title, listen_year
),
pivoted AS (
    SELECT 
        song_title,
        MAX(CASE WHEN listen_year = 2022 THEN song_rank END) AS rank_2022,
        MAX(CASE WHEN listen_year = 2023 THEN song_rank END) AS rank_2023,
        MAX(CASE WHEN listen_year = 2024 THEN song_rank END) AS rank_2024,
        MAX(CASE WHEN listen_year = 2025 THEN song_rank END) AS rank_2025
    FROM song_ranking
    GROUP BY song_title
)
SELECT song_title,
       rank_2022, rank_2023, rank_2024, rank_2025
FROM pivoted
ORDER BY 
    (CASE WHEN rank_2022 IS NULL THEN 1 ELSE 0 END
   + CASE WHEN rank_2023 IS NULL THEN 1 ELSE 0 END
   + CASE WHEN rank_2024 IS NULL THEN 1 ELSE 0 END
   + CASE WHEN rank_2025 IS NULL THEN 1 ELSE 0 END) ASC,
    COALESCE(rank_2022, 9999),
    COALESCE(rank_2023, 9999),
    COALESCE(rank_2024, 9999),
    COALESCE(rank_2025, 9999);
/*
Insight:

*/


-- Act 4 Scene III: What does my cumulative listening time look like across a year?
SELECT
    EXTRACT(year FROM stream_time) AS listen_year,
    SUM(play_length_ms) AS annual_listen_time,
    CONCAT(
        FLOOR(SUM(play_length_ms) / (1000 * 60 * 60 * 24)), 'd ',
        FLOOR((SUM(play_length_ms) / (1000 * 60 * 60)) % 24), 'h ',
        FLOOR((SUM(play_length_ms) / (1000 * 60)) % 60), 'm'
    ) AS yearly_listen_time,
    CONCAT(
        FLOOR(SUM(SUM(play_length_ms)) OVER (ORDER BY EXTRACT(year FROM stream_time)) / (1000 * 60 * 60 * 24)), 'd ',
        FLOOR((SUM(SUM(play_length_ms)) OVER (ORDER BY EXTRACT(year FROM stream_time)) / (1000 * 60 * 60)) % 24), 'h ',
        FLOOR((SUM(SUM(play_length_ms)) OVER (ORDER BY EXTRACT(year FROM stream_time)) / (1000 * 60)) % 60), 'm'
    ) AS cumulative_listen_time
FROM streams
GROUP BY listen_year
ORDER BY listen_year;
/*
Insight: 
Music listen spanned from 2022 to 2025 with a peak in 2023 followed by a sharp decline in 2024 and 2025.
*/


-- Act 4 Scene IV: For my top artists, which songs dominate my listening?
WITH artist_stat AS (
	-- calculates the number of streams and listening hours for each artist
	SELECT
		ar.artist_name,
		COUNT(st.stream_id) number_of_streams,
		SUM(st.play_length_ms) total_listen_time
	FROM streams st
	JOIN songs so
		ON so.song_id = st.song_id
	JOIN artists ar
		ON ar.artist_id = so.artist_id
	GROUP BY ar.artist_name
),
top10_artist AS (
-- using the artist_stat, this filters for the top 10 artist to establish a table of artist I will call top artist
	SELECT
		artist_name
	FROM artist_stat
	ORDER BY number_of_streams DESC, total_listen_time DESC
	LIMIT 10
),
song_rank AS (
-- for my top artists, rank their songs in order of stream_count and listen_time
	SELECT 
		so.song_title,
		ar.artist_name,
		COUNT(st.stream_id) total_play,
		SUM(st.play_length_ms) listen_time,
		ROW_NUMBER() OVER(
			PARTITION BY ar.artist_name
			ORDER BY COUNT(st.stream_id) DESC, SUM(st.play_length_ms) DESC
		) AS song_rank
	FROM streams st
	JOIN songs so 
		ON so.song_id = st.song_id
	JOIN artists ar 
		ON ar.artist_id = so.artist_id
	WHERE ar.artist_name IN (SELECT t10.artist_name FROM top10_artist t10)
	GROUP BY ar.artist_name, so.song_title
)
SELECT
	artist_name, 
	song_title,
	total_play,
	CONCAT(
		(listen_time / (1000 * 60 * 60)) / 24, 'd ',
		(listen_time / (1000 * 60 * 60)) % 24, 'h ',
		(listen_time / (1000 * 60)) % 60, 'm'
	) listen_time_text
FROM song_rank
WHERE song_rank.song_rank = 1;
/*
Insight:
Among the top 10 artists, each has one standout track that dominates listening. 
Across them all, “Favourite Boy” by Half Moon Run is the most dominant song overall.
*/


-- Act 4 Scene V: How often do I binge the same artist or album consecutively?
WITH ordered_streams AS (
	SELECT
		st.stream_time,
		so.song_title,
		ar.artist_name,
		al.album_title,
		LAG(ar.artist_name) OVER(
			ORDER BY st.stream_time
		) AS prev_artist,
		lag(al.album_title) OVER(
			ORDER BY st.stream_time
		) AS prev_album
	FROM streams st
	JOIN songs so ON so.song_id = st.song_id
	JOIN albums al ON al.album_id = so.album_id
	JOIN artists ar ON ar.artist_id = al.album_artist
),
streaks AS (
	SELECT
		stream_time,
		artist_name, 
		album_title,
		CASE
			WHEN artist_name = prev_artist OR album_title = prev_album THEN 0 ELSE 1
		END AS streak_flag
	FROM ordered_streams
),
streak_group AS (
	SELECT 
		stream_time, 
		artist_name,
		album_title,
		SUM(streak_flag) OVER (ORDER BY stream_time) AS streak_id
	FROM streaks
)
SELECT 
	artist_name,
	album_title,
	--streak_id,
	COUNT(*) songs_in_streak
FROM streak_group
GROUP BY artist_name, album_title, streak_id
HAVING COUNT(*) > 1
ORDER BY songs_in_streak DESC;

