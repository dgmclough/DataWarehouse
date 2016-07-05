Dimensional Model
--implementation of the dimensional model/ data warehouse schema

CREATE DATABASE dw_epl;

USE dw_epl;

--creating the tables according to the schema 
CREATE TABLE DimTime(
	date_sk INT PRIMARY KEY,
	year INT,
	month INT,
	day INT
);


CREATE TABLE DimTeam(
	team_sk INT PRIMARY KEY,
	team_name TEXT,
	year_of_foundation INT
);

CREATE TABLE DimOpponent(
	opponent_sk INT PRIMARY KEY,
	team_name TEXT,
	year_of_foundation INT
);

CREATE TABLE DimPlayer(
	player_sk INT PRIMARY KEY,
	player_name TEXT,
	player_surname TEXT,
	player_age INT
);

CREATE TABLE DimStadium(
	stadium_sk INT PRIMARY KEY,
	stadium_name TEXT,
	stadium_city TEXT,
	capacity INT
);

--implementation of the fact table with all foreign key constraints 
CREATE TABLE Fact_Stats(
	date_sk INT,
	player_sk INT,
	team_sk INT,
	opponent_sk INT,
	stadium_sk INT,
	min_played INT,
	goals INT,
	shot_on INT,
	shot_off INT,
	penalty INT,
	pass_ok INT,
	pass_ko INT,
	CONSTRAINT FK_dimdate FOREIGN KEY (date_sk) REFERENCES DimTime (date_sk),
	CONSTRAINT FK_dimplayer FOREIGN KEY (player_sk) REFERENCES DimPlayer (player_sk),
	CONSTRAINT FK_dimteam FOREIGN KEY (team_sk) REFERENCES DimTeam (team_sk),
	CONSTRAINT FK_dimopponent FOREIGN KEY (opponent_sk) REFERENCES DimOpponent (opponent_sk),
	CONSTRAINT FK_dimstadium FOREIGN KEY (stadium_sk) REFERENCES DimStadium (stadium_sk),
	CONSTRAINT PK_factstats PRIMARY KEY (date_sk, player_sk, team_sk, opponent_sk, stadium_sk)
);