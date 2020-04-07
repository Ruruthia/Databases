drop table if exists liczby;
go
create table liczby
(
    id int,
    liczba int
);
go


insert into liczby
    (id, liczba)
values(1, 1);
insert into liczby
    (id, liczba)
values(2, 2);
insert into liczby
    (id, liczba)
values(3, 3);
go

select *
from liczby;

-- set transaction isolation level read uncommitted;
-- set transaction isolation level read committed;
set transaction isolation level repeatable read;
-- set transaction isolation level serializable;
-- set transaction isolation level snapshot;

--Przykład: odczyt "brudnych danych" 
--czyli takich, które zostały zmienione w transakcji która później została wycofana
--Gdzie występuje: read uncommited
--Gdzie nie występuje: read commited, repeatable read, snapshot, serializable

begin transaction
update liczby set liczba = 10 where id = 1
WaitFor Delay '00:00:10'
--Pierwsza transakcja
rollback

select *
from liczby

--Przykład: niepowtarzalność odczytów
--ta sama transakcja daje różne wyniki, bo pomiędzy jej kolejnymi wywołaniami zmieniono zawartość bazy danych
--Gdzie występuje: read uncommited, read commited
--Gdzie nie występuje: repeatable read, snapshot, serializable

begin transaction
select sum(liczba)
from liczby
where id = 3
group by id
commit
WaitFor Delay '00:00:10'
--Druga transakcja
begin transaction
select sum(liczba)
from liczby
where id = 3
group by id
commit


--Przykład: odczyty fantomów
--te same zapytania w obrębie jednej transakcji dają różne wyniki, 
--bo baza została zmieniona pomiędzy tymi zapytaniami
--Gdzie występuje: read uncommited, read commited, repeatable read
--Gdzie nie występuje: snapshot, serializable

delete from liczby
insert into liczby
    (id, liczba)
values(1, 1);
insert into liczby
    (id, liczba)
values(2, 2);
insert into liczby
    (id, liczba)
values(3, 3);
insert into liczby
    (id, liczba)
values(4, 4);
insert into liczby
    (id, liczba)
values(5, 5);
insert into liczby
    (id, liczba)
values(6, 6);
go


begin transaction
select id, liczba
from liczby
where id<5 and id>2;
WaitFor Delay '00:00:10'
--Trzecia transakcja
select id, liczba
from liczby
where id<5 and id>2;

commit