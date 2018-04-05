--
--  Coulombe Alexis
--

USE master;

-- Drop database
IF DB_ID('MadMax') IS NOT NULL DROP DATABASE MadMax;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Création des database   
CREATE DATABASE MadMax
	ON PRIMARY(
		NAME='MadMax',
		FILENAME='H:\MadMax.mdf',
		SIZE=10MB,
		MAXSIZE=20,
		FILEGROWTH=10%
	) LOG ON(
		NAME='MadMax_log',
		FILENAME='H:\MadMax.ldf',
		SIZE=10MB,
		MAXSIZE=200,
		FILEGROWTH=20%
	);
GO

-- Use database
USE MadMax;
GO

---------------------------------TP             ------------  Remise 1 -----------------------------------------------------------


---------------------------------------------------------------------
--  Création des Schemas 
---------------------------------------------------------------------
GO
CREATE SCHEMA Membres;
GO
CREATE SCHEMA Inventaires;
GO
CREATE SCHEMA Villes;
GO
CREATE SCHEMA Reservoirs;
GO
CREATE SCHEMA Batailles;

---------------------------------------------------------------------
-- Création des Tables  avec les contraintes NULL, NOT NULL, IDENTITY 
--       et avec la contrainte nommée PRIMARY KEY à la fin de la table
---------------------------------------------------------------------
GO
CREATE TABLE Membres.membre
(
	MembreID int NOT NULL IDENTITY(1,1),
	Prenom nvarchar(50) NOT NULL,
	Nom nvarchar(50) NOT NULL,
	Age int NOT NULL,
	Adresse nvarchar(50) NULL
	CONSTRAINT PK_Membre_MembreID PRIMARY KEY (MembreID)
) ON [PRIMARY];
GO

CREATE TABLE Inventaires.objet
(
	ObjetID int NOT NULL IDENTITY(1,1),
	Nom nvarchar(50) NOT NULL,
	Valeur int DEFAULT 0,
	Rarete nvarchar(50) NOT NULL,
	CONSTRAINT PK_Objet_ObjetID PRIMARY KEY (ObjetID)
) ON [PRIMARY];
GO

CREATE TABLE Inventaires.inventaire
(
	InventaireID int NOT NULL IDENTITY(1,1),
	MembreID int NOT NULL,
	ObjetID int NOT NULL,
	CONSTRAINT PK_Inventaire_InventaireID PRIMARY KEY (InventaireID),
) ON [PRIMARY];
GO

CREATE TABLE Reservoirs.Reservoir
(
	ReservoirsID int NOT NULL IDENTITY(1,1),
	Quantite int NOT NULL,
	QuantiteDate datetime2 NOT NULL,
	CONSTRAINT PK_Reservoirs_ReservoirsID PRIMARY KEY (ReservoirsID),
) ON [PRIMARY];
GO

CREATE TABLE Reservoirs.achat
(
	AchatID int NOT NULL IDENTITY(1,1),
	MembreID int NOT NULL,
	ReservoirsID int NOT NULL,
	Quantite int NOT NULL,
	DateAchat datetime2 NOT NULL
	CONSTRAINT PK_Achat_AchatID PRIMARY KEY (AchatID),
) ON [PRIMARY];
GO

CREATE TABLE Villes.ville
(
	VilleID int NOT NULL IDENTITY(1,1),
	Nom nvarchar(50) NOT NULL
	CONSTRAINT PK_Ville_VilleID PRIMARY KEY (VilleID)
) ON [PRIMARY];
GO

CREATE TABLE Batailles.Bataille
(
	BataillesID int NOT NULL IDENTITY(1,1),
	VilleID int NOT NULL,
	DateBatailles datetime2 NOT NULL,
	DateFin datetime2 NULL,
	NombreMort int NULL,
	CONSTRAINT PK_Batailles_BataillesID PRIMARY KEY (BataillesID),
) ON [PRIMARY];
GO

---------------------------------------------------------------------
-- Création des autres contraintes ALTER TABLE...ADD CONSTRAINT 
--             pour les contraintes de clés étrangères, 
--             pour les contraintes DEFAULT, UNIQUE et CHECK
---------------------------------------------------------------------
ALTER TABLE Inventaires.objet
	ADD CONSTRAINT CHK_Objet_Valeur CHECK (Valeur >= 0)

ALTER TABLE Inventaires.inventaire
	ADD CONSTRAINT FK_Inventaire_Membre_MembreID
		FOREIGN KEY (MembreID)
		REFERENCES Membres.membre(MembreID)
		ON DELETE CASCADE,
	CONSTRAINT FK_Inventaire_Objet_ObjetID
		FOREIGN KEY (ObjetID)
		REFERENCES Inventaires.objet(ObjetID)
		ON DELETE CASCADE

ALTER TABLE Reservoirs.achat
	ADD CONSTRAINT FK_Achat_Membre_MembreID
		FOREIGN KEY (MembreID)
		REFERENCES Membres.membre(MembreID)
		ON DELETE CASCADE,
	CONSTRAINT FK_Reservoirs_ReservoirsID
		FOREIGN KEY (ReservoirsID)
		REFERENCES Reservoirs.Reservoir(ReservoirsID)
		ON DELETE CASCADE,
	CONSTRAINT CHK_Reservoirs_DateAchat CHECK (DateAchat <= CURRENT_TIMESTAMP),
	CONSTRAINT CHK_Reservoirs_QuantiteAchat CHECK (Quantite >= 0)

ALTER TABLE Reservoirs.Reservoir
	ADD CONSTRAINT CHK_Reservoirs_Quantite CHECK (Quantite >= 0),
	CONSTRAINT CHK_Reservoirse_QuantiteDate CHECK (QuantiteDate <= CURRENT_TIMESTAMP)

ALTER TABLE Batailles.Bataille
	ADD CONSTRAINT FK_Batailles_Ville_VilleID
		FOREIGN KEY (VilleID)
		REFERENCES Villes.ville(VilleID)
		ON DELETE CASCADE,
	CONSTRAINT CHK_Batailles_DateBatailles CHECK (DateBatailles <= CURRENT_TIMESTAMP),
	CONSTRAINT CHK_Batailles_NombreMort CHECK (NombreMort >= 0)

