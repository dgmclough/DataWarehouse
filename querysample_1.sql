--First Query
--Player query that extracts certain performance statistics for every player present
--in the database and ranks them by highest number of goals scored
-- most significant column i believe is where the players average time to score a goal
--when on the pitch, broken down to minutes 
-- concat is used to concatenate results for appearance
-- round is used to reduce decimal place and make it more presentable 

SELECT 
CONCAT(dimplayer.player_surname, ", ", dimplayer.player_name)AS Player,
dimteam.team_name AS Team,
SUM(fact_stats.min_played) AS Total_Time,
ROUND(AVG(fact_stats.min_played)) AS Avg_Time_Per_Match,
SUM(fact_stats.goals) AS Total_Goals,
CONCAT(IF(ROUND(SUM(fact_stats.min_played)/SUM(fact_stats.goals)) IS NULL, SUM(fact_stats.min_played), ROUND(SUM(fact_stats.min_played)/SUM(fact_stats.goals))), "  mins") AS Scores_On_Avg_Every,
CONCAT(ROUND((((SUM(fact_stats.shot_on))/(COALESCE(SUM(fact_stats.shot_off),0) + COALESCE(SUM(fact_stats.shot_on),0)))*100)), "%") AS Shots_On_Target,
CONCAT(ROUND((((SUM(fact_stats.pass_ok))/(COALESCE(SUM(fact_stats.pass_ok),0) + COALESCE(SUM(fact_stats.pass_ko),0)))*100)),"%") AS Pass_Success,
COUNT(fact_stats.player_sk) AS Appearances

FROM fact_stats 

INNER JOIN dimteam ON dimteam.team_sk = fact_stats.team_sk  
INNER JOIN dimplayer ON dimplayer.player_sk = fact_stats.player_sk
INNER JOIN dimtime ON dimtime.date_sk = fact_stats.date_sk
INNER JOIN dimopponent ON dimopponent.opponent_sk = fact_stats.opponent_sk

--players must have played at least 1 minute in the games selected 
WHERE fact_stats.min_played > 0 

GROUP BY dimplayer.player_sk
ORDER BY Total_Goals DESC;








