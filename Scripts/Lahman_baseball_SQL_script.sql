SELECT DISTINCT year
FROM homegames
ORDER BY year

-------------------------------------------------------------------------------------------------
--1. What range of years for baseball games played does the provided database cover? 
SELECT concat(MIN(yearid),'-',MAX(yearid))
FROM appearances
--ORDER BY yearid


SELECT * FROM appearances


SELECT DISTINCT yearid
FROM appearances
WHERE yearid BETWEEN (SELECT MIN(yearid)
FROM appearances
WHERE yearid >=1871
) AND (SELECT MAX(yearid) 
FROM appearances
WHERE yearid<=2016)


-----------------------------------------------------------------------------------------------------
--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--need shortest height from people
--need the team.id they played for from teams
--need the number of games
--need playerid from people
 SELECT *
 FROM appearances
 WHERE name= 'Eddie Gaedel'



SELECT * FROM people

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
LIMIT 1;

------------------------------------------
SELECT
		MIN(people.height/12) as min_height
	,	people.namegiven
	,	SUM(appearances.g_all) as total_games
	,	teams.teamid
FROM people
	INNER JOIN appearances
		USING(playerid)
	INNER JOIN teams
		USING(teamid)
GROUP BY people.playerid, name, teams.teamid
ORDER BY min_height
LIMIT 1;
--------------------------------------------------
--google searched player only appeared in one game
SELECT
		MIN(people.height/12) as min_height
	,	concat(people.namefirst, ' ', people.namelast) AS name
	--,	SUM(appearances.g_all) as total_games
	,	appearances.g_all
	,	teams.name
FROM people
	INNER JOIN appearances
		USING(playerid)
	INNER JOIN teams
		USING(teamid)
GROUP BY people.playerid, teams.name, appearances.g_all
ORDER BY min_height
LIMIT 1;

------------
SELECT p.namefirst, p.namelast
	,	 min(p.height) as height
	,	 a.g_all as GamesPlayed
	,	 t.name as TeamName
FROM people AS p
	INNER JOIN appearances AS a
		ON p.playerid = a.playerid
	INNER JOIN teams AS t
		ON a.teamid = t.teamid
GROUP BY p.namefirst, p.namelast, a.g_all, t.name
ORDER BY height
LIMIT 1



-- declare @inches int
-- set@inches=43

-----------------------------------------------------------------------------------------------------
--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
--concat(people.namefirst, ' ', people.namelast) AS name
--Join people and collegeplaying by playerid
--Join people and salaries table on playerID
--use salaries.salary
--collegeplaying.playerid
--join on collegeplaying.school id from collegeplaying to schools table

WITH highest_salaries AS (
						SELECT 
								SUM(salaries.salary) AS total_salary
							,	salaries.playerid
						FROM salaries
						GROUP BY salaries.playerid
							)
SELECT 
		concat(people.namefirst, ' ', people.namelast) AS name
	,	highest_salaries.total_salary
	,	highest_salaries.playerid
FROM highest_salaries
	INNER JOIN people
		ON highest_salaries.playerid=people.playerid
ORDER BY total_salary DESC

--------------------------------------------------------
--adding in players from vanderbilt adding additional with statement


WITH highest_salaries AS (
						SELECT 
								SUM(salaries.salary)::INT::MONEY AS total_salary
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
----------------------------------------
SELECT
		  CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, s.schoolname AS venue
		, --SUM(DISTINCT sa.salary) AS total_salary
		,	COUNT(sa.salary) AS total_salary
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
GROUP BY venue, c.playerid, full_name--, total_salary
ORDER BY total_salary DESC;


SELECT *
FROM salaries

select * FROM schools

-----------------------------------------------------------------------------------------------------
--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT * FROM fielding

SELECT (CASE WHEN fielding.pos='OF' THEN 'Outfield' END) AS Outfield
	,  (CASE WHEN fielding.pos IN('SS', '1B', '2B', '3B') THEN 'Infield' END) AS Infield
	,  (CASE WHEN fielding.pos='P' THEN 'Battery'
			 WHEN fielding.pos='C' THEN 'Battery' END) AS Battery
FROM fielding

----------------------
--new approach. Maybe CTE a table for each of the criteria then use the select statement at the emd to determine putouts and year of 2016?

WITH position_one AS (SELECT
						fielding.pos
					,	fielding.yearid
					,	fielding.po
						FROM fielding
						WHERE fielding.pos iLIKE '%OF%')

,	 position_two AS (SELECT
						fielding.pos
					,	fielding.yearid
					,	fielding.po
						FROM fielding
						WHERE fielding.pos IN('SS', '1B', '2B', '3B'))

,	 position_three AS (SELECT
						fielding.pos
					,	fielding.yearid
					,	fielding.po
						FROM fielding
WHERE fielding.pos='C' AND fielding.pos='P')
----------------------------------------------
--Correct
SELECT 
	CASE WHEN pos='OF' THEN 'Outfield' 
		 --WHEN pos IN('SS', '1B', '2B', '3B') THEN 'Infield'
		 WHEN pos='P' OR pos='C' THEN 'Battery' ELSE 'Infield' END AS position
	,	SUM(fielding.po) AS total_po
FROM fielding
WHERE fielding.yearid=2016
GROUP BY position

----------------------------------------------------------------------------------------------------
--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--ROUND(AVG(batting.so),2)
--ROUND(AVG(batting.hr),2)
--WHERE batting.year>FLOOR(1920/10)

WITH avg_so       AS (SELECT 
				  ROUND(AVG(batting.so),2) AS avg_so	
				  FROM batting)
,	 since_1920   AS (SELECT *
						FROM batting
						WHERE batting.year>((1920/10)*10) AS decade)
SELECT *
FROM avg
----------------------------------------------------
--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--ROUND(AVG(batting.so),2)
--ROUND(AVG(batting.hr),2)
--WHERE batting.year>FLOOR(1920/10)

SELECT 
		ROUND(AVG(so),2)/g AS avg_so
	,	(yearid/10)*10 AS decade
	,	ROUND(AVG(batting.hr),2)/g AS avg_hr
FROM batting
WHERE yearid>1920
GROUP BY decade, g
ORDER by decade
-------------------------
SELECT
	(yearid/10)*10 AS decade
,	ROUND(AVG(SO+SOA), 2)/g AS avg_strikeouts_game
,	ROUND(AVG(HR+HRA), 2)/g AS avg_homeruns_game
FROM teams
WHERE yearid >= 1920
GROUP BY
	decade, g
ORDER BY
	avg_strikeouts_game
,	avg_homeruns_game

SELECT *
FROM teams









