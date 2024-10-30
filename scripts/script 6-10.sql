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

select teamid, sum(w) as largest_number
from teams
where (yearid between 1970 and 2016) and teamid not in  (select distinct teamid from teams
where wswin = 'Y') 
group by teamid
order by largest_number desc





--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance. 

--run querry bu just picking homegames table
SELECT park AS park_name
	,	 team AS team_name
	,	 attendance/games AS avg_attendance
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5

--run querry by just joining homegames,teams,and parks table
SELECT name 
	,	 park_name
	,     homegames.attendance / games AS avg_attendance
FROM homegames
	INNER JOIN parks
		USING(park)
	INNER JOIN teams
		ON homegames.year=teams.yearid
		AND homegames.team=teams.teamid 
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;




select * from teams where 


--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.



--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.





