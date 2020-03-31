--Zadanie 1

http://sqlfiddle.com/#!18/1495e/6

drop function if exists borrowed_longer_than
go

create function borrowed_longer_than(@daysCount int)
returns table
return (select czytelnik.PESEL as PESEL, count(wypozyczenie.Wypozyczenie_ID) as Liczba_Egzemplarzy
from Czytelnik czytelnik join Wypozyczenie wypozyczenie
        on czytelnik.Czytelnik_ID=wypozyczenie.Czytelnik_ID and wypozyczenie.Liczba_Dni>=@daysCount group by czytelnik.PESEL having count(wypozyczenie.Wypozyczenie_ID)>0)

go
select * from borrowed_longer_than(10)

--Zadanie 2

--SCHEME

DROP TABLE IF EXISTS imiona;
CREATE TABLE imiona
( imie_ID INT IDENTITY
, imie VARCHAR(30)
, CONSTRAINT imie_PK PRIMARY KEY (imie_ID)
);
GO

DROP TABLE IF EXISTS  nazwiska;
CREATE TABLE nazwiska
( nazwisko_ID INT IDENTITY
, nazwisko VARCHAR(30)
, CONSTRAINT nazwisko_PK PRIMARY KEY (nazwisko_ID)
);
GO

DROP TABLE IF EXISTS  dane;
CREATE TABLE dane
( imie VARCHAR(30)
, nazwisko VARCHAR(30)
, CONSTRAINT dane_PK PRIMARY KEY (imie, nazwisko)
);
GO

SET IDENTITY_INSERT imiona ON
INSERT INTO imiona (imie_ID,imie) VALUES
(1, 'Agnieszka'),
(2, 'Grzegorz'),
(3, 'Maja'),
(4, 'Piotr'),
(5, 'Jakub'),
(6, 'Szymon');
SET IDENTITY_INSERT imiona OFF
GO

SET IDENTITY_INSERT nazwiska ON
INSERT INTO nazwiska (nazwisko_ID, nazwisko) VALUES
(1, 'Nowak'),
(2, 'Kowalski'),
(3, 'Wiśniewski'),
(4, 'Wójcik'),
(5, 'Kowalczyk'),
(6, 'Kamiński');
SET IDENTITY_INSERT nazwiska OFF
GO

--ZAPYTANIA

DROP PROCEDURE IF EXISTS dodaj_dane
GO

CREATE PROCEDURE dodaj_dane @n INT
AS
BEGIN
  DELETE FROM dane
  DECLARE @ilosc_imion INT
  DECLARE @ilosc_nazwisk INT
  DECLARE @nowe_imie VARCHAR(30)
  DECLARE @nowe_nazwisko VARCHAR(30)
  SET @ilosc_imion = (SELECT COUNT(imie_ID) as ile_imion FROM imiona)
  SET @ilosc_nazwisk = (SELECT COUNT(nazwisko_ID) as ile_nazwisk FROM nazwiska)

  IF POWER(@ilosc_imion, @ilosc_nazwisk) < 2*@n THROW 50000 , 'Za duze n!', 1
  ELSE
  BEGIN
    WHILE((SELECT COUNT(*) as ile_danych FROM dane) < @n)
      BEGIN
      SET @nowe_imie = (SELECT TOP 1 imie FROM imiona ORDER BY NEWID())
      SET @nowe_nazwisko = (SELECT TOP 1 nazwisko FROM nazwiska ORDER BY NEWID())
      IF (NOT EXISTS(SELECT * FROM dane WHERE imie = @nowe_imie AND nazwisko = @nowe_nazwisko))
      BEGIN
          INSERT INTO dane(imie, nazwisko)
          VALUES(@nowe_imie, @nowe_nazwisko)
      END
    END
  END
END
GO

EXEC dodaj_dane @n = 3
GO

--Zadanie 3
--DOPISAĆ DO BIBLIOTEKI

DROP TABLE IF EXISTS Wyniki;
GO
DROP TYPE IF EXISTS TabelaIDType;
GO
CREATE TYPE TabelaIDType AS TABLE (Czytelnik_ID INT);
GO

CREATE TABLE Wyniki
( Czytelnik_ID INT,
  Suma INT);
GO

--ZAPYTANIA

DROP PROCEDURE IF EXISTS CalculateDays;
GO

CREATE PROCEDURE CalculateDays @TabelaID TabelaIDType READONLY
AS
BEGIN
INSERT INTO Wyniki SELECT
  tab.Czytelnik_ID as Czytelnik_ID, SUM(wypozyczenie.Liczba_Dni) AS Suma FROM @TabelaID tab
  JOIN Wypozyczenie wypozyczenie ON wypozyczenie.Czytelnik_ID = tab.Czytelnik_ID GROUP BY tab.Czytelnik_ID
END
GO

DECLARE @ids TabelaIDType
INSERT INTO @ids SELECT Czytelnik_ID FROM Czytelnik
EXEC CalculateDays @ids
GO

SELECT * FROM Wyniki

--Ewentualnie (czemu nie działa?):
--https://stackoverflow.com/questions/1443663/how-to-return-temporary-table-from-stored-procedure

