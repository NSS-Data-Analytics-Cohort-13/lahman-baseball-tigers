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

--Answer Version 2 (in progress)
SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id;


--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- name, height of shortest player
-- how many games ^
-- what team ^^
SELECT *
FROM people

--1. Answer
SELECT MIN(height) AS shortest_height
FROM people
--2. Answer
Select people.namegiven, MIN(height/12) AS shortest_height
FROM people
WHERE height IS NOT NULL
GROUP BY namegiven
ORDER BY shortest_height ASC
--3.
SELECT height, 
FROM appearances

--Ref 3.
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

 
--5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- Avg Strikeout per game by year since 1920
-- Round the numbers to 2 decimal places
-- Same for home runs per game
-- any trends?
