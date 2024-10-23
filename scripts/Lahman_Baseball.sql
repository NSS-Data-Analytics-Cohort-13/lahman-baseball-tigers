-- 1. What range of years for baseball games played does the provided database cover? 

SELECT 
		  G_all
		, yearid
FROM appearances

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT 
		  CONCAT(p.namefirst,' ',p.namelast) 
		, MIN(height) AS shortest_player
FROM people AS p
-- INNER JOIN appearances AS a
-- USING(playerid)
-- WHERE 
GROUP BY playerid
ORDER BY shortest_player;
   

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
   
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
