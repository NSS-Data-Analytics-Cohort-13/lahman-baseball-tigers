-- 1. What range of years for baseball games played does the provided database cover?  

SELECT 
		CONCAT(MIN(yearid),' ','to',' ',MAX(yearid)) AS years_range
FROM batting
-- INNER JOIN teams
-- USING(yearid)
-- INNER JOIN appearances
-- USING(yearid)
-- INNER JOIN allstarfull
-- USING(yearid)
-- INNER JOIN awardssharemanagers
-- USING(yearid)
-- INNER JOIN awardsmanagers
-- USING(yearid)
-- INNER JOIN awardsplayers
-- USING(yearid)
-- INNER JOIN awardsshareplayers
-- USING(yearid)
-- INNER JOIN halloffame
-- USING(yearid)
-- INNER JOIN managers
-- USING(yearid)
-- INNER JOIN pitching
-- USING(yearid)
-- INNER JOIN fielding
-- USING(yearid)
-- INNER JOIN fieldingofsplit
-- USING(yearid)
-- INNER JOIN fieldingpost
-- USING(yearid)

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

SELECT
		  CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, s.schoolname AS venue
		, SUM(DISTINCT sa.salary)::int::money AS total_salary
FROM  schools AS s
INNER JOIN collegeplaying AS c
USING(schoolid)
INNER JOIN people AS p
USING(playerid)
INNER JOIN salaries AS sa
USING(playerid)
-- WHERE p.playerid = sa.playerid (Validation purposes)
WHERE s.schoolname = 'Vanderbilt University'
--where schoolid = 'vandy' (Validation purposes)
GROUP BY venue, c.playerid, full_name--, total_salary
ORDER BY total_salary DESC;

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




-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.


SELECT 
	   CASE WHEN pos = 'OF' THEN 'outfield'
			WHEN pos = 'P' OR pos = 'C' THEN 'battery' ELSE 'infield' END AS positions
		  , SUM(po) AS total_po
FROM fielding
WHERE yearid = 2016
GROUP BY positions


-- SELECT ---team query 
-- 	CASE WHEN pos = 'OF' THEN 'Outfield'
-- 		 --WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
-- 		 WHEN pos='P' OR pos='C' THEN 'Battery' ELSE 'Infield' END AS position
-- 	,	SUM(fielding.po) AS total_po
-- FROM fielding
-- WHERE fielding.yearid=2016
-- GROUP BY position

