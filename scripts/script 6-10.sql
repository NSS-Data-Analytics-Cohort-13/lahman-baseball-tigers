--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


SELECT 	CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, ROUND(sb::NUMERIC/(cs::NUMERIC+sb::NUMERIC)*100, 2) AS success_rate
	    , yearid
from batting
	INNER JOIN people AS p
		USING(playerid)
WHERE yearid = 2016 AND (cs+sb >= 20)
ORDER BY success_rate DESC




--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
--the who did not win the world series

--max wins, min wins who won the champion series
WITH	 wins_yes AS (SELECT yearid, 
			max(w) AS max_wins_y
			FROM teams
			WHERE wswin='Y' AND yearid>=1970
			GROUP BY yearid,g)
			
,		wins_min_yes AS (SELECT yearid,
			min (w) AS min_wins_y
			FROM teams
			WHERE wswin='Y' AND yearid>=1970
			GROUP BY yearid)
			
,		max_wins_no AS (SELECT yearid,
			max (w) AS max_wins_n
			FROM teams
			WHERE wswin='N' AND yearid>=1970
			GROUP BY yearid)
SELECT
	MAX (max_wins_y) as max_wins_yes
,	MIN(min_wins_y) as min_wins_yes
,	MAX (max_wins_n) as max_wins_no

FROM wins_yes
	INNER JOIN wins_min_yes
		USING (yearid)
	INNER JOIN max_wins_no
		USING (yearid)
WHERE yearid !=1981
LIMIT 1


--percentage
WITH max_wins_w AS (SELECT
					yearid, MAX(w) AS m_w
					FROM teams
					WHERE yearid>= 1970 AND wswin='Y'
					GROUP BY yearid)
,	max_wins_l AS (SELECT
					yearid, MAX(w) AS m_w
					FROM teams
					WHERE yearid>= 1970 AND wswin='N'
					GROUP BY yearid)
SELECT 
		SUM(CASE WHEN m.m_w >= m_l.m_w THEN 1 ELSE 0 END) AS sum_max_winner,
		(SUM(CASE WHEN m.m_w >= m_l.m_w THEN 1 ELSE 0 END)*1.0/COUNT(*)) *100 AS percentage
FROM max_wins_w AS m
	INNER JOIN max_wins_l m_l
		USING(yearid)
WHERE m.yearid !=1981







--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance. 

--run querry bu just picking homegames table
--picked park and team column to get names of park and team

SELECT park AS park_name
	,	 team AS team_name
	,	 attendance/games AS avg_attendance
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5

--run querry by just joining homegames,teams,and parks table
SELECT t.name as team_name
	,	 p.park_name
	,     homegames.attendance / games AS avg_attendance
FROM homegames
	INNER JOIN parks as p
		USING(park)
	INNER JOIN teams as t
		ON homegames.year=t.yearid
		AND homegames.team=t.teamid 
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

 


--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH nl_award AS (
    SELECT playerid, yearid
    FROM AwardsManagers
    WHERE awardid ILIKE '%tsn manager%' AND lgid = 'NL'
),
al_award AS (
    SELECT playerid, yearid
    FROM AwardsManagers
    WHERE awardid ILIKE '%tsn manager%' AND lgid = 'AL'
),
both_awards AS (
    SELECT nl.playerid
    FROM nl_award nl
    JOIN al_award al ON nl.playerid = al.playerid
)
SELECT DISTINCT
    (p.namefirst || ' ' || p.namelast) AS manager_name,
    t.name AS team_name
FROM
    AwardsManagers am
	INNER JOIN both_awards AS ba 
		ON am.playerid = ba.playerid
	INNER JOIN people AS p 
		ON am.playerid = p.playerid
	INNER JOIN managers AS m 
		ON am.playerid = m.playerid AND am.yearid = m.yearid
	INNER JOIN teams AS t 
		ON m.teamid = t.teamid AND am.yearid = t.yearid
ORDER BY
    manager_name;



--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

SELECT people.namefirst
	,	people.namelast
	,	b.hr AS hr_high
FROM batting AS b
	INNER JOIN people
		ON  b.playerid = people.playerid
AND (SELECT COUNT (DISTINCT yearid)
    FROM batting
--players had played in league for 10 years
	WHERE playerid = people.playerid) >= 10
--players had atleast 1 home run in 2016
AND b.hr >=1
--players career hit highest (hr) in 2016 
AND b.hr = (
        SELECT MAX(hr)
        FROM batting
        WHERE playerid = b.playerid
		AND b.yearid = 2016	
    )
GROUP BY people.namefirst,people.namelast,b.hr
 ORDER BY hr_high DESC




