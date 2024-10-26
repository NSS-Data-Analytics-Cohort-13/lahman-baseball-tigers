--1. What range of years for baseball games played does the provided database cover? 

--used concat to to show the rsult in one column
SELECT 
	CONCAT(MIN(yearid), '-', MAX(yearid)) AS year_range
FROM appearances; 

--as we heav year id from many tables 
SELECT min(span_first) as FirstYear, max(span_last) as LastYear 
FROM homegames


--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--find the shortestpalyer
--select * from people where 

SELECT p.namefirst, p.namelast
	,	 min(p.height) as height
	,	 a.g_all as Games_played
	,	 t.name as team_name
FROM people AS p 
	INNER JOIN appearances AS a 
		USING (playerid)  --ON p.playerid = a.playerid
	INNER JOIN teams AS t 
		USING (teamid) --ON a.teamid = t.teamid
GROUP BY p.namefirst, p.namelast, a.g_all, t.name
ORDER BY height
LIMIT 1 


--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT p.namefirst, p.namelast
	,	 sum(DISTINCT sal.salary)::INT::MONEY as TotalSalary
FROM schools AS s 
	INNER JOIN collegeplaying AS c 
		USING (schoolid)--ON s.schoolid = c.schoolid
	INNER JOIN people AS p 
		USING (playerid)--ON c.playerid = p.playerid
	INNER JOIN salaries AS sal 
		USING (playerid) --on sal.playerid = p.playerid
WHERE schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast
ORDER BY TotalSalary DESC


--followed results with subquerry
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
			WHERE schoolname = 'Vanderbilt University'
			) AS school
	ON pep.playerid = school.playerid
GROUP BY pep.namefirst 
	,	pep.namelast
ORDER BY salary DESC





--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.


SELECT 
	CASE 
		WHEN Pos = 'OF' THEN 'Outfield'
			WHEN pos = 'P' OR pos = 'C' THEN 'Battery' else 'infield'
		END AS positions
	,	sum(fielding.Po) AS total_putouts
FROM fielding 
WHERE fielding.yearid = 2016
GROUP BY positions
	

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

-- select * from teams
-- sum of stikeouts
--sum of home runs
--for average devide it by sum of games
--round it do 2 decimal places


SELECT	yearid / 10 * 10 AS decade
	,	ROUND(SUM(so)::NUMERIC / SUM(g)::NUMERIC, 2) AS avg_so_game
	,	ROUND(SUM(hr)::NUMERIC / SUM(g)::NUMERIC, 2) AS avg_hr_game
--	,	ROUND(SUM(CAST(so AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_so
--	,	ROUND(SUM(CAST(hr AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_hr
FROM teams
WHERE yearid >=1920
GROUP by decade
ORDER BY decade;

--if you take stikeouts from pitching table
SELECT	yearid / 10 * 10 AS decade
	,	ROUND(SUM(so) / SUM(g)::NUMERIC, 2) AS avg_so_game
	,	ROUND(SUM(hr) / SUM(g)::NUMERIC, 2) AS avg_hr_game
FROM pitching
WHERE yearid >=1920
GROUP by decade
ORDER BY decade;






