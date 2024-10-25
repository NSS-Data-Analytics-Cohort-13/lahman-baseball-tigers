-- 1. What range of years for baseball games played does the provided database cover?  

SELECT 
		CONCAT(MIN(yearid),' ','to',' ',MAX(yearid)) AS years_range
FROM batting
INNER JOIN teams
USING(yearid)
INNER JOIN appearances
USING(yearid)
INNER JOIN allstarfull
USING(yearid)
INNER JOIN awardssharemanagers
USING(yearid)
INNER JOIN awardsmanagers
USING(yearid)
INNER JOIN awardsplayers
USING(yearid)
INNER JOIN awardsshareplayers
USING(yearid)
INNER JOIN halloffame
USING(yearid)
INNER JOIN managers
USING(yearid)
INNER JOIN pitching
USING(yearid)
INNER JOIN fielding
USING(yearid)
INNER JOIN fieldingofsplit
USING(yearid)
INNER JOIN fieldingpost
USING(yearid)

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT 
		CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, MIN(p.height) AS shortest_player
		, a.g_all AS num_of_played_games
		, t.name AS team
FROM people AS p
INNER JOIN appearances AS a
USING(playerid)
INNER JOIN teams AS t
ON a.teamid = t.teamid
WHERE a.playerid = 'gaedeed01'
GROUP BY p.playerid, a.teamid, team, a.g_all
ORDER BY shortest_player
   

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- SELECT 
-- 		  CONCAT(p.namefirst,' ',p.namelast) AS name
-- 		, a.teamid AS team
-- 		, t.name AS team_name
-- FROM people AS p
-- INNER JOIN appearances AS a
-- USING(playerid)
-- INNER JOIN teams AS t
-- USING(teamid)
-- WHERE t.name ilike 'Vanderbilt'
-- GROUP BY team, team.name, name
-- ORDER BY team;

-- FROM salarries


-- SELECT 
-- 		  sum(CONCAT(p.namefirst,' ',p.namelast)) AS full_name
-- 		, s.schoolname AS venue 
-- 		, sa.salary AS total_salary
-- FROM  schools AS s
-- INNER JOIN collegeplaying AS c
-- USING(schoolid)
-- INNER JOIN people AS p
-- USING(playerid)
-- INNER JOIN salaries AS sa
-- USING(playerid)
-- -- WHERE p.playerid = sa.playerid
-- where s.schoolname = 'Vanderbilt University'
-- --where schoolid = 'vandy'
-- GROUP BY venue, c.playerid
-- ORDER BY total_salary DESC;


-- SELECT schoolname
-- from  schools
-- where schoolname ilike '%an%'

SELECT
		  CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, s.schoolname AS venue
		, SUM(DISTINCT sa.salary) AS total_salary
FROM  schools AS s
INNER JOIN collegeplaying AS c
USING(schoolid)
INNER JOIN people AS p
USING(playerid)
INNER JOIN salaries AS sa
USING(playerid)
-- WHERE p.playerid = sa.playerid (Validation purposes)
where s.schoolname = 'Vanderbilt University'
--where schoolid = 'vandy' (Validation purposes)
GROUP BY venue, c.playerid, full_name--, total_salary
ORDER BY total_salary DESC;


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.


-- SELECT 
-- 		CASE 
-- 			WHEN pos = 'OF' THEN 'outfield'
-- 			WHEN pos = 'P' OR pos = 'C' THEN battery ELSE 'infield'
-- 		  , SUM(f.PO) AS toltal_po
-- FROM fielding AS f
-- WHERE yearid = 2016


SELECT
	CASE WHEN pos='OF' THEN 'Outfield'
		 --WHEN pos IN('SS', '1B', '2B', '3B') THEN 'Infield'
		 WHEN pos='P' OR pos='C' THEN 'Battery' ELSE 'Infield' END AS position
	,	SUM(fielding.po) AS total_po
FROM fielding
WHERE fielding.yearid=2016
GROUP BY position
   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?













SELECT max(yearid)
FROM appearances

select yearid
from fieldingofsplit

select *
from teams
where 

SELECT 
	CONCAT(MIN(yearid), '-', MAX(yearid)) AS year_range
FROM managers;

--
SELECT
		MIN(people.height/12) as min_height
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







9:21
LIMIT 1;