-- SELECT
-- 		ROUND(SUM(CAST(so AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_so
-- 	,	(yearid/10)*10 AS decade
-- 	,	ROUND(SUM(CAST(hr AS numeric))/SUM(CAST(g AS numeric)),2) AS avg_hr
-- FROM teams
-- WHERE yearid>=1920
-- GROUP BY decade
-- ORDER by decade


-- select *
-- from fielding

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT 
		ROUND(SUM(so)/SUM(g)::NUMERIC, 2) AS avg_so --/games
	  , ROUND(SUM(hr)/SUM(g)::NUMERIC, 2) AS avg_hr ---/games
	  , yearid/10 * 10 AS decade 
FROM teams
WHERE yearid >= 1920 
GROUP BY decade
ORDER BY decade;

_____









--6:Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


-- select 
-- 		  cs
-- 		, sb
-- 	    , (select yearid from teams where yearid = 2016)
-- from teams
-- where cs >= 20 OR sb >= 20

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
ORDER BY success_rate DESC;



--7: From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--What is the smallest number of wins for a team that did win the world series? 
--Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
--Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

7 perceentage) WITH max_wins_w AS (SELECT
					yearid, MAX(w) AS m_w
					FROM teams
					WHERE yearid>= 1970 AND wswin='Y'
					GROUP BY yearid)
,	max_wins_l AS (SELECT
					yearid, MAX(w) AS m_w
					FROM teams
					WHERE yearid>= 1970 AND wswin='N'
					GROUP BY yearid)
SELECT --yearid
	--,	m.m_w AS most_win_ws_winner
	--,	m_l.m_w AS most_win_ws_loser
		--COUNT(CASE WHEN m.m_w >= m_l.m_w THEN 'max win win' END),
		SUM(CASE WHEN m.m_w >= m_l.m_w THEN 1 ELSE 0 END) AS sum_max_winner,
		(SUM(CASE WHEN m.m_w >= m_l.m_w THEN 1 ELSE 0 END)*1.0/COUNT(*)) *100 AS percentage
FROM max_wins_w AS m
	INNER JOIN max_wins_l m_l
		USING(yearid)
WHERE m.yearid !=1981


-- SELECT 
-- 	      MAX(w) AS max_win
-- 		, MIN(w) AS min_win
-- 		, yearid
-- FROM teams
-- where yearid BETWEEN 1970 AND 2016
-- GROUP BY yearid
-- ORDER BY yearid


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


SELECT 
		p.park_name
	  , t.name AS team_name
	  , ROUND(CAST(h.attendance AS NUMERIC)/CAST(h.games AS NUMERIC), 2) avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
USING(park)
INNER JOIN teams AS t 
ON h.year =  t.yearid
WHERE h.year = 2016 AND h.games >= 10
ORDER BY avg_attendance DESC;

LIMIT 5 ASC


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

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.


SELECT 
		      
		  distinct CONCAT(p.namefirst,' ',p.namelast) AS full_name
		--
		-- , nl.lgid
		-- , nl.nl_yearid
		, t.name AS nlteamname
		, al.lgid
		-- , al.al_yearid
		--  , ta.name as alteamname
FROM (SELECT 
		      playerid
		    , yearid AS nl_yearid
			, lgid
		  --, awardid
FROM awardsmanagers
WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year') AS nl
INNER JOIN (SELECT 
		      playerid
		    , yearid AS al_yearid
			, lgid
		  --, awardid
FROM awardsmanagers
WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year') AS al
ON nl.playerid = al.playerid
INNER JOIN people AS p
ON p.playerid = nl.playerid
left JOIN managers AS m
ON m.playerid = p.playerid AND  m.yearid = nl.nl_yearid
left JOIN managers AS ma
ON ma.playerid = p.playerid AND  ma.yearid = al.al_yearid
left JOIN teams AS t
ON t.teamid = m.teamid AND t.yearid = nl.nl_yearid 
left JOIN teams AS ta
ON ta.teamid = ma.teamid AND ta.yearid = al.al_yearid





--ON nl_award.yearid = al_award.yearid --AND nl_award.playerid = al_award.playerid
-- INNER JOIN people AS p
-- ON p.playerid = man.playerid
-- INNER JOIN managers AS m
-- ON m.playerid = p.playerid AND m.yearid = man.yearid 
-- INNER JOIN teams AS t
-- ON t.teamid = m.teamid AND t.yearid = man.yearid 
-- ORDER BY full_name, team_name


--  SELECT *





-- SELECT 
-- 		  playerid
-- 		, yearid
-- 		, awardid
-- 		, lgid
-- FROM awardsmanagers
-- WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year' --AND playerid ILIKE 'coxbo01'
-- UNION
-- SELECT 
-- 		  playerid
-- 		, yearid
-- 		, awardid
-- 		, lgid
-- FROM awardsmanagers
-- WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year' --AND playerid ILIKE 'coxbo01'
-- INNER JOIN awardsmanagers AS am
-- ON nl_award.playerid = am.playerid  



-- SELECT 
-- 		  CONCAT(p.namefirst,' ',p.namelast) AS full_name
-- 		, am.awardid
-- 		, t.teamid AS team_name
-- 		, am.lgid
-- FROM awardsmanagers AS am
-- FULL JOIN people AS p
-- USING(playerid)
-- FULL JOIN managershalf AS m
-- ON p.playerid = m.playerid
-- FULL JOIN teams AS t
-- ON t.teamid = m.teamid
-- WHERE am.lgid IN ('AL','NL') AND am.awardid ILIKE 'TSN%' AND t.teamid IS NOT NULL  
-- GROUP BY am.awardid, am.lgid, full_name, team_name
-- ORDER BY am.awardid


-- SELECT 

-- SELECT 
-- 		  CONCAT(p.namefirst,' ',p.namelast) AS full_name
-- 		, am.awardid
-- 		, t.teamid AS team_name
-- 		, am.lgid
-- FROM awardsmanagers AS am
-- FULL JOIN people AS p
-- USING(playerid)
-- FULL JOIN managershalf AS m
-- ON p.playerid = m.playerid
-- FULL JOIN teams AS t
-- ON t.teamid = m.teamid
-- WHERE am.lgid = 'AL' AND am.lgid = 'NL' AND am.awardid = 'TSN%' AND t.teamid IS NOT NULL  
-- GROUP BY am.awardid, am.lgid, full_name, team_name
-- ORDER BY am.awardid




(SELECT am.awardid FROM awardsmanagers WHERE awardid ILIKE 'TSN%') AS tsn_winner_managers

SELECT *  FROM awardsmanagers
SELECT * FROM parks
select * from homegames
select * from teams
--am.awardid = 'TNS%' AND am.lgid IN('AL','NL')

--Team query
WITH award_al AS (
				SELECT --awardid
						DISTINCT playerid, yearid
				FROM awardsmanagers
			    WHERE lgid='AL'
				AND awardid='TSN Manager of the Year' AND playerid IN('johnsda02', 'leylaji99')
				)
,	award_nl AS (
				SELECT --awardid,
				DISTINCT playerid, yearid
				FROM awardsmanagers
				WHERE lgid='NL' AND awardid='TSN Manager of the Year' AND playerid IN('johnsda02', 'leylaji99'))
SELECT  DISTINCT
		teams.name AS team_name
	,	concat(people.namefirst, ' ', people.namelast) AS full_name
	--,	awardsmanagers.lgid
	--,   managers.playerid
	,	'TSN Manager of the Year'
FROM managers
	LEFT JOIN award_nl
		ON managers.playerid=award_nl.playerid AND managers.yearid=award_nl.yearid
			 JOIN people
				ON managers.playerid=people.playerid
					 --JOIN managers
						--ON awardsmanagers.playerid=managers.playerid
							LEFT JOIN award_al
								ON managers.playerid=award_al.playerid  AND managers.yearid=award_al.yearid
									INNER JOIN teams
										ON managers.teamid=teams.teamid AND managers.yearid=teams.yearid
--WHERE awardsmanagers.awardid='TSN Manager of the Year' AND awardsmanagers.lgid!='ML' AND awardsmanagers.lgid IN('AL','NL') AND managers.playerid IN('johnsda02', 'leylaji99')
WHERE (award_al.yearid IS NOT NULL OR award_nl.yearid IS NOT NULL)
GROUP BY full_name,team_name--,   managers.playerid
ORDER BY full_name

-- Unsuccessful try
-- SELECT 
-- 		   CONCAT(p.namefirst,' ',p.namelast) AS full_name
-- 		 , (SELECT am.awardid AS tsn_winner_managers FROM awardsmanagers WHERE lgid IN ('AL','NL'))
-- 		-- , t.teamid AS team_name
-- 		 --, lgid
-- FROM awardsmanagers AS am
-- FULL JOIN people AS p
-- USING(playerid)
-- FULL JOIN managershalf AS m
-- ON p.playerid = m.playerid
-- FULL JOIN teams AS t
-- ON t.teamid = m.teamid
-- WHERE 
-- 	(SELECT 
-- 			CASE WHEN igid = 'AL' THEN '1'
-- 			CASE WHEN igid = 'NL' THEN '1' ELSE END
-- 			FROM awardsmanagers)

-- AND 


-- SELECT 
-- 		   (SELECT CONCAT(p.namefirst,' ',p.namelast) AS full_name FROM awardsmanagers WHERE lgid IN('AL','NL') GROUP BY full_name
-- 		 , am.awardid AS tsn_winner_managers
-- 		 , t.teamid AS team_name
		
-- FROM awardsmanagers AS am
-- FULL JOIN people AS p
-- USING(playerid)
-- FULL JOIN managershalf AS m
-- ON p.playerid = m.playerid
-- FULL JOIN teams AS t
-- ON t.teamid = m.teamid
-- WHERE am.awardid ILIKE 'TSN% 



--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.



SELECT 
      	, people.namefirst
		, people.namelast
		, b.hr AS hr_high
FROM batting AS b
JOIN people
ON  b.playerid = people.playerid
AND (SELECT COUNT (DISTINCT yearid)
    FROM batting
                WHERE playerid = people.playerid) >= 10
AND b.hr >=1
AND b.hr = (
        SELECT MAX(hr)
        FROM batting
        WHERE playerid = b.playerid
                                AND b.yearid = 2016
                                
    )
GROUP BY people.namefirst,people.namelast,b.hr
ORDER BY hr_high DESC


--10 abid
-- SELECT people.namefirst
-- 	,	people.namelast
-- 	,	b.hr AS hr_high
-- FROM batting AS b
-- 	INNER JOIN people
-- 		ON  b.playerid = people.playerid
-- AND (SELECT COUNT (DISTINCT yearid)
--     FROM batting
-- --players had played in league for 10 years
-- 	WHERE playerid = people.playerid) >= 10
-- --players had atleast 1 home run in 2016
-- AND b.hr >=1
-- --players career hit highest (hr) in 2016
-- AND b.hr = (
--         SELECT MAX(hr)
--         FROM batting
--         WHERE playerid = b.playerid
-- 		AND b.yearid = 2016	
--     )
-- GROUP BY people.namefirst,people.namelast,b.hr
--  ORDER BY hr_high DESC

--10 ebuka

-- WITH player_career_high AS
-- (
--     --Finding each player's career-high home runs
--     SELECT playerID, MAX(HR) AS MaxHR
--     FROM Batting
--     GROUP BY playerID
-- ),
-- players_hit AS
-- (
--     -- home runs for players in 2016 who hit their career high
--     SELECT b.playerID, b.HR AS hr_2016
--     FROM Batting b
--     JOIN player_career_high pch ON b.playerID = pch.playerID
-- 	AND b.HR = pch.MaxHR
--     WHERE b.yearID = 2016 AND b.HR > 0
-- ),
-- decade_players AS
-- (
--     -- players who have played at least 10 years
--     SELECT playerID
--     FROM Batting
--     GROUP BY playerID
--     HAVING COUNT(DISTINCT yearID) >= 10
-- )
-- SELECT concat(people.namefirst, ' ', people.namelast) AS full_name, p.playerID, p.hr_2016 AS home_runs_2016
-- FROM players_hit p
-- JOIN decade_players d ON p.playerID = d.playerID
-- JOIN people ON p.playerID = people.playerID
-- ORDER BY p.hr_2016 DESC;

-- SELECT *  FROM awardsmanagers
-- (SELECT distinct awardid FROM awardsmanagers WHERE awardid ILIKE 'TSN%') AS tsn_winner_managers

-- SELECT * FROM parks
-- select * from homegames
-- select * from teams

-- SELECT 
-- 		*
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016

-- select 


-- SELECT *
-- FROM teams

-- select yearid, so
-- from pitching


-- select so, soa, yearid
-- from teams

-- select so, yearid
-- from battingpost

-- select *
-- from homegames


-- SELECT max(yearid)
-- FROM appearances

-- select yearid
-- from fieldingofsplit

-- select cs, sb, yearid
-- from teams
-- where yearid = 2016

-- SELECT 
-- 	CONCAT(MIN(yearid), '-', MAX(yearid)) AS year_range
-- FROM managers;

-- --
-- SELECT
-- 		MIN(people.height/12) as min_height
-- 	,	people.namegiven
-- 	,	SUM(appearances.g_all) as total_games
-- 	,	teams.franchid
-- FROM people
-- 	INNER JOIN appearances
-- 		USING(playerid)
-- 	INNER JOIN teams
-- 		USING(teamid)
-- GROUP BY people.playerid, name, teams.franchid
-- ORDER BY min_height


-- SELECT * FROM parks







-- 9:21
-- LIMIT 1;
