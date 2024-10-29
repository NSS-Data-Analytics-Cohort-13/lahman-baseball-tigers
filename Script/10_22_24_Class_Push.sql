--1.What range of years for baseball games played does the provided database cover?
-- range of years baseball games
Select *
From appearances

Select yearid
From appearances

--Answer Version 1:
SELECT 
	CONCAT(MIN(yearid), '-', MAX(yearid)) AS year_range
FROM appearances;


--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- name, height of shortest player
-- how many games ^
-- what team ^^
SELECT *
FROM people

--2a. Answer
SELECT MIN(height) AS shortest_height
FROM people
--2b. Answer
Select people.namegiven, MIN(height/12) AS shortest_height
FROM people
WHERE height IS NOT NULL
GROUP BY namegiven
ORDER BY shortest_height ASC

--2c Final Answer: Combine All to answer question
SELECT namefirst, 
	namelast,
	namegiven,
	name AS team_name,
	yearid,
	--name = team played for
	(ROUND(MIN(height/12)::decimal,2)) AS shortest_height, SUM(appearances.g_all) as total_games 
FROM people
--making the min height show as shortest_height & adding the sum of total games played
--aka g_all to show as total_games
	LEFT JOIN appearances
	USING(playerid)
	LEFT JOIN teams
	USING(teamid, yearid)
	--bringing over playerid from appearances & teamid, yearid from teams
GROUP BY namefirst, namelast, playerid, appearances.teamid, yearid, team_name
--group by, how it appears in the output
ORDER BY shortest_height ASC
LIMIT 1;
--how it's sorted^

--Ref.
SELECT MIN (people.height) as min_height
	,	people.namegiven
	,	SUM(appearances.g_all) as total_games
	,	teams.franchid
FROM people
	INNER JOIN appearances
		USING(playerid)
	INNER JOIN teams
		USING(teamid)
GROUP BY people.playerid, name, teams.franchid
ORDER BY min_height
LIMIT 1;

--3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- players from Vanderbuilt (david price 81 mill)
-- first name, last name, total salary (major leagues)
-- sort by desc total salary
-- who earned the most money

 --Attempt 1
 WITH highest_salaries AS (
						SELECT
								SUM(salaries.salary) AS total_salary
							,	salaries.playerid
						FROM salaries
						GROUP BY salaries.playerid
							)
					
,	vandy_players AS (SELECT
								schools.schoolid
							,	schools.schoolname
						FROM schools
						WHERE schools.schoolname iLIKE '%Vanderbilt%'
						GROUP BY schools.schoolid, schools.schoolname
							)	
SELECT
		concat(people.namefirst, ' ', people.namelast) AS name
	,	highest_salaries.total_salary
	,	highest_salaries.playerid
	,	collegeplaying.schoolid
	,	vandy_players.schoolid
	,	vandy_players.schoolname
FROM highest_salaries
	INNER JOIN people
		ON highest_salaries.playerid=people.playerid
	INNER JOIN collegeplaying
		ON people.playerid=collegeplaying.playerid
	INNER JOIN vandy_players
		ON collegeplaying.schoolid=vandy_players.schoolid
ORDER BY total_salary DESC
LIMIT 1;

--Attempt 2
SELECT
		  CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, s.schoolname AS venue
		, SUM(sa.salary) AS total_salary
FROM  schools AS s
INNER JOIN collegeplaying AS c
USING(schoolid)
INNER JOIN people AS p
USING(playerid)
INNER JOIN salaries AS sa
USING(playerid)
-- WHERE p.playerid = sa.playerid
where s.schoolname = 'Vanderbilt University'
--where schoolid = 'vandy'
GROUP BY venue, c.playerid, full_name
ORDER BY total_salary DESC;

--4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
-- group the fielding table as follows
-- OF as "Outfield"
-- "SS", "1B", "2B", and "3B" as "Infield"
-- "P" or "C" as "Battery"
-- Determine the number of putouts made by each of these three groups in 2016.
--Attempt 1
SELECT po
FROM fielding
JOIN "OF" AS "Outfield"
JOIN "SS","1B","2B","3B" AS "Infield"
JOIN "P", "C" AS "Battery"
GROUP BY

--Attempt 2
SELECT po
FROM fielding
	INNER JOIN appearances
		USING(playerid)
	INNER JOIN teams
		USING(teamid)
