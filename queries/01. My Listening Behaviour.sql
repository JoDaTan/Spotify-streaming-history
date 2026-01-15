-- ACT 1: MY LISTENING BEHAVIOUR (BASIC QUERIES)
/* 
This part of the project uses basic querying techniques; SELECT, WHERE, ORDER keywords to answer questions tahat give insight into how I use Spotify
The Questions:
1. What does a typical stream record look like?
2. How often do streams end early, and what are the most common reasons?
3. Which platforms do I listen on the most, and how does play length differ by platform?
4. How much of my listening happens offline vs online?
5. What proportion of streams are skipped?
*/

-- Act 1 Scene I: What does a typical stream record look like?
SELECT * FROM streams;
/* INSIGHT
A typical stream is a single play event of a track recorded with its timestamp, duration, play device, connectivity status and start/end reason
*/

-- Act 1 Scene II: How often do streams end early, and what are the most common reasons?
SELECT 
	reason_end,
	COUNT(stream_id)
FROM streams 
WHERE reason_end <> 'trackdone' -- streams that end early have a reason_end that is not equal to 'trackdone'
GROUP BY reason_end
ORDER BY COUNT(stream_id) DESC;

/* INSIGHT
- There are a total of 10,625 streams.
- Approximately (50%) of streams end early. That is 1 in 2
- When stream end early, they are often by intentional user action:
	- 'forward skip - 55%, 
	- 'backward skip / remote - 8%'
*/


-- Act 1 Scene III: Which platforms do I listen on the most, and how does play length differ by platform?
SELECT 
    CASE 
        WHEN platform ILIKE '%android%' THEN 'Mobile'
        WHEN platform ILIKE '%windows%' THEN 'Personal Computer'
        ELSE 'Other'
    END AS stream_platform,
    (SUM(play_length_ms) / (1000 * 60 * 60)) || 'H ' ||
    ((SUM(play_length_ms) / (1000 * 60)) % 60) || 'M' AS total_listening_time
FROM streams
GROUP BY stream_platform
ORDER BY total_listening_time DESC;

-- Insight: My streaming platform are mobile and my personal computer. With 460 hours 54 minutes out of approximately 472 hours spent listening on mobile. That is ~98%

-- Act 1 Scene IV: How much of my listening happens offline vs online?
SELECT 
	CASE
		WHEN offline = 'true' THEN 'offline' ELSE 'online' END AS status,
	(SUM(play_length_ms) / (1000 * 60 * 60)) || 'H ' ||
	((SUM(play_length_ms) / (1000 * 60)) % 60) || 'M' total_listening_time
FROM streams
GROUP BY status
ORDER BY total_listening_time DESC;

-- Insight: My streaming is based overwhelmingly on internet connectivity (online)


-- Act 1 Scene V: What proportion of streams are skipped?
SELECT 
	skipped,
	COUNT(stream_id)
FROM streams
GROUP BY skipped;

--Insight: 42.6% of streams are skipped