---------------------------------------------------------------------
-- Liste des récits utilisateurs  (numérotés  US1, US2....)
---------------------------------------------------------------------
-- US1: Identifier si la quantité d’eau d’aujourd’hui est plus haute que la quantité d'eau de hier.
-- US2: Faire la moyenne de la quantité d’eau dans le réservoir par mois.
-- US3: Quelle personne a le plus d’objets dans l’inventaire avec une valeur plus haute que 20 ?
-- US4: Quel est la moyenne d’âge des personnes qui ont une adresse et qui ont quelque chose dans l'inventaire, aussi, si la moyenne à plus de 18 ans.
-- US5: Combien de temps dure une Batailles contre qui à telle eu lieu ?
-- US6: Quelles sont les 3 personnes à avoir acheté le plus souvent d'eau à la ville? Afficher son Inventaires.

---------------------------------------------------------------------
-- Insertion des données
---------------------------------------------------------------------
INSERT INTO Membres.membre (Prenom, Nom, Age, Adresse) VALUES ('Alexis', 'Coulombe', 20, '123 meumeu'),
('Andrei', 'Colombus', 5, '1625 des poules'),
('Joe', 'La patate', 20, '365 du pomier'),
('Jertrude', 'La patate', 28, '365 du pomier'),
('Bob', 'Captial', 45, NULL),
('Roger', 'Remax', 67, '365 du pomier'),
('Linda', 'Platine', 18, NULL),
('Monique', 'La poutine', 100, NULL);

INSERT INTO Inventaires.objet (Nom, Valeur, Rarete) VALUES ('Metal', '1', 'Commun'),
('Roue de camion', '5', 'Commun'),
('Diamand', '40', 'Rare'),
('Clavier d''ordinateur', '4', 'Commun'),
('Volant de voiture', '12', 'Peu commun'),
('Sac à dos', '3', 'Commun'),
('Bouteille de pepsi', '2', 'Peu commun');

INSERT INTO Inventaires.inventaire (MembreID, ObjetID) VALUES (1, 1),
(2, 4),
(3, 7),
(1, 2),
(1, 2),
(3, 3),
(3, 1),
(2, 6),
(1, 6),
(1, 7);

INSERT INTO Villes.ville (Nom) VALUES ('Longueil'),
('Stroemond'),
('Traka'),
('Magos'),
('Dradiff');

INSERT INTO Reservoirs.Reservoir (Quantite, QuantiteDate) VALUES (200, '2017-01-28 00:00:00'),
(190, '2017-01-29 00:00:00'),
(210, '2017-01-30 00:00:00'),
(120, '2017-02-02 00:00:00'),
(150, '2017-02-28 00:00:00'),
(210, '2017-03-06 00:00:00'),
(300, '2017-03-07 00:00:00');

INSERT INTO Batailles.Bataille (VilleID, DateBatailles, DateFin, NombreMort) VALUES (1, '2017-12-25 00:00:00', '2017-12-26 00:00:00', 20),
(2, '2017-06-27 00:00:00', '2017-07-26 00:00:00', 240),
(1, '2017-10-03 00:00:00', '2018-02-03 00:00:00', 101),
(3, '2017-12-15 00:00:00', '2018-01-01 00:00:00', 97),
(1, '2017-01-09 00:00:00', '2017-03-17 00:00:00', 36),
(2, '2017-09-07 00:00:00', '2017-10-12 00:00:00', 572),
(1, '2018-01-14 00:00:00', NULL, 346),
(4, '2018-01-13 00:00:00', NULL, 20);

INSERT INTO Reservoirs.achat (MembreID, ReservoirsID, Quantite, DateAchat) VALUES (1, 1, 10, '2018-01-29 23:45:00'),
(2, 1, 20, '2018-01-29 13:05:55'),
(1, 2, 10, '2017-12-02 11:05:00'),
(4, 2, 10, '2016-10-10 17:10:00'),
(5, 2, 10, '2015-06-18 19:05:00'),
(5, 2, 10, '2016-05-03 22:45:00'),
(3, 4, 10, '2010-10-10 18:18:49');


---------------------------------------------------------------------
-- Tentative de faire les requêtes pour satisfaire les récits utilisateurs
---------------------------------------------------------------------
--U1: Identifier si la quantité d’eau d’aujourd’hui est plus haute que la quantité d'eau de hier.
	GO
	DECLARE @QuantiteHier FLOAT, @QuantiteToday FLOAT
	
	WITH QuantiteToday AS (
		SELECT QuantiteDate, Quantite FROM [Reservoirs].[Reservoir]
		WHERE DAY(QuantiteDate) = DAY(GETDATE())
	), QuantiteHier AS (
		SELECT QuantiteDate, Quantite FROM [Reservoirs].[Reservoir]
		WHERE DAY(QuantiteDate) = DAY(GETDATE() - 1)
	)

	SELECT @QuantiteToday = tod.Quantite, @QuantiteHier = hie.Quantite FROM QuantiteToday tod
	INNER JOIN QuantiteHier hie
	ON 1 = 1

	IF @QuantiteToday > @QuantiteHier
		SELECT 'La quantité d''hier est plus grand qu''aujourd''hui' as 'Quantité d''eau'
	ELSE IF @QuantiteToday = @QuantiteHier
		SELECT 'La quantité d''hier est au même niveau qu''aujourd''hui' as 'Quantité d''eau'
	ELSE IF @QuantiteToday < @QuantiteHier
		SELECT 'La quantité d''hier est moin grande qu''aujourd''hui' as 'Quantité d''eau'
	ELSE 
		SELECT 'Il n''y a pas d''historique pour la quantité d''eau pour aujourd''hui' as 'Quantité d''eau'
	GO
