Staging Tables
-- a script for the first ETL process that automates the creation of stage tables, import and
--cleaning of data and transfer to the data warehouse 

CREATE DATABASE epl_stage;

USE epl_stage;

--implementation of the stage tables using auto increment function for surrogate key 
--same applies for all the following stage tables 
CREATE TABLE team_stage(
	team_sk INT PRIMARY KEY AUTO_INCREMENT,
	sourceDB INT,
	Team_ID INT,
	team_name TEXT, 
	year_of_foundation INT
);

--insertion of data from the relational database 
--same applies for the following stage tables 
INSERT INTO team_stage(sourceDB, Team_ID, team_name, year_of_foundation)
	SELECT 1,Team_ID, Team_name, YearOfFound
	FROM epl.Teams;

--transfer of the cleaned data into the data warehouse 
--same applies for following stage tables 
INSERT INTO dw_epl.DimTeam(team_sk, team_name, year_of_foundation)
	SELECT team_sk, team_name, year_of_foundation
	FROM team_stage;


CREATE TABLE opponent_stage(
	opponent_sk INT PRIMARY KEY AUTO_INCREMENT,
	sourceDB INT,
	Team_ID INT,
	team_name TEXT, 
	year_of_foundation INT
);

INSERT INTO opponent_stage(sourceDB, Team_ID, team_name, year_of_foundation)
	SELECT 1,Team_ID, Team_name, YearOfFound
	FROM epl.Teams;
	
INSERT INTO dw_epl.DimOpponent(opponent_sk, team_name, year_of_foundation)
	SELECT opponent_sk, team_name, year_of_foundation
	FROM opponent_stage;
	

CREATE TABLE player_stage(
	player_sk INT PRIMARY KEY AUTO_INCREMENT,
	sourceDB INT,
	player_ID INT,
	player_name TEXT, 
	player_surname TEXT,
	player_age INT
);

INSERT INTO player_stage(sourceDB, player_ID, player_name, player_surname)
	SELECT 1, Player_ID, Pl_name, Pl_surname
	FROM epl.Players;
	
INSERT INTO dw_epl.DimPlayer(player_sk, player_name, player_surname)
	SELECT player_sk, player_name, player_surname
	FROM player_stage;


CREATE TABLE time_stage(
	date_sk INT PRIMARY KEY AUTO_INCREMENT,
	year INT,
	month INT,
	day INT,
	M_date Date
);

--use of the extract function to parse the date of matches into separate fields
INSERT INTO time_stage(year, month, day, M_date)
	SELECT EXTRACT(YEAR FROM M_date) AS year,
	EXTRACT(MONTH FROM M_date) AS month,
	EXTRACT(DAY FROM M_date) AS day,
	M_date
	FROM(
		SELECT DISTINCT M_date from epl.Matches
	)AS matchtime;
	
INSERT INTO dw_epl.DimTime(date_sk, year, month, day)
	SELECT date_sk, year, month, day
	FROM time_stage;


CREATE TABLE stadium_stage(
	stadium_sk INT PRIMARY KEY AUTO_INCREMENT,
	sourceDB INT,
	stadiumID INT,
	stadium_name TEXT, 
	stadium_city TEXT,
	capacity INT,
	Team_ID INT
);

INSERT INTO stadium_stage(sourceDB,stadiumID, stadium_name, stadium_city, capacity, Team_ID)
	SELECT 1,Stadium_ID, St_name, City, Capacity, TeamID
	FROM epl.Stadiums;
	
INSERT INTO dw_epl.DimStadium(stadium_sk, stadium_name, stadium_city, capacity)
	SELECT stadium_sk, stadium_name, stadium_city, capacity
	FROM stadium_stage;
	
--implementation of the fact_stage 	
CREATE TABLE fact_stage(
	date_sk INT,
	player_sk INT,
	team_sk INT,
	opponent_sk INT,
	stadium_sk INT,
	sourceDB INT,
	TeamA_ID INT,
	TeamB_ID INT,
	player_ID INT,
	M_date Date,
	min_played INT,
	goals INT,
	shot_on INT,
	shot_off INT,
	penalty INT,
	pass_ok INT,
	pass_ko INT
);

INSERT INTO fact_stage(sourceDB, TeamA_ID, TeamB_ID, player_ID, M_date, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko)
	SELECT 1, TeamA_ID, TeamB_ID, Player_ID, M_date, MinPlayed, Goals, Shot_on, Shot_off, Penalty, Pass_OK, Pass_KO
	FROM epl.player_stats;
	
--updating the surrogate keys for the date 
--matching through the time_stage by the date 
UPDATE fact_stage
SET date_sk=
  (select time_stage.date_sk FROM
  time_stage  WHERE (time_stage.M_date = fact_stage.M_date));	

--updating surrogate key for the player
--matching through the player_stage by player_id  
UPDATE fact_stage
SET player_sk=
  (select player_stage.player_sk FROM
  player_stage  WHERE (player_stage.sourceDB=fact_stage.sourceDB AND
  player_stage.player_ID = fact_stage.player_ID));

--updating surrogate key for the team
--matching through the team_stage by team_id 
UPDATE fact_stage
SET team_sk=
	(select team_stage.team_sk FROM
	team_stage WHERE (team_stage.sourceDB=fact_stage.sourceDB AND
	team_stage.Team_ID=fact_stage.TeamA_ID)
	);
  
--updating surrogate key for the opponent
--matching through the opponent_stage by opponent_id 
UPDATE fact_stage
SET opponent_sk=
	(select opponent_stage.opponent_sk FROM
	opponent_stage WHERE (opponent_stage.sourceDB=fact_stage.sourceDB AND
	opponent_stage.Team_ID=fact_stage.TeamB_ID)
	);

--updating surrogate key for the stadium
--matching through the stadium_stage by stadium_id 	
UPDATE fact_stage
SET stadium_sk=
	(select stadium_stage.stadium_sk FROM
	stadium_stage WHERE (stadium_stage.Team_ID=fact_stage.TeamA_ID)
	);

--inserting the updated data with surrogate keys from the fact_stage into the
--data warehouse fact table 
INSERT INTO dw_epl.Fact_Stats(date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko)
	SELECT date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko
	FROM fact_stage;