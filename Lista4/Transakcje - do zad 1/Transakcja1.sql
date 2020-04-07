-- set transaction isolation level read uncommitted;
-- set transaction isolation level read committed;
-- set transaction isolation level repeatable read;
-- set transaction isolation level serializable;
-- set transaction isolation level snapshot;

--Pierwsza transakcja
begin transaction
select liczba from liczby where id = 1
commit