--U2: Faire la moyenne de la quantité d’eau dans le réservoir par mois.
	GO
	SELECT AVG(Quantite) as 'Quantité moyenne', MONTH(QuantiteDate) as Mois FROM Reservoirs.Reservoir
	GROUP BY MONTH(QuantiteDate)
	GO
--U3: Quelle personne a le plus d’objets dans l’inventaire avec une valeur plus haute que 20 ?
	GO
	SELECT TOP 1 mem.Nom, COUNT(obj.Nom) as 'Nombre d''objets', SUM(obj.Valeur) as 'Valeur totale' FROM [Inventaires].[inventaire] inv
	INNER JOIN [Membres].[membre] mem
	ON mem.MembreID = inv.MembreID
	INNER JOIN [Inventaires].[objet] obj
	ON obj.ObjetID = inv.ObjetID
	GROUP BY mem.Nom
	HAVING SUM(obj.Valeur) > 20
	ORDER BY COUNT(obj.Nom) DESC
	GO
--U4: Quel est la moyenne d’âge des personnes qui ont une adresse et qui ont quelque chose dans l'inventaire, aussi, si la moyenne à plus de 18 ans.
	GO
	SELECT IIF(AVG(mem.Age) >= 18, 'La moyenne est adulte', 'La moyenne est mineur') as 'Moyenne d''age' FROM [Membres].[membre] mem
	INNER JOIN [Inventaires].[inventaire] inv
	ON inv.MembreID = mem.MembreID
	GO
--U5: Combien de temps dure une Batailles contre qui à telle eu lieu ?
	GO
	SELECT ISNULL(CONVERT(VARCHAR(50), DATEDIFF(DAY, bat.DateBatailles, bat.DateFin)) + ' jour(s)', 'Toujours en cours') as 'Jours de Batailless', 
	vil.Nom as 'Adversaire' FROM [Batailles].[Bataille] bat
	INNER JOIN [Villes].[ville] vil
	ON bat.VilleID = vil.VilleID
	GO
--U6: Quelles sont les 3 personnes à avoir acheté le plus souvent d'eau à la ville? Afficher son Inventaires.
	GO
	SELECT TOP 3 mem.Nom, COUNT(ach.MembreID) as 'Fréquences d''achats', obj.Nom, COUNT(obj.Nom) as 'Quantité de cet objet', SUM(obj.Valeur) as 'Valeur totale' FROM [Reservoirs].[achat] ach
	INNER JOIN [Membres].[membre] mem
	ON mem.MembreID = ach.MembreID
	INNER JOIN [Inventaires].[inventaire] inv
	ON inv.MembreID = mem.MembreID
	INNER JOIN [Inventaires].[objet] obj
	ON obj.ObjetID = inv.ObjetID
	GROUP BY ach.MembreID, mem.Nom, obj.Nom
	ORDER BY COUNT(ach.MembreID) DESC
	GO



--------------------------------------------------------------  Remise 2 ---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------
-- index non clustered nécessaires pour optimiser les requêtes
---------------------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_Membre_Nom
ON [Membres].[membre]
(
	Nom
);

CREATE NONCLUSTERED INDEX IX_Inventaire_Objet
ON [Inventaires].[objet]
(
	Nom
);

CREATE NONCLUSTERED INDEX IX_Ville_ville
ON [Villes].[ville]
(
	Nom
);

CREATE NONCLUSTERED INDEX IX_Reservoirs_Reservoirs
ON [Reservoirs].[Reservoir]
(
	Quantite
);

CREATE NONCLUSTERED INDEX IX_Reservoirs_achat
ON [Reservoirs].[achat]
(
	Quantite
);


---------------------------------------------------------------------
--Créez une ou deux vues en expliquant quand vous prévoyiez les utiliser.
---------------------------------------------------------------------

IF OBJECT_ID('Inventaires.vw_InventaireAvance', 'V') IS NOT NULL
	DROP VIEW Inventaires.vw_InventaireAvance;

GO

CREATE VIEW Inventaires.vw_InventaireAvance
AS
	SELECT mem.MembreID, obj.ObjetID, mem.Nom + ', ' + mem.Prenom as NomComplet, obj.Nom, COUNT(obj.Nom) as objetPareil, SUM(obj.Valeur) as valeurTotale FROM [Inventaires].[inventaire] inv
	INNER JOIN [Membres].[membre] mem
	ON mem.MembreID = inv.MembreID
	INNER JOIN [Inventaires].[objet] obj
	ON obj.ObjetID = inv.ObjetID
	GROUP BY mem.Nom, mem.Prenom, obj.Nom, mem.MembreID, obj.ObjetID
GO

SELECT * FROM Inventaires.vw_InventaireAvance

-- Je vais utiliser cette vue très souvent, à chaque fois que je veux voir l'inventaire d'un membre et/ou sa valeur

---------------------------------------------------------------------
--Transformez les requêtes afin que celles-ci deviennent plus générales.
---------------------------------------------------------------------

--U1: Identifier si la quantité d’eau d’aujourd’hui est plus haute que la quantité d'eau de hier.
	IF OBJECT_ID('dbo.udf_comparerQuantite', 'FN') IS NOT NULL
		DROP FUNCTION dbo.udf_comparerQuantite;
	GO

	CREATE FUNCTION dbo.udf_comparerQuantite(@nombreUn AS FLOAT, @nombreDeux AS FLOAT) RETURNS NVARCHAR(100)
	AS
	BEGIN
		IF @nombreUn > @nombreDeux
			RETURN N'La quantité d''hier est plus grand qu''aujourd''hui'
		IF @nombreUn = @nombreDeux
			RETURN N'La quantité d''hier est au même niveau qu''aujourd''hui'
		IF @nombreUn < @nombreDeux
			RETURN N'La quantité d''hier est moin grande qu''aujourd''hui'

		RETURN 'Il ''y a pas d''historique pour le réservoir aujourd''hui'
	END
	GO

	SELECT dbo.udf_comparerQuantite((SELECT Quantite FROM [Reservoirs].[Reservoir] WHERE DAY(QuantiteDate) = DAY(GETDATE())),
								(SELECT Quantite FROM [Reservoirs].[Reservoir]WHERE DAY(QuantiteDate) = DAY(GETDATE() - 1))) as 'Quantité d''eau'

