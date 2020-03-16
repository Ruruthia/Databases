-- Zadanie 1

SELECT DISTINCT a.City FROM [SalesLT].[SalesOrderHeader] h, [SalesLT].[Address] a
WHERE h.ShipDate<CURRENT_TIMESTAMP AND a.AddressID=h.ShipToAddressID ORDER BY City

--Zadanie 2

SELECT m.Name, COUNT(p.ProductID) FROM [SalesLT].[ProductModel] m JOIN [SalesLT].[Product] p
ON p.ProductModelID=m.ProductModelID GROUP BY m.Name HAVING COUNT(p.ProductID)>1

--Zadanie 3

SELECT a.City, COUNT(a.AddressID) as "Liczba klientów", COUNT(DISTINCT c.SalesPerson) as "Liczba SalesPerson" FROM [SalesLT].[Address] a
JOIN [SalesLT].[CustomerAddress] ca ON ca.AddressID = a.AddressID
JOIN [SalesLT].[Customer] c ON c.CustomerID = ca.CustomerID
GROUP BY a.City

--TEST

SELECT c.FirstName as "Name", c.SalesPerson as "Salesperson" FROM [SalesLT].[Customer] c
JOIN [SalesLT].[CustomerAddress] ca ON c.CustomerID = ca.CustomerID
JOIN [SalesLT].[Address] a ON  ca.AddressID = a.AddressID
WHERE a.City = 'Calgary'

--Zadanie 4


UPDATE [SalesLT].[Product] SET ProductCategoryID = 3 WHERE ProductID = 680;
UPDATE [SalesLT].[Product] SET ProductCategoryID = 3 WHERE ProductID = 706;
UPDATE [SalesLT].[Product] SET ProductCategoryID = 3 WHERE ProductID = 707;
UPDATE [SalesLT].[Product] SET ProductCategoryID = 2 WHERE ProductID = 708;
UPDATE [SalesLT].[Product] SET ProductCategoryID = 1 WHERE ProductID = 709;
UPDATE [SalesLT].[Product] SET ProductCategoryID = 1 WHERE ProductID = 710;
SELECT * FROM [SalesLT].[Product]

SELECT parents.Name as "Category Name", products.Name as "Product Name"
FROM [SalesLT].[ProductCategory] parents
JOIN [SalesLT].[Product] products ON products.ProductCategoryID = parents.ProductCategoryID
WHERE EXISTS (SELECT * FROM [SalesLT].[ProductCategory] sons WHERE sons.ParentProductCategoryID=parents.ProductCategoryID)


--Zadanie 5
SELECT c.FirstName as "Name", c.LastName as "Lastname", SUM(od.UnitPriceDiscount*od.OrderQty) as "Saved" FROM [SalesLT].[Customer] c
JOIN [SalesLT].[SalesOrderHeader] oh ON c.CustomerID=oh.CustomerID
JOIN [SalesLT].[SalesOrderDetail] od ON oh.SalesOrderID = od.SalesOrderID
GROUP BY c.FirstName, c.LastName

--TEST
SELECT od.UnitPriceDiscount as "Discount for unit", od.OrderQty as "Quantity" FROM [SalesLT].[SalesOrderDetail] od
JOIN [SalesLT].[SalesOrderHeader] oh ON oh.SalesOrderID = od.SalesOrderID
JOIN [SalesLT].[Customer] c ON c.CustomerID=oh.CustomerID
WHERE c.FirstName='Frank' AND od.UnitPriceDiscount>0


--0.8

SELECT od.UnitPriceDiscount as "Discount for unit", od.OrderQty as "Quantity" FROM [SalesLT].[SalesOrderDetail] od
JOIN [SalesLT].[SalesOrderHeader] oh ON oh.SalesOrderID = od.SalesOrderID
JOIN [SalesLT].[Customer] c ON c.CustomerID=oh.CustomerID
WHERE c.FirstName='Kevin' AND od.UnitPriceDiscount>0


--5.77

SELECT od.UnitPriceDiscount as "Discount for unit", od.OrderQty as "Quantity" FROM [SalesLT].[SalesOrderDetail] od
JOIN [SalesLT].[SalesOrderHeader] oh ON oh.SalesOrderID = od.SalesOrderID
JOIN [SalesLT].[Customer] c ON c.CustomerID=oh.CustomerID
WHERE c.FirstName='Melissa' AND od.UnitPriceDiscount>0

--0.0


--Zadanie 6


UPDATE [SalesLT].[SalesOrderHeader] SET status = 3, DueDate = CAST('2009-05-25' AS DATETIME)  WHERE SalesOrderID = 71774;
UPDATE [SalesLT].[SalesOrderHeader] SET status = 3, DueDate = CAST('2039-05-25' AS DATETIME) WHERE SalesOrderID = 71784;

DROP TABLE IF EXISTS OrdersToProcess;

CREATE TABLE OrdersToProcess
( SalesOrderID INT,
  Delayed BIT
);
GO


MERGE OrdersToProcess AS op
USING (SELECT SalesOrderID, Status, DueDate FROM [SalesLT].[SalesOrderHeader]) AS oh
ON op.SalesOrderID = oh.SalesOrderID
WHEN MATCHED AND oh.Status=5 THEN DELETE
WHEN MATCHED AND oh.DueDate<CURRENT_TIMESTAMP THEN UPDATE SET op.Delayed = 1
WHEN NOT MATCHED AND oh.Status<5 THEN
  INSERT(SalesOrderID, Delayed)
  VALUES(oh.SalesOrderID, 0);
GO

SELECT * FROM OrdersToProcess


--Zadanie 7

ALTER TABLE [SalesLT].[Customer] DROP COLUMN CreditCardNumber
ALTER TABLE [SalesLT].[Customer] ADD CreditCardNumber INT NOT NULL
CONSTRAINT MyConstraint CHECK(CreditCardNumber<=100 AND CreditCardNumber>0) DEFAULT(5);
UPDATE [SalesLT].[Customer] SET CreditCardNumber = 120 WHERE CustomerID = 1;
SELECT * FROM [SalesLT].[Customer]
