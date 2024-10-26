SELECT DISTINCT year
FROM homegames
ORDER BY year

-------------------------------------------------------------------------------------------------
--1. What range of years for baseball games played does the provided database cover? 
--correct
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
	,	teams.name as team_name
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
								SUM(DISTINCT salaries.salary)::INT::MONEY AS total_salary
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
--LIMIT 1;
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

--correct
SELECT 
		ROUND(SUM(CAST(so AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_so
	,	(yearid/10)*10 AS decade
	,	ROUND(SUM(CAST(hr AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_hr
FROM teams
WHERE yearid>=1920
GROUP BY decade
ORDER by decade

-------------------------------------------------------------------------------------------------------------------------

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
--Correct

SELECT ROUND((CAST(sb AS NUMERIC) / (CAST(sb+cs AS NUMERIC))),3) *100 || '%' AS percentage_success
	,	CONCAT(namefirst,' ',namelast) AS full_name
	, 	yearid
	--,	sb
	--,	cs
FROM batting
	inner join people
		USING(playerid)
WHERE yearid=2016 AND sb+cs>=20
ORDER BY percentage_success DESC

SELECT * FROM batting
------------------------------------------
SELECT ((SUM(sb) / (SUM(sb+cs)) *100 AS percentage_success
	,	CONCAT(namefirst,' ',namelast) AS full_name
	, 	yearid
	--,	sb
	--,	cs
FROM batting
	inner join people
		USING(playerid)
WHERE yearid=2016 AND sb>20
ORDER BY percentage_success DESC
------------------------------------
SELECT (CAST (sb AS NUMERIC) / (CAST(sb+cs AS NUMERIC))) *100 AS percentage_success
	,	CONCAT(namefirst,' ',namelast) AS full_name
	, 	yearid
	--,	sb
	--,	cs
FROM batting
	inner join people
		USING(playerid)
WHERE yearid=2016 AND sb>20
ORDER BY percentage_success DESC
-------------------------------------------------------------------------------------------------------------

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT 	
		yearid
	,	teamid
	,	MAX(w) AS max_wins
	,	MIN(w) AS min_wins
	,	CASE WHEN wswin='Y' THEN 'Winner'
			 WHEN  wswin='N' THEN 'Loser' ELSE 'Didnt Make WS' END AS ws_win_loss

FROM teams
WHERE yearid BETWEEN 1970 AND 2016
GROUP BY yearid, teamid, wswin
ORDER BY max_wins DESC, min_wins ASC

--2001	"SEA"	116	 "Loser"
--1981	"LAN"	63	"Winner"	
-------------------------------------------
--i need to find the percentage also use a CTE too many rows

WITH  wins_yes AS (SELECT --teamid,
				max(w) AS max_wins_y
				FROM teams
				WHERE wswin='Y')
				--GROUP BY teamid)
				
,     wins_min_yes AS (SELECT --teamid,
				min(w) AS min_wins_y
				FROM teams
				WHERE wswin='Y')
				--GROUP BY teamid)

,         max_wins_no AS (SELECT --teamid,
				max(w) AS max_wins_n
				FROM teams
				WHERE wswin='N')
				--GROUP BY teamid)

SELECT max_wins_y
	,	min_wins_y
	,	max_wins_n
FROM wins_yes, wins_min_yes, max_wins_no
FROM teams
	INNER JOIN wins_yes
		USING(teamid)
			INNER JOIN wins_min_yes
				USING(teamid)
					INNER JOIN max_wins_no
						USING(teamid)
GROUP BY max_wins_y
	,	min_wins_y
	,	max_wins_n
ORDER BY max_wins_y DESC
	,	min_wins_y
	,	max_wins_n 
-----------------------------------------------------------
SELECT 	
		yearid
	,	teamid
	--,	MAX(w) AS max_wins
	--,	MIN(w) AS min_wins
	,	CASE WHEN wswin='Y' THEN 'Winner'
			 WHEN  wswin='N' THEN 'Loser' ELSE 'Didnt Make WS' END AS ws_win_loss

FROM teams
WHERE yearid>=1970 AND yearid !=1981
GROUP BY yearid, teamid, wswin
ORDER BY max_wins DESC, min_wins ASC


--2006	"SLN"	83	"Winner"

-------------------
SELECT * FROM teams
--"1871-2016"



--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT 
		name
	,	park_name
	,	ROUND(CAST(homegames.attendance AS NUMERIC)/CAST(homegames.games AS NUMERIC),2) AS avg_attendance	
FROM homegames
		INNER JOIN parks
			USING(park)
				INNER JOIN teams
					ON homegames.year=teams.yearid
					AND homegames.team=teams.teamid
WHERE games>=10 AND year=2016
ORDER BY avg_attendance DESC
LIMIT 5;
---------------------------------------

SELECT 
		name
	,	park_name
	,	ROUND(CAST(homegames.attendance AS NUMERIC)/CAST(homegames.games AS NUMERIC),2) AS avg_attendance	
FROM homegames
		INNER JOIN parks
			USING(park)
				INNER JOIN teams
					ON homegames.year=teams.yearid
					AND homegames.team=teams.teamid
WHERE games>=10 AND year=2016
ORDER BY avg_attendance ASC
LIMIT 5;
-----------------------------------------------------------------------------------------------------------------------

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT 
		concat(people.namefirst, ' ', people.namelast) AS full_name
	,	lgid
	,	lgid
	,	awardid
FROM awardsmanagers
	INNER JOIN people
		USING(playerid)
WHERE awardid='TSN Manager of the Year' AND lgid IN('AL', 'NL') --(--lgid='AL' AND lgid='NL')
GROUP BY full_name, lgid, awardid


--"Davey Johnson"	"AL"	"TSN Manager of the Year"
--"Davey Johnson"	"NL"	"TSN Manager of the Year"
--WHERE lgid='AL' AND lgid='NL' AND awardid='TSN Manager of the Year'
----------------------------------------------------------------------
--Going to try using CTEs to pull from. only need 2 names missing managers table. 

WITH award AS (
				SELECT awardid
					,	playerid
				FROM awardsmanagers
			    WHERE awardid='TSN Manager of the Year' AND lgid IN('AL', 'NL')
				)
-- --,	nl_league AS (SELECT lgid
-- 						,	playerid
-- 					-FROM awardsmanagers
-- 					WHERE lgid='NL'
-- 					)	
-- --,	al_league AS (
-- 					--SELECT lgid
-- 						,	playerid
-- 					FROM awardsmanagers
-- 					WHERE lgid='AL'
-- 					)

SELECT 
		concat(people.namefirst, ' ', people.namelast) AS full_name
	--,	award.awardid
	,	awardsmanagers.lgid
	--,	playerid
	--,	teamid
FROM awardsmanagers
	INNER JOIN award
		ON awardsmanagers.playerid=award.playerid
			--INNER JOIN nl_league
				--ON awardsmanagers.playerid=nl_league.playerid
					--INNER JOIN al_league
						--ON awardsmanagers.playerid=al_league.playerid
							INNER JOIN people
								ON awardsmanagers.playerid=people.playerid

GROUP BY full_name, award.awardid, awardsmanagers.lgid
ORDER BY full_name


-----------------------------------------------------------------------------------------------------------------


--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH 



