--U2: Faire la moyenne de la quantité d’eau dans le réservoir par mois.
	IF OBJECT_ID('dbo.udf_avoirMoisSelonDate', 'FN') IS NOT NULL
		DROP FUNCTION dbo.udf_avoirMoisSelonDate;
	GO

	CREATE FUNCTION dbo.udf_avoirMoisSelonDate(@date AS DATETIME2) RETURNS INT
	AS
	BEGIN
		RETURN MONTH(@date)
	END
	GO
 
	SELECT AVG(Quantite) as 'Quantité moyenne', dbo.udf_avoirMoisSelonDate(QuantiteDate) as Mois FROM Reservoirs.Reservoir
	GROUP BY dbo.udf_avoirMoisSelonDate(QuantiteDate)

--U3: Quelle personne a le plus d’objets dans l’inventaire avec une valeur plus haute que 20 ?
	SELECT inva.NomComplet, COUNT(obj.Nom) as 'Nombre d''objets', inva.valeurTotale as 'Valeur totale' FROM [Inventaires].[inventaire] inv
	INNER JOIN [Inventaires].[objet] obj
	ON obj.ObjetID = inv.ObjetID
	INNER JOIN Inventaires.vw_InventaireAvance inva
	ON inva.MembreID = inv.MembreID AND obj.ObjetID = inva.ObjetID
	GROUP BY inva.NomComplet, inva.valeurTotale
	HAVING inva.valeurTotale > 20


--U4: Quel est la moyenne d’âge des personnes qui ont une adresse et qui ont quelque chose dans l'inventaire, aussi, si la moyenne à plus de 18 ans.
	IF OBJECT_ID('dbo.udf_savoirSiAdulteSelonAge', 'FN') IS NOT NULL
		DROP FUNCTION dbo.udf_savoirSiAdulteSelonAge;
	GO

	CREATE FUNCTION dbo.udf_savoirSiAdulteSelonAge(@age AS INT) RETURNS VARCHAR(50)
	AS
	BEGIN
		IF @age >= 18
			RETURN 'La moyenne est adulte!'
		ELSE
			RETURN 'La moyenne est mineur!'
		
		RETURN 'Un return impossible!'
	END
	GO

	SELECT dbo.udf_savoirSiAdulteSelonAge(AVG(mem.Age)) as 'Moyenne d''age' FROM [Membres].[membre] mem
	INNER JOIN [Inventaires].[inventaire] inv
	ON inv.MembreID = mem.MembreID

--U5: Combien de temps dure une Batailles contre qui à telle eu lieu ?
	IF OBJECT_ID('dbo.udf_siValeurNull', 'FN') IS NOT NULL
		DROP FUNCTION dbo.udf_siValeurNull;
	GO

	CREATE FUNCTION dbo.udf_siValeurNull(@differenceDeDate AS VARCHAR(50)) RETURNS VARCHAR(50)
	AS
	BEGIN
		RETURN ISNULL(@differenceDeDate, 'Toujours en cours')
	END
	GO

	SELECT dbo.udf_siValeurNull(CONVERT(VARCHAR(50), DATEDIFF(DAY, bat.DateBatailles, bat.DateFin)) + ' jour(s)') as 'Jours de Batailless', 
	vil.Nom as 'Adversaire' FROM [Batailles].[Bataille] bat
	INNER JOIN [Villes].[ville] vil
	ON bat.VilleID = vil.VilleID

--U6: Quelles sont les 3 personnes à avoir acheté le plus souvent d'eau à la ville? Afficher son Inventaires.
	SELECT TOP 3 mem.Nom, COUNT(ach.MembreID) as 'Fréquences d''achats', obj.Nom, COUNT(obj.Nom) as 'Quantité de cet objet', SUM(obj.Valeur) as 'Valeur totale' FROM [Reservoirs].[achat] ach
	INNER JOIN [Membres].[membre] mem
	ON mem.MembreID = ach.MembreID
	INNER JOIN [Inventaires].[inventaire] inv
	ON inv.MembreID = mem.MembreID
	INNER JOIN [Inventaires].[objet] obj
	ON obj.ObjetID = inv.ObjetID
	GROUP BY ach.MembreID, mem.Nom, obj.Nom
	ORDER BY COUNT(ach.MembreID) DESC
	
---------------------------------------------------------------------
--Correction de la partie corrigée
---------------------------------------------------------------------
	
-- Correction des fautes d'orthographes...

-- Mettre les schemas au pluriel

-- Ajouter les valeurs pas défauts dans un alter table
GO
ALTER TABLE Membres.membre 
ADD CONSTRAINT DF_Adresse DEFAULT 'Aucune' FOR Adresse;
GO

GO
ALTER TABLE Batailles.Bataille
ADD CONSTRAINT DF_NombreMort DEFAULT 0 FOR NombreMort;
GO



------------------------------------------------------------------------  Remise 3 ------------------------------------------------------------------------------------



---------------------------------------------------------------------
--Correction TP2
---------------------------------------------------------------------

--Corrigé: Mettre un atlas pour les champs sans nom de colonne
--Corrigé: Pas de résultats pour certaines de tes US 
--Corrigé: Copie les textes de tes US près de tes solutions
--Corrigé: Toujours pas de contrainte UNIQUE
ALTER TABLE Inventaires.Objet
	ADD CONSTRAINT UC_Objet UNIQUE (Nom); 

--Corrigé: Il faut aussi des index NC pour toutes les clés étrangères des tables
CREATE NONCLUSTERED INDEX IX_Inventaires_MembreID
ON Inventaires.Inventaire
(
	MembreID
);

CREATE NONCLUSTERED INDEX IX_Inventaires_ObjetID
ON Inventaires.Inventaire
(
	ObjetID
);

CREATE NONCLUSTERED INDEX IX_Reservoirs_MembreID
ON Reservoirs.achat
(
	MembreID
);

