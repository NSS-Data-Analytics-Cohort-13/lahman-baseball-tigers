--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

select sb,cs, b.playerid, round(cast(sb as numeric)/(sb+cs) * 100,2) || '%' as success_rate,
		p.namefirst, p.namelast
from batting AS b 
	INNER JOIN people AS p 
	USING (playerid)
where yearid = '2016'  
		and (sb + cs) >= 20
order by success_rate desc



SELECT 	CONCAT(p.namefirst,' ',p.namelast) AS full_name
		, ROUND(sb::NUMERIC/(cs::NUMERIC+sb::NUMERIC)*100, 2) AS success_rate
	    , yearid
from batting
INNER JOIN people AS p
USING(playerid)
WHERE yearid = 2016 AND (cs+sb >= 20)
ORDER BY success_rate DESC



--select sb,cs from batting where yearid = '2016'

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
--the who did not win the world series
select teamid, sum(w) as largest_number
from teams
where (yearid between 1970 and 2016) and teamid not in  (select distinct teamid from teams
where wswin = 'Y') 
group by teamid
order by largest_number desc

--the who did win the world series
select teamid, sum(w) as largest_number
from teams
where (yearid between 1970 and 2016) and teamid in  (select distinct teamid from teams
where wswin = 'Y' and yearid <> 2002) --redo yearid <> 2002
group by teamid
order by largest_number


--world series plus season winner







--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance. 

