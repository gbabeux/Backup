USE [H18_Proj_Eq07]

CREATE SCHEMA Agents

CREATE TABLE Agents.Agent(
	Agent_ID AS INT IDENTITY(1,1),
	Nom AS VARCHAR(30) NOT NULL,
	Prenom AS VARCHAR(30) NOT NULL,
	Telephone AS 
)