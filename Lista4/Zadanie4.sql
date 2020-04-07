
DROP TABLE IF EXISTS Wypozyczenie;
GO

DROP TABLE IF EXISTS Egzemplarz;
GO

DROP TABLE IF EXISTS Czytelnik;
GO

DROP TABLE IF EXISTS Ksiazka;
GO

CREATE TABLE Ksiazka
(
    Ksiazka_ID INT IDENTITY
,
    ISBN VARCHAR(20)
,
    Tytul VARCHAR(300)
,
    Autor VARCHAR(200)
,
    Rok_Wydania INT
,
    Cena DECIMAL(10,2)
,
    Wypozyczona_Ostatni_Miesiac BIT
,
    CONSTRAINT Ksiazka_PK PRIMARY KEY (Ksiazka_ID)
,
    CONSTRAINT Ksiazka_UK_ISBN UNIQUE (ISBN)
);
GO

CREATE TABLE Egzemplarz
(
    Egzemplarz_ID INT IDENTITY
,
    Sygnatura CHAR(8)
,
    Ksiazka_ID INT
,
    CONSTRAINT Egzemplarz_PK PRIMARY KEY (Egzemplarz_ID)
,
    CONSTRAINT Egzemplarz_UK_Sygnatura UNIQUE (Sygnatura)
,
    CONSTRAINT Egzemplarz_FK FOREIGN KEY (Ksiazka_ID) REFERENCES Ksiazka (Ksiazka_ID) ON DELETE CASCADE
);
GO


SET IDENTITY_INSERT Ksiazka ON
INSERT INTO Ksiazka
    (Ksiazka_ID,ISBN,Tytul,Autor,Rok_Wydania,Cena)
VALUES
    (1, '83-246-0279-8', 'Microsoft Access. Podr�cznik administratora', 'Helen Feddema', 2006, 69),
    (2, '83-246-0653-X', 'SQL Server 2005. Programowanie. Od podstaw', 'Robert Vieira', 2007, 97),
    (3, '978-83-246-0549-1', 'SQL Server 2005. Wyci�nij wszystko', 'Eric L. Brown', 2007, 57),
    (4, '978-83-246-1258-1', 'PHP, MySQL i MVC. Tworzenie witryn WWW opartych na bazie danych', 'W�odzimierz Gajda', 2010, 79),
    (5, '978-83-246-2060-9', 'Access 2007 PL. Seria praktyk', 'Andrew Unsworth', 2009, 39),
    (6, '978-83-246-2188-0', 'Czysty kod. Podr�cznik dobrego programisty', 'Robert C. Martin', 2010, 67);
SET IDENTITY_INSERT Ksiazka OFF
GO

SET IDENTITY_INSERT Egzemplarz ON
INSERT INTO Egzemplarz
    (Egzemplarz_ID,Ksiazka_ID,Sygnatura)
VALUES
    (1, 5, 'S0001'),
    (2, 5, 'S0002'),
    (3, 1, 'S0003'),
    (4, 1, 'S0004'),
    (5, 1, 'S0005'),
    -- (6,2,'S0006'),
    (7, 3, 'S0007'),
    (8, 3, 'S0008'),
    (9, 3, 'S0009'),
    (10, 3, 'S0010'),
    (11, 6, 'S0011'),
    (12, 6, 'S0012'),
    (13, 4, 'S0013'),
    (14, 4, 'S0014'),
    (15, 4, 'S0015');
SET IDENTITY_INSERT Egzemplarz OFF
GO

--Niezgrupowane indexy:

CREATE NONCLUSTERED INDEX ncIX1 ON Egzemplarz(Ksiazka_ID)
INCLUDE(Egzemplarz_ID)
GO
CREATE NONCLUSTERED INDEX ncIX2 ON Ksiazka(Ksiazka_ID)
GO

--Zgrupowane indexy, najpierw musimy usunąć istniejące:

ALTER TABLE Egzemplarz
DROP CONSTRAINT Egzemplarz_PK
GO

ALTER TABLE Egzemplarz
DROP CONSTRAINT Egzemplarz_FK
GO

ALTER TABLE Ksiazka
DROP CONSTRAINT Ksiazka_PK
GO

CREATE CLUSTERED INDEX cIX1 ON Egzemplarz(Ksiazka_ID)
GO

CREATE CLUSTERED INDEX cIX2 ON Ksiazka(Ksiazka_ID)
GO

--Index kryjący

CREATE NONCLUSTERED INDEX covIX1 ON Egzemplarz(Ksiazka_ID, Egzemplarz_ID);
GO

SELECT e.Egzemplarz_ID
FROM Ksiazka k
    JOIN Egzemplarz e ON e.Ksiazka_ID = k.Ksiazka_ID
GROUP BY e.Egzemplarz_ID