CREATE NONCLUSTERED INDEX IX_Reservoirs_ReservoirID
ON Reservoirs.achat
(
	ReservoirsID
);

CREATE NONCLUSTERED INDEX IX_Batailles_VilleID
ON Batailles.Bataille
(
	VilleID
);

-- Il aurait fallu faire des DML pour insérer/modifier des données
-- Insérer ->
IF OBJECT_ID('dbo.usp_ajouterUnObjet', 'P') IS NOT NULL
		DROP PROCEDURE dbo.usp_ajouterUnObjet;
	GO

	CREATE PROCEDURE dbo.usp_ajouterUnObjet
	 @nomObjet AS VARCHAR(50),
	 @valeur int,
	 @rarete AS VARCHAR(50)			
	AS
	BEGIN
		INSERT INTO Inventaires.objet (Nom, Valeur, Rarete)
		VALUES (@nomObjet, @valeur, @rarete);
	END
	GO

	SELECT * FROM Inventaires.objet

	EXECUTE dbo.usp_ajouterUnObjet @nomObjet = 'Téléphone', @valeur = 200, @rarete = 'Peu commun'

	SELECT * FROM Inventaires.objet

-- Modifier ->
IF OBJECT_ID('dbo.usp_modifierValeurObjet', 'P') IS NOT NULL
		DROP PROCEDURE dbo.usp_modifierUnObjet;
	GO

	CREATE PROCEDURE dbo.usp_modifierUnObjet
	 @nomObjetAModifier AS VARCHAR(50),
	 @valeur int	
	AS
	BEGIN
		UPDATE Inventaires.objet SET Valeur = @valeur
		WHERE Nom = @nomObjetAModifier
	END
	GO

	SELECT * FROM Inventaires.objet

	EXECUTE dbo.usp_modifierUnObjet @nomObjetAModifier = 'Metal', @valeur = 40

	SELECT * FROM Inventaires.objet

-- Modification de la requête de la US1 avec DML pour insérer:
INSERT INTO Reservoirs.Reservoir (Quantite, QuantiteDate) VALUES (200, '2018-02-21 00:00:00'),
(190, '2018-02-20 00:00:00'),
(210, '2018-02-19 00:00:00');	
	
	WITH QuantiteToday AS (
		SELECT Quantite as QuantiteToday
		 FROM [Reservoirs].[Reservoir]
		WHERE DAY(QuantiteDate) = DAY(GETDATE())
	), QuantiteHier AS (
		SELECT Quantite as QuantiteHier FROM [Reservoirs].[Reservoir]
		WHERE DAY(QuantiteDate) = DAY(GETDATE() - 1)
	)

	SELECT CASE 
	WHEN (QuantiteToday > QuantiteHier) THEN 'La quantité d''hier est plus grand qu''aujourd''hui'
	WHEN (QuantiteToday = QuantiteHier) THEN 'La quantité d''hier est au même niveau qu''aujourd''hui'
	WHEN (QuantiteToday < QuantiteHier) THEN'La quantité d''hier est moin grande qu''aujourd''hui'
	END as 'Comparaison du niveau d''eau'
	FROM QuantiteToday tod
	INNER JOIN QuantiteHier hie
	ON 1 = 1


---------------------------------------------------------------------
--Refaites les solutions aux interrogations pour utiliser les fonctions ou les procédures lorsque c’est approprié.
---------------------------------------------------------------------

-- US6: Quelles sont les 3 personnes à avoir acheté le plus souvent d'eau à la ville? Afficher son Inventaires.
	IF OBJECT_ID('dbo.usp_avoirFrequenceAchat', 'P') IS NOT NULL
		DROP PROCEDURE dbo.usp_avoirFrequenceAchat;
	GO

	CREATE PROCEDURE dbo.usp_avoirFrequenceAchat
	 @nomMembre AS VARCHAR(50),
	 @nomObjet AS VARCHAR(50)			
	AS
	BEGIN

	SELECT mem.Nom, obj.Nom, COUNT(obj.Nom) as 'Nombre d''objet(s) identitque(s)'
	FROM [Reservoirs].[achat] ach
	INNER JOIN [Membres].[membre] mem
	ON mem.MembreID = ach.MembreID
	INNER JOIN [Inventaires].[inventaire] inv
	ON inv.MembreID = mem.MembreID
	INNER JOIN [Inventaires].[objet] obj
	ON obj.ObjetID = inv.ObjetID
	WHERE @nomMembre = mem.Nom AND @nomMembre IN (SELECT TOP 3 mem.Nom FROM [Reservoirs].[achat] ach
						INNER JOIN [Membres].[membre] mem
						ON mem.MembreID = ach.MembreID
						INNER JOIN [Inventaires].[inventaire] inv
						ON inv.MembreID = mem.MembreID
						INNER JOIN [Inventaires].[objet] obj
						ON obj.ObjetID = inv.ObjetID
						GROUP BY mem.Nom, obj.Nom
						ORDER BY COUNT(mem.Nom) DESC) 
						
						AND @nomObjet = obj.Nom AND @nomObjet IN (SELECT TOP 3 obj.Nom FROM [Reservoirs].[achat] ach
						INNER JOIN [Membres].[membre] mem
						ON mem.MembreID = ach.MembreID
						INNER JOIN [Inventaires].[inventaire] inv
						ON inv.MembreID = mem.MembreID
						INNER JOIN [Inventaires].[objet] obj
						ON obj.ObjetID = inv.ObjetID
						GROUP BY mem.Nom, obj.Nom
						ORDER BY COUNT(obj.Nom) DESC)
	GROUP BY mem.Nom, obj.Nom
	ORDER BY COUNT(obj.Nom) DESC

	RETURN
	END
	GO

	-- Regarde si le membre avec le nom et le nom d'objet choisi est bien dans le TOP 3. Il affiche après si il existe.
	EXECUTE dbo.usp_avoirFrequenceAchat @nomMembre = 'Coulombe', @nomObjet = 'Metal'

