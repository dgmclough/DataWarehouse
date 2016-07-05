--creating the relational database tables, running the scripts to populate tables.
--importing and parsing data from a csv file to populate and order all other tables

CREATE DATABASE epl;

USE epl;

--creating the tables according to the database schema 
CREATE TABLE Teams(
	Team_ID INT NOT NULL,
	Team_name TEXT NOT NULL,
	YearOfFound INT NOT NULL,
	PRIMARY KEY (Team_ID)
);
	
CREATE TABLE Players(
	Player_ID INT NOT NULL,
	Pl_name TEXT,
	Pl_surname TEXT NOT NULL,
	TeamID INT NOT NULL,
	PRIMARY KEY (Player_ID),
	CONSTRAINT fk_TeamPlayer FOREIGN KEY (TeamID) REFERENCES Teams(Team_ID)
);
	
CREATE TABLE Stadiums(
	Stadium_ID INT NOT NULL,
	St_name TEXT NOT NULL,
	City TEXT NOT NULL,
	Capacity INT NOT NULL,
	TeamID INT NOT NULL,
	PRIMARY KEY (Stadium_ID),
	CONSTRAINT fk_TeamStadium FOREIGN KEY (TeamID) REFERENCES Teams(Team_ID)
);
--Creating the relational database for holding the Premiership Data	
CREATE TABLE Matches(
	TeamA_ID INT NOT NULL,
	TeamB_ID INT NOT NULL,
	M_date DATE NOT NULL,
	CONSTRAINT pk_Matches PRIMARY KEY (TeamA_ID, TeamB_ID, M_date)
);
	
CREATE TABLE Player_stats(
	TeamA_ID INT NOT NULL,
	TeamB_ID INT NOT NULL,
	M_date DATE NOT NULL,
	Player_ID INT NOT NULL,
	MinPlayed INT NOT NULL,
	Goals INT NOT NULL,
	Shot_on INT NOT NULL,
	Shot_off INT NOT NULL,
	Penalty INT NOT NULL,
	Pass_OK INT NOT NULL,
	Pass_KO INT NOT NULL,
	CONSTRAINT pk_Stats PRIMARY KEY (TeamA_ID, TeamB_ID, M_date, Player_ID),
	CONSTRAINT fk_MatchStat FOREIGN KEY (TeamA_ID, TeamB_ID, M_date) REFERENCES Matches(TeamA_ID, TeamB_ID, M_date),
	CONSTRAINT fk_PlayerStat FOREIGN KEY (Player_ID) REFERENCES Players(Player_ID)
);

--imlpementing the script provided to populate the stadiums and teams tables 	
SOURCE \Users\dgmcl\Downloads\Insert.sql

--creating a denormalised table to insert the data from the csv file 
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
	TotalUnsuccessfulPasses INT NOT NULL
);


--imlpementing the script provided to populate the stadiums and teams tables 	
SOURCE \Users\dgmcl\Downloads\Insert.sql -- change the source to wherever you have this script saved

--creating a denormalised table to insert the data from the csv file 
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
	TotalUnsuccessfulPasses INT NOT NULL
);

--loading the csv data from "premier.csv" into the denormalised table 
LOAD DATA LOCAL INFILE 'C:/Users/dgmcl/Downloads/Premier.csv' --change the location of the file to whereever you have this saved
INTO TABLE denormTable
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(M_date, Player_ID, Player_surname, Player_firstname, Team_name, Team_ID, Opposition, Opposition_ID, Mins_Played, Goals, ShotsOnTarget, ShotsOffTarget, PenaltyGoals, TotalSuccessfulPasses, TotalUnsuccessfulPasses);

--removing the null values found at the end of the file 	
DELETE FROM denormTable WHERE Team_ID NOT IN(SELECT Team_ID FROM Teams);

--inserting distinct certain fields into the players table 
INSERT INTO Players (Player_ID, Pl_name, Pl_surname, TeamID)
SELECT DISTINCT Player_ID, Player_firstname, Player_surname, Team_ID
FROM denormTable;

--inserting distinct certain fields into the matches table 	
INSERT INTO Matches (TeamA_ID, TeamB_ID, M_date)
SELECT DISTINCT Team_ID, Opposition_ID, M_date
FROM denormTABLE;

--inserting relevant fields into the player_stats table 	
INSERT INTO Player_stats (TeamA_ID, TeamB_ID, M_date, Player_ID, MinPlayed, Goals, Shot_on, Shot_off, Penalty, Pass_OK, Pass_KO)
SELECT Team_ID, Opposition_ID, M_date, Player_ID, Mins_Played, Goals, ShotsOnTarget, ShotsOffTarget, PenaltyGoals, TotalSuccessfulPasses, TotalUnsuccessfulPasses
FROM denormTABLE;