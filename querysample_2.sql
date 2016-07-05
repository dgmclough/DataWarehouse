--Second Query selects statistics for teams
-- and ranks them according to highest number of goals scored 

SELECT dimteam.team_name AS Team_Name,
SUM(fact_stats.goals) AS Total_Goals,
CONCAT(ROUND((((SUM(fact_stats.shot_on))/(COALESCE(SUM(fact_stats.shot_off),0) + COALESCE(SUM(fact_stats.shot_on),0)))*100)), "%") AS Shots_On_Target,
COALESCE(SUM(fact_stats.shot_off),0) + COALESCE(SUM(fact_stats.shot_on),0) AS Total_Shots,
CONCAT(ROUND((((SUM(fact_stats.goals))/(SUM(fact_stats.shot_on)))*100)), "%") AS Goals_From_On_Target,
CONCAT(ROUND((((SUM(fact_stats.goals))/(COALESCE(SUM(fact_stats.shot_off),0) + COALESCE(SUM(fact_stats.shot_on),0)))*100)), "%") AS Goals_From_All_Shots,
CONCAT(ROUND((((SUM(fact_stats.pass_ok))/(COALESCE(SUM(fact_stats.pass_ok),0) + COALESCE(SUM(fact_stats.pass_ko),0)))*100)),"%") AS Pass_Success

FROM fact_stats 

INNER JOIN dimteam ON dimteam.team_sk = fact_stats.team_sk 
INNER JOIN dimopponent ON dimopponent.opponent_sk = fact_stats.opponent_sk
INNER JOIN dimplayer ON dimplayer.player_sk = fact_stats.player_sk
INNER JOIN dimtime ON dimtime.date_sk = fact_stats.date_sk

GROUP BY dimteam.team_name
ORDER BY Total_Goals DESC;