---------------------------------------------------------------------
--Trouvez un champ calculé qui ferait du sens dans votre projet. Faites un ALTER TABLE pour ajouter ce champ dans une de vos entités. Puis faites une fonction pour calculer ce champ.
---------------------------------------------------------------------

-- Champ calculé -> le nombre d'habitants dans une ville

-- Ajout table associative ville -> membre
GO
CREATE TABLE Membres.villeMembre
(
	MembreID int NOT NULL, 
	VilleID int NOT NULL
)
GO


INSERT INTO Membres.villeMembre (MembreID, VilleID) VALUES (1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 2),
(6, 3),
(7, 4),
(8, 4);


GO
ALTER TABLE Villes.ville
ADD NombreHabitant int
GO

SELECT * FROM Villes.ville

GO
IF OBJECT_ID('dbo.udf_avoirNombreHabitant', 'FN') IS NOT NULL
	DROP FUNCTION dbo.udf_avoirNombreHabitant;

GO
CREATE FUNCTION dbo.udf_avoirNombreHabitant(@IDVille AS INT) RETURNS INT
AS
BEGIN
	DECLARE @compte AS int

	SELECT @compte = COUNT(vm.MembreID) FROM Villes.ville v
	INNER JOIN Membres.villeMembre vm
	ON vm.VilleID = v.VilleID
	INNER JOIN Membres.membre m
	ON m.MembreID = vm.MembreID
	WHERE @IDVille = v.VilleID
	GROUP BY v.Nom

	RETURN @compte
END
GO

SELECT dbo.udf_avoirNombreHabitant(1) as 'Habitant dans la ville'

UPDATE Villes.Ville
SET NombreHabitant = dbo.udf_avoirNombreHabitant(VilleID)


---------------------------------------------------------------------
--Trouvez un AUTRE champ calculé qui ferait du sens dans votre projet. NE faites PAS un ALTER TABLE pour ajouter ce champ dans une de vos entités. Puis faites une fonction pour calculer ce champ.
---------------------------------------------------------------------

-- Champ calculé no.2 -> La valeur des objets dans l'inventaire d'un membre

GO
IF OBJECT_ID('dbo.udf_avoirValeurInventaire', 'FN') IS NOT NULL
	DROP FUNCTION dbo.udf_avoirValeurInventaire;

GO
CREATE FUNCTION dbo.udf_avoirValeurInventaire(@IDMembre AS INT) RETURNS INT
AS
BEGIN
	DECLARE @valeur AS int

	SELECT @valeur = SUM(o.Valeur) FROM Inventaires.inventaire i
	INNER JOIN Inventaires.objet o
	ON o.ObjetID = i.ObjetID
	INNER JOIN Membres.membre m
	ON m.MembreID = i.MembreID
	WHERE m.MembreID = @IDMembre
	GROUP BY m.MembreID

	RETURN @valeur
END
GO

SELECT dbo.udf_avoirValeurInventaire(2) as 'Valeur inventaire'


---------------------------------------------------------------------
-- Faites un ALTER TABLE pour ajouter le champ en l’initialisant avec cette dernière fonction.
---------------------------------------------------------------------

GO
ALTER TABLE Membres.membre
ADD ValeurInventaire AS dbo.udf_avoirValeurInventaire(MembreID)
GO


---------------------------------------------------------------------
--Faites une vue pour une interrogation complexe que vous pourriez ensuite utiliser dans une procédure.
---------------------------------------------------------------------

--la valeur de l'inventaire d'un membre est plus haute que la moyenne des membres dans une ville

IF OBJECT_ID('Inventaires.vw_MoyenneInventaire', 'V') IS NOT NULL
	DROP VIEW Inventaires.vw_MoyenneInventaire;

GO

CREATE VIEW Inventaires.vw_MoyenneInventaire
AS
	SELECT vm.VilleID as ville, AVG(m.ValeurInventaire) as valeurAvg FROM [Membres].[membre] m
	INNER JOIN [Membres].[villeMembre] vm
	ON vm.MembreID = m.MembreID
	INNER JOIN [Villes].[ville] v
	ON vm.VilleID = v.VilleID
	GROUP BY vm.VilleID
GO

IF OBJECT_ID('dbo.usp_estPlusQueMoyenne', 'P') IS NOT NULL
	DROP PROCEDURE dbo.usp_estPlusQueMoyenne;
GO

GO
CREATE PROCEDURE dbo.usp_estPlusQueMoyenne
@IdMembre AS INT
AS
BEGIN
	SELECT ValeurInventaire FROM [Membres].[membre] m
	INNER JOIN [Membres].[villeMembre] vm
	ON m.MembreID = vm.MembreID
	INNER JOIN [Villes].[ville] v
	ON v.VilleID = vm.VilleID
	WHERE m.MembreID = @IdMembre AND ValeurInventaire > (SELECT valeurAvg FROM Inventaires.vw_MoyenneInventaire moy WHERE moy.ville = vm.VilleID)
END
GO

EXECUTE dbo.usp_estPlusQueMoyenne @IdMembre = 1




------------------------------------------------------------------------  Remise 4 ------------------------------------------------------------------------------------




---------------------------------------------------------------------
--Correction TP3
---------------------------------------------------------------------

--La procedure dbo.usp_ajouterUnObjet devrait vérifier que l'on n'est pas en train d'ajouter une clé en double dans un champ UNIQUE
GO

IF OBJECT_ID('dbo.usp_ajouterUnObjet', 'P') IS NOT NULL
		DROP PROCEDURE dbo.usp_ajouterUnObjet;
	GO

	CREATE PROCEDURE dbo.usp_ajouterUnObjet
	 @nomObjet AS VARCHAR(50),
	 @valeur int,
	 @rarete AS VARCHAR(50)			
	AS
	BEGIN
		BEGIN TRY
			INSERT INTO Inventaires.objet (Nom, Valeur, Rarete)
			VALUES (@nomObjet, @valeur, @rarete);
		END TRY
		BEGIN CATCH
			SELECT 'Ce nom d''item existe déjà!' as Erreur
		END CATCH
	END
	GO

	SELECT * FROM Inventaires.objet

	EXECUTE dbo.usp_ajouterUnObjet @nomObjet = 'Téléphone', @valeur = 200, @rarete = 'Peu commun'

	SELECT * FROM Inventaires.objet

