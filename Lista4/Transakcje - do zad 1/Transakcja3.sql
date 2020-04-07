-- set transaction isolation level read uncommitted;
-- set transaction isolation level read committed;
-- set transaction isolation level repeatable read;
-- set transaction isolation level serializable;
-- set transaction isolation level snapshot;

--Trzecia transakcja
begin transaction
update liczby set id = 10 where liczba = 3
commit
