-- Nie do końca rozumiem treść. Ja robię tak, że jak usunę jakąś walutę z Kursów to znikają ceny w niej podane.
-- Aktualizujemy tylko te ceny, które już są podane w zależności od kursu.
-- Inaczej możnaby to zrobić tak, że mamy w Cenach tylko ceny w PLN i dodajemy te w walutach, które są w Kursach.
-- Wtedy powinniśmy robić kursor po Kursach i je insertować.



DROP TABLE IF EXISTS Towary;
GO

DROP TABLE IF EXISTS Ceny;
GO

DROP TABLE IF EXISTS Kursy;
GO

CREATE TABLE Towary
(
    ID INT IDENTITY,
    NazwaTowaru VARCHAR(300),
    CONSTRAINT Towar_PK PRIMARY KEY (ID)
);
GO

CREATE TABLE Kursy
(
    Waluta VARCHAR(300),
    CenaPLN FLOAT,
    CONSTRAINT Kurs_PK PRIMARY KEY (Waluta)
);
GO

CREATE TABLE Ceny
(
    TowarID INT,
    Waluta VARCHAR(300),
    Cena FLOAT,
    CONSTRAINT Cena_Towar_FK FOREIGN KEY (TowarID) REFERENCES Towary (ID) ON DELETE CASCADE,
    CONSTRAINT Cena_Waluta_FK FOREIGN KEY (Waluta) REFERENCES Kursy (Waluta) ON DELETE CASCADE
);
GO

SET IDENTITY_INSERT Towary ON
INSERT INTO Towary
    (ID, NazwaTowaru)
VALUES
    (1, 'ziemniak'),
    (2, 'rower'),
    (3, 'węgiel'),
    (4, 'niewolnik');
SET IDENTITY_INSERT Towary OFF
GO

INSERT INTO Kursy
    (Waluta, CenaPLN)
VALUES
    ('zloty', 1),
    ('dolar', 3.88),
    ('funt', 5.07),
    ('frank', 4.27);
GO

INSERT INTO Ceny
    (TowarID, Waluta, Cena)
VALUES
    (1, 'zloty', 2),
    (1, 'frank', 2),
    (2, 'zloty', 300),
    (2, 'frank', 300),
    (2, 'dolar', 300),
    (2, 'funt', 300),
    (3, 'zloty', 0.5),
    (3, 'frank', 0.5),
    (3, 'dolar', 0.5),
    (3, 'funt', 0.5),
    (4, 'zloty', 1000),
    (4, 'frank', 1000),
    (4, 'dolar', 1000),
    (4, 'funt', 1000);
GO

delete from Kursy where Waluta='funt'

declare c_towary cursor for select ID
from Towary
declare @id int
open c_towary
fetch next from c_towary into @id
while(@@fetch_status = 0)
begin

    declare c_ceny cursor 
for select Waluta
    from Ceny
    where TowarID = @id
    for
    update
    of
    Cena;
    declare @waluta varchar(300), @cena float, @cenapln float
    open c_ceny
    fetch next from c_ceny into @waluta
    while @@fetch_status = 0
begin
        set @cena = (select Cena
        from Ceny
        where TowarID = @id and Waluta='zloty')
        set @cenapln = (select CenaPLN
        from Kursy
        where Waluta = @waluta)

        update Ceny set Cena = @cena * @cenapln where current of c_ceny
        fetch next from c_ceny into @waluta

    end
    close c_ceny
    deallocate c_ceny

    fetch next from c_towary into @id
end
close c_towary
deallocate c_towary

select *
from Ceny