---------------------------------------------------------------------
--Créez une table historique pour cette table en ajoutant un autre id et un champ dateMAJ qui sera un timedate2 
---------------------------------------------------------------------
GO
CREATE TABLE Membres.hist_membre
(
	HistoriqueMembreID int IDENTITY(1,1) NOT NULL,
	MembreID int,
	Prenom nvarchar(50) NOT NULL,
	Nom nvarchar(50) NOT NULL,
	Age int NOT NULL,
	Adresse nvarchar(50) NULL,
	DateAjout datetime2 NOT NULL,
	dateMAJ datetime2 NOT NULL
	CONSTRAINT PK_Membre_HistoriqueMembreID PRIMARY KEY (HistoriqueMembreID)
) ON [PRIMARY];
GO

CREATE TABLE Reservoirs.hist_achat
(
	HistoriqueAchatID int IDENTITY(1,1) NOT NULL,
	AchatID int,
	MembreID int NOT NULL,
	ReservoirsID int NOT NULL,
	Quantite int NOT NULL,
	DateAchat datetime2 NOT NULL,
	DateAjout datetime2 NOT NULL,
	dateMAJ datetime2 NOT NULL
	CONSTRAINT PK_Membre_HistoriqueAchatID PRIMARY KEY (HistoriqueAchatID)
) ON [PRIMARY];

GO

---------------------------------------------------------------------
--Faites un modification à cette table historique pour ajouter une contrainte default
---------------------------------------------------------------------
GO

ALTER TABLE Membres.hist_membre
	ADD CONSTRAINT DF_dateMAJ DEFAULT CURRENT_TIMESTAMP FOR dateMAJ;

ALTER TABLE Reservoirs.hist_achat
	ADD CONSTRAINT DF_dateMAJ DEFAULT CURRENT_TIMESTAMP FOR dateMAJ;

---------------------------------------------------------------------
--Il faut alors créer des tables historiques pour tous les enfants.
---------------------------------------------------------------------

--Ajout d'une date d'ajout dans les tables pour les historique
GO
ALTER TABLE Membres.membre
ADD DateAjout datetime2;

GO

ALTER TABLE Reservoirs.achat
ADD DateAjout datetime2;

--Ajout des données dans les nouveaux champs
GO

DELETE FROM Membres.membre
WHERE 1=1

GO

DELETE FROM Reservoirs.achat
WHERE 1=1

GO

DELETE FROM Inventaires.inventaire
WHERE 1=1

GO

INSERT INTO Membres.membre (Prenom, Nom, Age, Adresse, DateAjout) VALUES ('Alexis', 'Coulombe', 20, '123 meumeu', '2018-02-01 22:05:55'),
('Andrei', 'Colombus', 5, '1625 des poules', '2018-01-29 10:05:55'),
('Joe', 'La patate', 20, '365 du pomier', '2017-12-08 13:05:55'),
('Jertrude', 'La patate', 28, '365 du pomier', '2017-07-18 13:05:55'),
('Bob', 'Captial', 45, NULL, '2017-10-10 14:05:55'),
('Roger', 'Remax', 67, '365 du pomier', '2017-01-29 18:05:55'),
('Linda', 'Platine', 18, NULL, '2018-02-12 16:05:55'),
('Monique', 'La poutine', 100, NULL, '2018-02-10 09:05:55');

GO

INSERT INTO Inventaires.inventaire (MembreID, ObjetID) VALUES (09, 1),
(11, 4),
(12, 7),
(09, 2),
(09, 2),
(12, 3),
(12, 1),
(11, 6),
(09, 6),
(09, 7);

GO

INSERT INTO Reservoirs.achat (MembreID, ReservoirsID, Quantite, DateAchat, DateAjout) VALUES (9, 1, 10, '2018-01-29 23:45:00', '2018-01-29 23:45:00'),
(10, 1, 20, '2018-01-29 13:05:55', '2018-01-29 13:05:55'),
(9, 2, 10, '2017-12-02 11:05:00', '2017-12-02 11:05:00'),
(14, 2, 10, '2016-10-10 17:10:00', '2016-10-10 17:10:00'),
(15, 2, 10, '2015-06-18 19:05:00', '2015-06-18 19:05:00'),
(15, 2, 10, '2016-05-03 22:45:00', '2016-05-03 22:45:00'),
(13, 4, 10, '2010-10-10 18:18:49', '2010-10-10 18:18:49');


GO

IF OBJECT_ID('dbo.usp_ajouterHistorique', 'P') IS NOT NULL
	DROP PROCEDURE dbo.usp_ajouterHistorique;
GO

GO
CREATE PROCEDURE dbo.usp_ajouterHistorique
 @tempsUn as datetime2,
 @tempsDeux as datetime2
AS
BEGIN
	INSERT INTO Membres.hist_membre (MembreID, Prenom, Nom, Age, Adresse, DateAjout)
	SELECT m.MembreID, m.Prenom, m.Nom, m.Age, m.Adresse, m.DateAjout FROM Membres.membre m WHERE m.DateAjout >= @tempsUn AND m.DateAjout <= @tempsDeux;

	DELETE FROM Membres.membre
	WHERE DateAjout >= @tempsUn AND DateAjout <= @tempsDeux; 

	INSERT INTO Reservoirs.hist_achat (AchatID, MembreID, ReservoirsID, Quantite, DateAchat, DateAjout)
	SELECT a.AchatID, a.MembreID, a.ReservoirsID, a.Quantite, a.DateAchat, a.DateAjout FROM Reservoirs.achat a WHERE a.DateAjout >= @tempsUn AND a.DateAjout <= @tempsDeux;

	DELETE FROM Reservoirs.achat
	WHERE DateAjout >= @tempsUn AND DateAjout <= @tempsDeux; 
END
GO

