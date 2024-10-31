--10/22/24
--1 What range of years for baseball games played does the provided database cover?

SELECT 
	CONCAT(MIN(yearid), '-', MAX(yearid)) AS year_range
FROM managers;


--2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT * --playerid, MIN(height) as shortest
FROM people
--GROUP BY playerid
WHERE height IS NOT NULL 
ORDER BY height ASC
;


--3 Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT	pep.namefirst
	,	pep.namelast
	,	SUM(sal.salary)::INT::MONEY AS salary
FROM people AS pep
INNER JOIN salaries AS sal
	ON pep.playerid = sal.playerid
INNER JOIN (
			SELECT distinct(collegeplaying.schoolid)
			,	playerid
			FROM collegeplaying
			INNER JOIN schools
			ON collegeplaying.schoolid = schools.schoolid
			) AS school
	ON pep.playerid = school.playerid
WHERE school.schoolid = 'vandy'
GROUP BY pep.namefirst
	,	pep.namelast
ORDER BY salary DESC
--4 Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield'
	--WHEN POs IN('SS', '1B', '2B', '3B') THEn 'infield'
	WHEN pos = 'p'OR pos = 'C'THEN 'Battery' ELSE 'infield' END AS position 

--5 Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT
		ROUND(SUM(CAST(so AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_so
	,	(yearid/10)*10 AS decade
	,	ROUND(SUM(CAST(hr AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_hr
FROM teams
WHERE yearid>=1920
GROUP BY decade
ORDER by decade

--6 Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
SELECT p.playerid, p.namefirst, p.namelast,
     ROUND(((b.sb ::numeric / (b.sb + b.cs))*100),2) AS success_rate 
FROM people AS p
JOIN batting AS b ON p.playerid = b.playerid
WHERE b.yearid = 2016
  AND (b.sb + b.cs) >= 20
ORDER BY success_rate DESC
LIMIT 1;


--2nd attempt as a team
 select
		--   cs
		-- , sb
		-- , cs+sb
		CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, ROUND(sb::NUMERIC/(cs::NUMERIC+sb::NUMERIC)*100, 2) AS success_rate
	    , yearid
from batting
INNER JOIN people AS p
USING(playerid)
WHERE yearid = 2016 AND (cs+sb >= 20)
ORDER BY success_rate DESC
--

--7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--attempt1
--SELECT MAX (wins) AS max_wins_without_ws



SELECT 
    ((
        WITH max_wins_per_year AS (
            SELECT yearID, MAX(W) AS max_wins
            FROM Teams
            WHERE yearID BETWEEN 1970 AND 2016
            GROUP BY yearID
        ),
        yearly_top_team AS (
            SELECT t.yearID, t.teamID, t.W
            FROM Teams t
            JOIN max_wins_per_year m ON t.yearID = m.yearID AND t.W = m.max_wins
        )
        SELECT COUNT(*) 
        FROM yearly_top_team yt
        JOIN Teams t ON yt.yearID = t.yearID AND yt.teamID = t.teamID
        WHERE t.WSWin = 'Y'
    ) / 47.0) * 100 AS percentage_most_wins_championship;

--8 Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--9 Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--10 Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

--Looking for 
	--players that hit their career high homerun numbers in 2016 (player_career_high)
	--players must have also played in the league for 10 years (decade_players)
	--players must have also hit atleast one homerun in 2016 thats min (players_hit)


WITH player_career_high AS (
    --Finding each player's career-high home runs
    SELECT playerID, MAX(HR) AS MaxHR
    FROM Batting
    GROUP BY playerID
),
players_hit AS (
    -- home runs for players in 2016 who hit their career high
    SELECT b.playerID, b.HR AS hr_2016
    FROM Batting b
    JOIN player_career_high pch ON b.playerID = pch.playerID 
	AND b.HR = pch.MaxHR
    WHERE b.yearID = 2016 AND b.HR > 0
),
decade_players AS (
    -- players who have played at least 10 years
    SELECT playerID
    FROM Batting
    GROUP BY playerID
    HAVING COUNT(DISTINCT yearID) >= 10
)

SELECT concat(people.namefirst, ' ', people.namelast) AS full_name, p.playerID, p.hr_2016 AS home_runs_2016
FROM players_hit p
JOIN decade_players d ON p.playerID = d.playerID
JOIN people ON p.playerID = people.playerID
ORDER BY p.hr_2016 DESC;


------------------------------------------------------------------------
 WITH career_high_2016 AS (SELECT
								playerid
							,	max(hr) AS max_hr
								FROM batting
								GROUP BY playerid
								)
,		total_2016 AS (SELECT
							playerid
						,	SUM(hr) AS total_hr
							FROM batting
							WHERE yearid=2016
							GROUP BY playerid
							)
,			ten_or_more AS (SELECT distinct
								playerid
							FROM batting
							WHERE yearid <=2006
							)
SELECT
		concat(people.namefirst, ' ', people.namelast) AS full_name
	,	total_hr
	,	max_hr
	,	CASE WHEN total_hr>=max_hr THEN 'record' ELSE 'Not a record' END AS record
FROM people	
	INNER JOIN career_high_2016
		USING(playerid)
			INNER JOIN total_2016
				USING(playerid)
					INNER JOIN ten_or_more
						USING(playerid)
WHERE total_hr>0
ORDER BY total_hr DESC












































--------------------------------------------------------------------------------
WITH player_career_high AS (
    -- Step 1: Find each player's career-high home runs
    SELECT playerID, MAX(HR) AS career_high_hr
    FROM Batting
    GROUP BY playerID
),
players_2016 AS (
    -- Step 2: Get home runs for players in 2016 who hit their career high
    SELECT b.playerID, b.HR AS hr_2016
    FROM Batting b
    JOIN player_career_high pch ON b.playerID = pch.playerID AND b.HR = pch.career_high_hr
    WHERE b.yearID = 2016 AND b.HR > 0
),
ten_year_players AS (
    -- Step 3: Identify players who have played at least 10 years
    SELECT playerID
    FROM Batting
    GROUP BY playerID
    HAVING COUNT(DISTINCT yearID) >= 10
)
-- Final Query: Select players who meet all criteria without using the Master table
SELECT p.playerID, p.hr_2016 AS home_runs_2016
FROM players_2016 p
JOIN ten_year_players t ON p.playerID = t.playerID;