DROP PROCEDURE IF EXISTS CalculateDays;
GO

CREATE PROCEDURE CalculateDays @TabelaID TabelaIDType READONLY
AS
SET NOCOUNT ON
RETURN
@results TABLE (Czytelnik_ID int, Suma int)
BEGIN
INSERT INTO @results SELECT
  tab.Czytelnik_ID as Czytelnik_ID, SUM(wypozyczenie.Liczba_Dni) AS Suma FROM @TabelaID tab
  JOIN Wypozyczenie wypozyczenie ON wypozyczenie.Czytelnik_ID = tab.Czytelnik_ID GROUP BY tab.Czytelnik_ID
SELECT * FROM @results
END
GO

DECLARE @ids TabelaIDType
INSERT INTO @ids SELECT Czytelnik_ID FROM Czytelnik
EXEC CalculateDays @ids
GO


--Zadanie 4
--Bazowałam na http://www.sommarskog.se/dyn-search.html#dynsql

CREATE PROCEDURE dynamic_search
  @tytul varchar(300) = null,
  @autor varchar(200) = null,
  @rok_wydania int = null
  @debug bit = 0
AS
BEGIN
DECLARE
  @sql nvarchar(MAX),
  @paramlist nvarchar(4000),
  @nl char(2) = char(13) + char(10)
SELECT @sql = 'SELECT COUNT(e.Egzemplarz_ID) FROM Ksiazka k JOIN Egzemplarz e ON e.Ksiazka_ID = k.Ksiazka_ID
WHERE 1 = 1' + @nl
IF @tytul IS NOT NULL
   SELECT @sql += 'AND k.Tytul = @tytul' + @nl
IF @autor IS NOT NULL
    SELECT @sql += 'AND k.Autor = @autor' + @nl
IF @rok_wydania IS NOT NULL
    SELECT @sql += 'AND k.Rok_wydania = @rok_wydania' + @nl
IF @debug = 1
    PRINT @sql
SELECT @paramlist = '@tytul varchar(300), @autor varchar(300), @rok_wydania int'
EXEC sp_executesql @sql, @paramlist, @tytul, @autor, @rok_wydania
END
GO

EXEC dynamic_search @tytul = 'Access 2007 PL. Seria praktyk' --2
EXEC dynamic_search @autor = 'Andrew Unsworth' --2
EXEC dynamic_search @rok_wydania = 2007 --4
EXEC dynamic_search @rok_wydania = 2007, @autor = 'Andrew Unsworth' --0
EXEC dynamic_search @rok_wydania = 2009, @autor = 'Andrew Unsworth' --2

--Czy da się to zrobić nie za pomocą dynamicznego SQL?
--Można np. wyifować wszystkie możliwości
--Albo static sql + recompile, analogicznie do:
CREATE PROCEDURE search_orders_3
                 @orderid   int          = NULL,
                 @fromdate  datetime     = NULL,
                 @todate    datetime     = NULL,
                 @minprice  money        = NULL,
                 @maxprice  money        = NULL,
                 @custid    nchar(5)     = NULL,
                 @custname  nvarchar(40) = NULL,
                 @city      nvarchar(15) = NULL,
                 @region    nvarchar(15) = NULL,
                 @country   nvarchar(15) = NULL,
                 @prodid    int          = NULL,
                 @prodname  nvarchar(40) = NULL AS

SELECT o.OrderID, o.OrderDate, od.UnitPrice, od.Quantity,
       c.CustomerID, c.CompanyName, c.Address, c.City, c.Region,
       c.PostalCode, c.Country, c.Phone, p.ProductID,
       p.ProductName, p.UnitsInStock, p.UnitsOnOrder
FROM   Orders o
JOIN   [Order Details] od ON o.OrderID = od.OrderID
JOIN   Customers c ON o.CustomerID = c.CustomerID
JOIN   Products p ON p.ProductID = od.ProductID
WHERE  (o.OrderID = @orderid OR @orderid IS NULL)
  AND  (o.OrderDate >= @fromdate OR @fromdate IS NULL)
  AND  (o.OrderDate <= @todate OR @todate IS NULL)
  AND  (od.UnitPrice >= @minprice OR @minprice IS NULL)
  AND  (od.UnitPrice <= @maxprice OR @maxprice IS NULL)
  AND  (o.CustomerID = @custid OR @custid IS NULL)
  AND  (c.CompanyName LIKE @custname + '%' OR @custname IS NULL)
  AND  (c.City = @city OR @city IS NULL)
  AND  (c.Region = @region OR @region IS NULL)
  AND  (c.Country = @country OR @country IS NULL)
  AND  (od.ProductID = @prodid OR @prodid IS NULL)
  AND  (p.ProductName LIKE @prodname + '%' OR @prodname IS NULL)
ORDER  BY o.OrderID
OPTION (RECOMPILE)

-- The hint instructs SQL Server to recompile the query every time.
-- Without this hint, SQL Server produces a plan that will be cached and reused.
--Jeśli dany argument jest nullem to odpowiadający mu AND jest zawsze prawdziwy
