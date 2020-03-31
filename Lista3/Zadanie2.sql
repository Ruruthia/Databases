--Zmieniłam schemat SalaryHistory - rok był niepotrzebny w tak opisanym zadaniu,
--zamiast SalaryNet łatwiej posługiwać się TaxPaid - wartością mówiącą ile podatku zapłacono w danym miesiącu.
--w sumie możnaby dodać jednak SalaryNet w ramach wygody odczytu

DROP TABLE IF EXISTS Employees;
GO

DROP TABLE IF EXISTS SalaryHistory;
GO

DROP TABLE IF EXISTS Logs;
GO

CREATE TABLE Logs
(
    EmployeeID INT,
    ErrorMessage varchar(300)
);
GO

CREATE TABLE Employees
(
    ID INT IDENTITY,
    SalaryGros FLOAT,
    CONSTRAINT Employee_PK PRIMARY KEY (ID)
);
GO

CREATE TABLE SalaryHistory
(
    EmployeeID INT,
    Month INT,
    TaxPaid FLOAT,
    SalaryGros FLOAT
);
GO

SET IDENTITY_INSERT Employees ON
insert into Employees
    (ID, SalaryGros)
values
    (1, 3000),
    (2, 2003.4),
    (3, 4000.75);
SET IDENTITY_INSERT Employees OFF
GO

insert into SalaryHistory
    (EmployeeID, Month, TaxPaid, SalaryGros)
VALUES
    (1, 1, 200, 1000),
    (1, 2, 300, 2000);
GO

DROP PROCEDURE IF EXISTS CountSalary;
GO

CREATE PROCEDURE CountSalary
    @month INT
AS
BEGIN

    declare c_employee cursor for select ID, SalaryGros
    from Employees
    declare @id int, @salary float
    open c_employee
    fetch next from c_employee into @id, @salary
    while @@fetch_status = 0 
  begin
        if (not exists(select *
        from SalaryHistory
        where EmployeeID = @id and Month = @month))
    begin

            declare @sumbrutto float
            declare @currentmonth int, @currenttax float, @currentsalary float
            declare @sumtax float, @taxtopay float, @finaltax float
            declare @errormonth int, @errorlog bit
            set @sumbrutto = 0
            --łącznie zarobiona kwota brutto
            set @currentmonth = 1
            --obecny miesiąc - do pętli while
            set @currenttax = 0
            --podatek zapłacony w danym miesiącu, do inserta dla kursora
            set @currentsalary = 0
            --kwota zarobiona brutto w danym miesiącu, do inserta dla kursora
            set @sumtax = 0
            --łącznie zapłacony podatek      
            set @taxtopay = 0
            -- łączny podatek do zapłacenia w tym roku
            set @finaltax = 0
            -- podatek, który należy zapłacić w @month
            set @errorlog = 0
            --1 w przypadku błędu

            while @currentmonth<@month
    begin
                if(not exists(select *
                from SalaryHistory
                where EmployeeID=@id and Month=@currentmonth))
      begin
                    set @errormonth = @currentmonth
                    set @errorlog = 1
                    break
                end
      else
      begin
                    select @currenttax = TaxPaid, @currentsalary = SalaryGros
                    from SalaryHistory
                    where EmployeeID=@id and Month=@currentmonth;
                    set @sumtax = @sumtax + @currenttax
                    set @sumbrutto = @sumbrutto + @currentsalary
                    set @currentmonth = @currentmonth + 1
                end
            end
            if (@errorlog = 1)
    begin

                insert into Logs
                    (EmployeeID, ErrorMessage)
                values
                    (@id, 'Nie ma obliczonej pensji z miesiaca ' + CAST(@errormonth as varchar(16)));

            end
    else
    begin
                set @sumbrutto = @sumbrutto + @salary
                if (@sumbrutto <= 85528)
    begin
                    set @taxtopay = 0.18 * @sumbrutto
                end
    else
    begin
                    declare @difference float
                    set @difference = @sumbrutto - 85528
                    set @taxtopay = 0.18 * 85528 + 0.32 * @difference
                end
                set @finaltax =  @taxtopay - @sumtax
                insert into SalaryHistory
                    (EmployeeID, Month, TaxPaid, SalaryGros)
                VALUES
                    (@id, @currentmonth, @finaltax, @salary)
            end
        end
        fetch next from c_employee into @id, @salary
    end
    close c_employee
    deallocate c_employee
end

go

exec CountSalary @month=1
go
exec CountSalary @month=2
go
exec CountSalary @month=3
go

select *
from SalaryHistory
select *
from Logs

