DROP TABLE IF EXISTS Bufor;
GO

DROP TABLE IF EXISTS Historia;
GO

DROP TABLE IF EXISTS Parametry;
GO

drop trigger if exists tr_insert_bufor
go

drop trigger if exists tr_insert_historia
go

CREATE TABLE Bufor
(
  ID INT,
  AdresUrl VARCHAR(300),
  OstatnieWejscie DATETIME
);
GO

CREATE TABLE Historia
(
  ID INT,
  AdresUrl VARCHAR(300),
  OstatnieWejscie DATETIME
);
GO

CREATE TABLE Parametry
(
  Nazwa VARCHAR(300),
  Wartosc INT
);
GO

INSERT INTO Parametry
  (Nazwa, Wartosc)
VALUES
  ('max_cache', 1000),
  ('maksymalny_rozmiar_bufora', 2);
GO

insert into Bufor
  (ID, AdresUrl, OstatnieWejscie)
values
  (1, 'first', '20110618 10:34:09 AM'),
  (2, 'second', '20220618 10:34:09 AM');

go

create trigger tr_insert_bufor on Bufor instead of insert
as
begin

  if exists (select *
  from Bufor b join inserted i on (b.AdresUrl=i.AdresUrl))
 BEGIN
    update Bufor set Bufor.OstatnieWejscie = getdate()
 from inserted i
 where Bufor.AdresUrl = i. AdresUrl
  end
else
begin
    if (select count(DISTINCT ID)
    from Bufor)<(select Wartosc
    from Parametry
    where Nazwa='maksymalny_rozmiar_bufora')
  begin
      insert into Bufor
      select *
      from inserted
    end
  else
  begin
      INSERT INTO Historia
        (ID,AdresUrl, OstatnieWejscie)
      (SELECT TOP 1
        *
      from Bufor
      where OstatnieWejscie = (select MIN(OstatnieWejscie)
      FROM Bufor));
      DELETE TOP (1) FROM Bufor where OstatnieWejscie = (select MIN(OstatnieWejscie)
      FROM Bufor);
    end
  end
end
go

create trigger tr_insert_historia on Historia instead of insert
as
begin
  if exists (select *
  from Historia h join inserted i on (h.AdresUrl=i.AdresUrl))
 BEGIN
    update Historia set Historia.OstatnieWejscie = i.OstatnieWejscie
 from inserted i
 where Historia.AdresUrl = i. AdresUrl
  end
 else
 insert into Historia
  select *
  from inserted
end
go


insert into Bufor
  (ID, AdresUrl, OstatnieWejscie)
values
  (3, 'third', '20330618 10:34:09 AM');

select *
from Bufor
go

select *
from Historia
go

insert into Bufor
  (ID, AdresUrl, OstatnieWejscie)
values
  (4, 'first', '20440618 10:34:09 AM');

go

select *
from Bufor
go

select *
from Historia
go

insert into Bufor
  (ID, AdresUrl, OstatnieWejscie)
values
  (5, 'fifth', '20550618 10:34:09 AM');

go

select *
from Bufor
go

select *
from Historia
go

insert into Bufor
  (ID, AdresUrl, OstatnieWejscie)
values
  (6, 'sixth', '20660618 10:34:09 AM');

go

select *
from Bufor
go

select *
from Historia
go

insert into Bufor
  (ID, AdresUrl, OstatnieWejscie)
values
  (7, 'seventh', '20770618 10:34:09 AM');

go

select *
from Bufor
go

select *
from Historia
go