SELECT * FROM Membres.membre
SELECT * FROM Reservoirs.achat
SELECT * FROM Membres.hist_membre
SELECT * FROM Reservoirs.hist_achat

EXECUTE dbo.usp_ajouterHistorique @tempsUn = '2010-01-01 00:00:00', @tempsDeux = '2016-01-01 00:00:00'

SELECT * FROM Membres.hist_membre
SELECT * FROM Reservoirs.hist_achat


---------------------------------------------------------------------
--Trouvez une autre procédure qui serait intéressante dans votre projet. Elle devra avoir des paramètres de type input absolument.
---------------------------------------------------------------------
GO

-- Modifier le nom du membre dans la table Membres.membre pour afficher la valeur de son inventaire à son prenom
-- Exemple: Alexis (40), UnNom (210) ...

--IF OBJECT_ID('dbo.usp_inscrireInventaireValeurAuNom', 'P') IS NOT NULL
--	DROP PROCEDURE dbo.usp_inscrireInventaireValeurAuNom;
--GO

--CREATE PROCEDURE dbo.usp_inscrireInventaireValeurAuNom
-- @idMembre varchar(50) 
--AS
--BEGIN
--	UPDATE Membres.membre
--	SET Nom = CONCAT((SELECT Nom FROM Membres.membre WHERE MembreID = @idMembre), ' (',
--	 (SELECT SUM(valeurTotale) FROM Inventaires.vw_InventaireAvance WHERE MembreID = @idMembre), ')')
--END
--GO

--SELECT * FROM Membres.membre WHERE MembreID = 9

--EXECUTE dbo.usp_inscrireInventaireValeurAuNom @idMembre = 09;

--SELECT * FROM Membres.membre WHERE MembreID = 9;


---------------------------------------------------------------------
--Faites une procédure pour insérer des données dans une table où vous avez une contrainte check. (TRY CATCH)
---------------------------------------------------------------------
GO

IF OBJECT_ID('dbo.usp_insererContrainteCheck', 'P') IS NOT NULL
	DROP PROCEDURE dbo.usp_insererContrainteCheck;
GO

CREATE PROCEDURE dbo.usp_insererContrainteCheck
 @valeur int,
 @date datetime2
AS
BEGIN
	BEGIN TRY
	INSERT INTO Reservoirs.Reservoir
		VALUES (@valeur, @date);
	END TRY
	BEGIN CATCH
		SELECT 'Une erreur est survenue lors de l''insertion de donnée dans un reservoir' as 'Erreur!';
	END CATCH
END
GO

SELECT * FROM Reservoirs.Reservoir

EXECUTE dbo.usp_insererContrainteCheck @valeur = 0, @date = '2018-03-20 22:00:00';

SELECT * FROM Reservoirs.Reservoir



------------------------------------------------------------------------  Remise 5tr_ajouterValeurDefautAMembre ------------------------------------------------------------------------------------



---------------------------------------------------------------------
--Inventez un trigger qui déclencherait l’exécution pour archiver des données
---------------------------------------------------------------------
GO

IF OBJECT_ID('Membres.tr_ajouterValeurDefautAMembre', 'TR') IS NOT NULL
	DROP TRIGGER Membres.tr_ajouterValeurDefautAMembre;
GO

SELECT * FROM Membres.membre

GO
CREATE TRIGGER Membres.tr_ajouterValeurDefautAMembre
ON [Membres].[membre]
AFTER INSERT
AS
BEGIN
	DECLARE @adresse varchar(50)
	DECLARE @dateAjout datetime2
	DECLARE @membreid int

	SELECT TOP(1) @membreid = MembreID, @adresse = Adresse, @dateAjout = DateAjout FROM Membres.membre
	ORDER BY MembreID DESC

	IF @adresse IS NULL 
		UPDATE Membres.membre SET Adresse = 'Aucune Adresse' WHERE MembreID = @membreid

	IF @dateAjout IS NULL 
		UPDATE Membres.membre SET DateAjout = CURRENT_TIMESTAMP WHERE MembreID = @membreid
END

INSERT INTO Membres.membre (Prenom, Nom, Age) VALUES ('Un', 'Nom', 46)

SELECT * FROM Membres.membre


---------------------------------------------------------------------
--Inventez un autre trigger de votre choix 
---------------------------------------------------------------------
GO
CREATE TABLE Membres.HistoriqueModification
(
	id int IDENTITY(1,1),
	information varchar(50) NOT NULL,
	dateModification datetime2 DEFAULT CURRENT_TIMESTAMP
);

GO

IF OBJECT_ID('Membres.tr_ajouterDansHistorique', 'TR') IS NOT NULL
	DROP TRIGGER Membres.tr_ajouterDansHistorique;
GO

SELECT * FROM Membres.HistoriqueModification

GO
CREATE TRIGGER Membres.tr_ajouterDansHistorique
ON Membres.membre
AFTER DELETE
AS
BEGIN
	INSERT INTO Membres.HistoriqueModification(information) VALUES ('Utilisateur supprimé')
END

DELETE FROM Membres.membre WHERE MembreID = 14

SELECT * FROM Membres.HistoriqueModification


---------------------------------------------------------------------
--Inventez une tâche cédulée qui ferait du sens dans le contexte de votre projet 
---------------------------------------------------------------------
GO

CREATE PROCEDURE Inventaires.AjouterValeurObjet
AS
BEGIN
	UPDATE Inventaires.objet SET Valeur = Valeur * 0.05;
END

GO

USE msdb

GO

EXEC sp_add_schedule
@schedule_name = N'Ajouter valeur a objet',
@freq_type = 1,
@active_start_time = 160000;
GO

EXEC dbo.sp_add_job
@job_name = N'Job ajouter valeur'
GO

EXEC sp_add_jobstep
@job_name = N'Job ajouter valeur',
@step_name = N'Augmenter valeur d''un objet',
@subsystem = N'TSQL',
@database_name = N'MadMax',
@command = N'EXEC [Inventaires].[AjouterValeurObjet]',
@retry_attempts = 5,
@retry_interval = 5;