GROUP BY people.playerid, name, teams.franchid
ORDER BY min_height
--Attempt 3
SELECT f.po,
       f.pos
       FROM fielding f
	   WHERE pos IS "OF" AS "Outfield"
	   WHERE pos IS "SS","1B","2B","3B" AS "Infield"
	   WHERE pos IS "P","C" AS "Battery"
       GROUP BY f.po,
                f.pos
       HAVING count(*) = (SELECT count(*)
                                 FROM elbat t2
                                 WHERE t2.bookname = t1.bookname
                                 GROUP BY t2.bookname,
                                          t2.bookauthor
										   	HAVING count(*) = (SELECT count(*)
                                	        FROM elbat t2
                                 	 	 	WHERE t2.bookname = t1.bookname
                                  	 	 	GROUP BY t2.bookname,
                                           t2.bookauthor
                                	 	    ORDER BY count(*) DESC
                                 	 	    LIMIT 1);
--Attempt 4
SELECT
	CASE WHEN pos='OF' THEN 'Outfield'
		 --WHEN pos IN('SS', '1B', '2B', '3B') THEN 'Infield'
		 WHEN pos='P' OR pos='C' THEN 'Battery' ELSE 'Infield' END AS position
	,	SUM(fielding.po) AS total_po
FROM fielding
WHERE fielding.yearid=2016
GROUP BY position

 
--5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- Avg Strikeout per game by year since 1920
-- Round the numbers to 2 decimal places
-- Same for home runs per game
-- any trends?
SELECT	yearid / 10 * 10 AS decade
	,	ROUND(SUM(so)::NUMERIC / SUM(g)::NUMERIC, 2) AS avg_so_game
	,	ROUND(SUM(hr)::NUMERIC / SUM(g)::NUMERIC, 2) AS avg_hr_game
FROM teams
WHERE yearid >=1920
GROUP by decade
ORDER BY decade;


--6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
--player (most stealing bases in 2016)
--percentage of successful stolen base attempts
--at least 20 stolen bases or more
SELECT sb
FROM batting

SELECT cs
FROM batting


SELECT b.playerid,
	pl.namefirst,
	pl.namelast,
	b.sb::decimal,
	b.cs::decimal,
	--b = batting, pl = people, sb = stolen bases, cs = caught stealing,
	ROUND((b.sb::decimal / (b.sb::decimal + b.cs::decimal)),2) AS stolen_bases_sucess
	--'::' used to convert one data type to another
FROM batting AS b
LEFT JOIN people AS pl ON b.playerid = pl.playerid
WHERE b.yearid = '2016'
	AND b.sb + b.cs >= 20
ORDER BY stolen_bases_sucess DESC

--7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
--largest wins for a team (and didnt win world series)
--smallest wins for a team (did win world series)
need answer 

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- (attendance from homegames table
-- (teams & parks Top 5 average attendance per game in 2016
-- Info: Average attendance = total attendance / number of games
-- (only parks with at least 10 games
-- Park name, Team name, Average attendance
-- Repeat for the lowest 5 average attendance
(SELECT park_name,
       t.name AS team_name,
       ROUND((AVG(h.attendance)/h.games),0) AS avg_attendance,
       'TOP 5' AS ranking
FROM homegames AS h 
INNER JOIN parks AS p
USING (park)
	LEFT JOIN teams AS t
	ON t.park =p.park_name
WHERE year= '2016'
AND games >'10'
AND t.yearid = '2016'
GROUP BY park_name,t.name,games
ORDER BY avg_attendance DESC
LIMIT 5)
UNION
(SELECT park_name,
       t.name AS team_name,
       ROUND((AVG(h.attendance)/h.games),0) AS avg_attendance,
       'BOTTOM 5' AS ranking
FROM homegames AS h 
INNER JOIN parks AS p
USING (park)
	LEFT JOIN teams AS t
	ON t.park =p.park_name
WHERE year= '2016'
AND games >'10'
AND t.yearid = '2016'
GROUP BY park_name,t.name,games
ORDER BY avg_attendance ASC
LIMIT 5)
ORDER BY Avg_attendance DESC;

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
-- (managers won TSN Manager of the Year award
-- (National league & American league
-- Full name & team they managed at the time of award
WITH tsn_managers AS (
SELECT playerid, yearid, lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND lgid IN ('NL', 'AL')

), man_by_year AS (
SELECT DISTINCT tsn.playerid, tsn.yearid
FROM tsn_managers AS tsn
JOIN tsn_managers AS tsn2
ON tsn.playerid = tsn2.playerid
AND tsn.lgid <> tsn2.lgid
)
SELECT p.namefirst, p.namelast, t.name, m.yearid
FROM man_by_year AS mby

INNER JOIN managers AS m
ON mby.playerid = m.playerid
AND mby.yearid = m.yearid

INNER JOIN people AS p
ON mby.playerid = p.playerid

INNER JOIN teams AS t
ON mby.yearid = t.yearid
AND m.teamid = t.teamid

ORDER BY namefirst

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
-- (players with their career highest number homes runs in 2016
-- (played in the league 10+ years
-- (hit at least 1 home run in 2016
-- First name, Last name, Number of home runs they hit in 2016
needs answer
