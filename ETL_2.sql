Staging Part Two 
--ETL of the second set of data from the file, "ETL2.csv"
--uses the same database and staging tables as the first ETL

USE epl_stage;

--creation of denormalised table to transfer all data into 
CREATE TABLE denormTable(
	M_date DATE NOT NULL,
	Player_ID INT NOT NULL,
	Player_surname TEXT NOT NULL,
	Player_firstname TEXT,
	Team_name TEXT NOT NULL,
	Team_ID INT NOT NULL,
	Opposition TEXT NOT NULL,
	Opposition_ID INT NOT NULL,
	Mins_Played INT NOT NULL,
	Goals INT NOT NULL,
	ShotsOnTarget INT NOT NULL,
	ShotsOffTarget INT NOT NULL,
	PenaltyGoals INT NOT NULL,
	TotalSuccessfulPasses INT NOT NULL,
	TotalUnsuccessfulPasses INT NOT NULL,
	sourceDB INT NOT NULL
);

--using LOAD to insert csv data into the denormalised table
LOAD DATA LOCAL INFILE 'C:/Users/dgmcl/Downloads/ETL2.csv' --change the location of the file to whereever you have this saved
INTO TABLE denormTable
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(M_date, Player_ID, Player_surname, Player_firstname, Team_name, Team_ID, Opposition, Opposition_ID, Mins_Played, Goals, ShotsOnTarget, ShotsOffTarget, PenaltyGoals, TotalSuccessfulPasses, TotalUnsuccessfulPasses, sourceDB);

--selecting the new entrants that do not exist in the data warehouse already 	
--inserting into the player_stage first 
INSERT INTO player_stage(sourceDB, player_id, player_name, player_surname)
SELECT DISTINCT 2,Player_ID, Player_firstname, Player_surname
FROM denormtable
WHERE Player_ID NOT IN (SELECT Player_ID FROM player_stage);

--inserting the new players only into the data warehouse 
INSERT INTO dw_epl.DimPlayer(player_sk, player_name, player_surname)
SELECT player_sk, player_name, player_surname
FROM player_stage
WHERE player_sk NOT IN (SELECT player_sk FROM dw_epl.DimPlayer);

--inserting all of the new records into the fact_stage table 
INSERT INTO fact_stage(sourceDB, TeamA_ID, TeamB_ID, player_ID, M_date, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko)
SELECT 2, Team_ID, Opposition_ID, Player_ID, M_date, Mins_Played, Goals, ShotsOnTarget, ShotsOffTarget, PenaltyGoals, TotalSuccessfulPasses, TotalUnsuccessfulPasses
FROM denormTable;

--using the same code to match the correct surrogate keys 
UPDATE fact_stage
SET date_sk=
  (select time_stage.date_sk FROM
  time_stage  WHERE (time_stage.M_date = fact_stage.M_date));	
	
UPDATE fact_stage
SET player_sk=
  (select player_stage.player_sk FROM
  player_stage  WHERE (player_stage.player_ID = fact_stage.player_ID));

  
UPDATE fact_stage
SET team_sk=
	(select team_stage.team_sk FROM
	team_stage WHERE (team_stage.Team_ID=fact_stage.TeamA_ID)
	);
  
UPDATE fact_stage
SET opponent_sk=
	(select opponent_stage.opponent_sk FROM
	opponent_stage WHERE (opponent_stage.Team_ID=fact_stage.TeamB_ID)
	);
	
UPDATE fact_stage
SET stadium_sk=
	(select stadium_stage.stadium_sk FROM
	stadium_stage WHERE (stadium_stage.Team_ID=fact_stage.TeamA_ID)
	);

--inserting only the new records into the data warehouse fact table by selecting source database as 2
INSERT INTO dw_epl.Fact_Stats(date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko)
SELECT date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko
FROM fact_stage
WHERE sourceDB=2;
