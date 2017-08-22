----LAB 1: Introduction to Transact-SQL
-- CAST datatype
SELECT CAST(CustomerID AS VARCHAR) + ': ' + CompanyName AS CustomerCompany
	FROM SalesLT.Customer;

-- CONVERT DateTime format
SELECT SalesOrderNumber + ' (' + STR(RevisionNumber, 1) + ')' AS OrderRevision, CONVERT(NVARCHAR(30), OrderDate, 102) AS OrderDate
	FROM SalesLT.SalesOrderHeader;

-- use ISNULL to check for middle names and concatenate with FirstName and LastName
SELECT FirstName + ' ' + ISNULL(MiddleName+ ' ', '') + LastName
	AS CustomerName
	FROM SalesLT.Customer;

-- select the CustomerID, and use COALESCE with EmailAddress and Phone columns
-- PrimaryContact contains the email address if known, and otherwise the phone number.
SELECT CustomerID, COALESCE(EmailAddress, Phone) AS PrimaryCOntact 
	FROM SalesLT.Customer;

-- Switch Cases
SELECT SalesOrderID, OrderDate,
  CASE
    WHEN ShipDate IS NULL THEN 'Awaiting Shipment'
    ELSE 'Shipped'
  END 
  AS ShippingStatus
	FROM SalesLT.SalesOrderHeader;


----LAB 2: Querying Tables with SELECT
-- select unique cities, and state province 
SELECT DISTINCT City, StateProvince
	FROM SalesLT.Address;

-- select the top 10 percent from the Name column
SELECT TOP 10 Percent Name
	FROM SalesLT.Product
	-- order by the weight in descending order
	order by Weight desc;

-- offset 10 rows and get the next 100
SELECT Name
	FROM SalesLT.Product
	ORDER BY Weight DESC
	OFFSET 10 ROWS FETCH NEXT 100 ROWS ONLY;

-- check that Color is one of 'Black', 'Red' or 'White'
-- check that Size is one of 'S' or 'M'
SELECT ProductNumber, Name
	FROM SalesLT.Product
	WHERE COLOR IN ('Black','Red','White') AND Size IN ('S','M');

-- filter for product numbers beginning with BK- using LIKE
SELECT ProductNumber, Name, ListPrice
	FROM SalesLT.Product
	WHERE ProductNumber LIKE 'BK-%';

-- filter for ProductNumbers
SELECT ProductNumber, Name, ListPrice
	FROM SalesLT.Product
	WHERE ProductNumber LIKE 'BK-[^R]%-[0-9][0-9]'; -- ex. FR-R92B-58

----Lab 3: Querying Multiple Tables with Joins
-- join tables based on CustomerID
SELECT c.CompanyName, oh.SalesOrderId, oh.TotalDue
	FROM SalesLT.Customer AS c
	JOIN SalesLT.SalesOrderHeader AS oh
	ON c.CustomerID = oh.CustomerID;

-- add parameter to join statement
SELECT c.CompanyName, a.AddressLine1, ISNULL(a.AddressLine2, '') AS AddressLine2, a.City, a.StateProvince, a.PostalCode, a.CountryRegion, oh.SalesOrderID, oh.TotalDue
	JOIN SalesLT.SalesOrderHeader AS oh
	ON oh.CustomerID = c.CustomerID
	JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID AND AddressType = 'Main Office'
	JOIN SalesLT.Address AS a
	ON ca.AddressID = a.AddressID;

-- all customers plus matching SalesOrderHeader
SELECT c.CompanyName, c.FirstName, c.LastName, oh.SalesOrderID, oh.TotalDue
	FROM SalesLT.Customer AS c
	LEFT JOIN SalesLT.SalesOrderHeader AS oh
	ON c.CustomerID = oh.CustomerID
	ORDER BY oh.SalesOrderID DESC;

-- join based on CustomerID
-- filter for when the AddressID doesn't exist 
SELECT c.CompanyName, c.FirstName, c.LastName, c.Phone
	FROM SalesLT.Customer AS c
	LEFT JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	WHERE ca.AddressID IS NULL;

-- join based on the SalesOrderID
-- join based on the ProductID
-- filter for nonexistent SalesOrderIDs
SELECT c.CustomerID, p.ProductID
	FROM SalesLT.Customer AS c
	FULL JOIN SalesLT.SalesOrderHeader AS oh
	ON c.CustomerID = oh.CustomerID
	FULL JOIN SalesLT.SalesOrderDetail AS od
	ON od.SalesOrderID = oh.SalesOrderID
	FULL JOIN SalesLT.Product AS p
	ON p.ProductID = od.ProductID
	WHERE oh.SalesOrderID IS NULL
	ORDER BY ProductID, CustomerID;

---- Lab 4: Using Set Operators
-- select the CompanyName, AddressLine1 columns
-- column named AddressType with the value 'Billing' for customers where the address type in the SalesLT.CustomerAddress table is 'Main Office'. 
SELECT c.CompanyName, a.AddressLine1, a.City, 'Billing' AS AddressType
	FROM SalesLT.Customer AS c
	JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN SalesLT.Address AS a
	ON a.AddressID = ca.AddressID
	WHERE AddressType = 'Main Office';

-- column named AddressType with the value 'Shipping' for customers where the address type in the SalesLT.CustomerAddress table is 'Shipping'
SELECT c.CompanyName, a.AddressLine1, a.City, 'Shipping' AS AddressType
	FROM SalesLT.Customer AS c
	JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN SalesLT.Address AS a
	ON ca.AddressID = a.AddressID
	WHERE ca.AddressType = 'Shipping';

-- Combine two previous queries
SELECT c.CompanyName, a.AddressLine1, a.City, 'Billing' AS AddressType
	FROM SalesLT.Customer AS c
	JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN SalesLT.Address AS a
	ON ca.AddressID = a.AddressID
	WHERE ca.AddressType = 'Main Office'

	UNION ALL

	SELECT c.CompanyName, a.AddressLine1, a.City, 'Shipping' AS AddressType
		FROM SalesLT.Customer AS c
		JOIN SalesLT.CustomerAddress AS ca
		ON c.CustomerID = ca.CustomerID
		JOIN SalesLT.Address AS a
		ON ca.AddressID = a.AddressID
		WHERE ca.AddressType = 'Shipping'
		ORDER BY c.CompanyName, AddressType;

-- returns the company name of each company that appears in a table of customers with a 'Main Office' address, but not in a table of customers with a 'Shipping' address.
SELECT c.CompanyName
	FROM SalesLT.Customer AS c
	JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN SalesLT.Address AS a
	ON a.AddressID = ca.AddressID
	WHERE ca.AddressType = 'Main Office'
	EXCEPT
	SELECT c.CompanyName
		FROM SalesLT.Customer AS c
		JOIN SalesLT.CustomerAddress AS ca
		ON c.CustomerID = ca.CustomerID
		JOIN SalesLT.Address AS a
		ON ca.AddressID = a.AddressID
		WHERE ca.AddressType = 'Shipping'
		ORDER BY c.CompanyName;

--  returns the company name of each company that appears in a table of customers with a 'Main Office' address, and also in a table of customers with a 'Shipping' address
SELECT c.CompanyName
	FROM SalesLT.Customer AS c
	JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN SalesLT.Address AS a
	ON a.AddressID = ca.AddressID
	WHERE ca.AddressType = 'Main Office'
	INTERSECT
	SELECT c.CompanyName
		FROM SalesLT.Customer AS c
		JOIN SalesLT.CustomerAddress AS ca
		ON c.CustomerID = ca.CustomerID
		JOIN SalesLT.Address AS a
		ON a.AddressID = ca.AddressID
		WHERE ca.AddressType = 'Shipping'
		ORDER BY c.CompanyName;

---- Lab 5: Using Functions and Aggregating Data
-- Round Value
SELECT ProductID, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight
	FROM SalesLT.Product;

-- Date Details
SELECT ProductID, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight,
		-- get the year of the SellStartDate
		YEAR(SellStartDate) as SellStartYear, 
		-- get the month datepart of the SellStartDate
		DATENAME(m, SellStartDate) as SellStartMonth
	FROM SalesLT.Product;

-- substring selection
SELECT ProductID, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight,
		YEAR(SellStartDate) as SellStartYear, 
		DATENAME(m, SellStartDate) as SellStartMonth,
		-- use the appropriate function to extract substring from ProductNumber
		LEFT(ProductNumber,2) AS ProductType
	FROM SalesLT.Product;

-- check dtype of column
SELECT ProductID, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight,
		YEAR(SellStartDate) as SellStartYear, 
		DATENAME(m, SellStartDate) as SellStartMonth,
		LEFT(ProductNumber, 2) AS ProductType
	FROM SalesLT.Product
	-- filter for numeric product size data
	WHERE ISNUMERIC(Size) = 1;

-- select and create ranking 
SELECT C.CompanyName, SOH.TotalDue AS Revenue,
		-- get ranking and order by appropriate column
		RANK() OVER (ORDER BY SOH.TotalDue DESC) AS RankByRevenue
		FROM SalesLT.SalesOrderHeader AS SOH
	JOIN SalesLT.Customer AS C
	ON SOH.CustomerID = C.CustomerID;

-- HAVING for filter groups
SELECT Name, SUM(LineTotal) AS TotalRevenue
	FROM SalesLT.SalesOrderDetail AS SOD
	JOIN SalesLT.Product AS P 
	ON SOD.ProductID = P.ProductID
	WHERE P.ListPrice > 1000
	GROUP BY P.Name
	-- add having clause
	HAVING SUM(LineTotal)>20000
	ORDER BY TotalRevenue DESC;

---- Lab 6: Using Subqueries and APPLY
-- select the ProductID, Name, and ListPrice columns
SELECT ProductID, Name, ListPrice
	FROM SalesLT.Product
	-- filter based on ListPrice
	WHERE ListPrice > 
	-- get the average UnitPrice
	(SELECT AVG(UnitPrice) FROM SalesLT.SalesOrderDetail)
	ORDER BY ProductID;

-- select each product where the list price is 100 or more, and the product has been sold for (strictly) less than 100
SELECT ProductID, Name, ListPrice
	FROM SalesLT.Product
	WHERE ProductID IN
	  -- select ProductID from the appropriate table
	  (SELECT ProductID FROM SalesLT.SalesOrderDetail
	   WHERE UnitPrice < 100)
	AND ListPrice >= 100
	ORDER BY ProductID;

-- Retrieve product info and average price per product
SELECT ProductID, Name, StandardCost, ListPrice,
	-- get the average UnitPrice
	(SELECT AVG(UnitPrice)
	 -- from the appropriate table, aliased as SOD
	 FROM SalesLT.SalesOrderDetail AS SOD
	 -- filter when the appropriate ProductIDs are equal
	 WHERE P.ProductID = SOD.ProductID) AS AvgSellingPrice
	FROM SalesLT.Product AS P
	ORDER BY P.ProductID;

-- Retrieve previous results but include only products where the cost is higher than the average selling price
SELECT ProductID, Name, StandardCost, ListPrice,
	(SELECT AVG(UnitPrice)
	 FROM SalesLT.SalesOrderDetail AS SOD
	 WHERE P.ProductID = SOD.ProductID) AS AvgSellingPrice
	FROM SalesLT.Product AS P
	-- filter based on StandardCost
	WHERE StandardCost >
	-- get the average UnitPrice
	(SELECT AVG(UnitPrice)
	 -- from the appropriate table aliased as SOD
	 FROM SalesLT.SalesOrderDetail AS SOD
	 -- filter when the appropriate ProductIDs are equal
	 WHERE P.ProductID = SOD.ProductID)
	ORDER BY P.ProductID;

-- selection with CROSS APPLY function
SELECT SOH.SalesOrderID,SOH.CustomerID,CI.FirstName,CI.LastName,SOH.TotalDue
	FROM SalesLT.SalesOrderHeader AS SOH
	-- cross apply as per the instructions
	CROSS APPLY dbo.ufnGetCustomerInformation(SOH.CustomerID) AS CI
	ORDER BY SOH.SalesOrderID;

-- -- selection with JOIN and CROSS APPLY function
SELECT CA.CustomerID, CI.FirstName, CI.LastName, A.AddressLine1, A.City
	FROM SalesLT.Address AS A
	JOIN SalesLT.CustomerAddress AS CA
	-- join based on AddressID
	ON A.AddressID = CA.AddressID
	-- cross apply as per instructions
	CROSS APPLY dbo.ufnGetCustomerInformation(CA.CustomerID) AS CI
	ORDER BY CA.CustomerID;

---- Lab 7: Using Table Expressions
-- Table Variable
DECLARE @Colors AS table (Color NVARCHAR(15));

INSERT INTO @Colors
SELECT DISTINCT Color FROM SalesLT.Product;

SELECT ProductID, Name, Color
FROM SalesLT.Product
WHERE Color IN (SELECT Color FROM @Colors);

-- Table-Valued Function
SELECT C.ParentProductCategoryName AS ParentCategory,
       C.ProductCategoryName AS Category,
       P.ProductID, P.Name AS ProductName
	FROM SalesLT.Product AS P
	JOIN dbo.ufnGetAllCategories() AS C --table-valued function
	ON P.ProductCategoryID = C.ProductCategoryID
	ORDER BY ParentCategory, Category, ProductName;

-- derived table or a common table expression
SELECT CompanyContact, SUM(SalesAmount) AS Revenue
	FROM
		(SELECT CONCAT(c.CompanyName, CONCAT(' (' + c.FirstName + ' ', c.LastName + ')')), SOH.TotalDue
		 FROM SalesLT.SalesOrderHeader AS SOH
		 JOIN SalesLT.Customer AS c
		 ON SOH.CustomerID = c.CustomerID) AS CustomerSales(CompanyContact, SalesAmount)
	GROUP BY CompanyContact
	ORDER BY CompanyContact;

---- Lab 8: Grouping Sets and Pivoting Data
-- Rollups of all locations, Countries, Country+State
SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
	FROM SalesLT.Address AS a
	JOIN SalesLT.CustomerAddress AS ca
	ON a.AddressID = ca.AddressID
	JOIN SalesLT.Customer AS c
	ON ca.CustomerID = c.CustomerID
	JOIN SalesLT.SalesOrderHeader as soh
	ON c.CustomerID = soh.CustomerID
	-- Modify GROUP BY to use ROLLUP
	GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
	ORDER BY a.CountryRegion, a.StateProvince;

-- Add label indicating rollup level
SELECT a.CountryRegion, a.StateProvince,
	IIF(GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1, 'Total', IIF(GROUPING_ID(a.CountryRegion,a.StateProvince) = 1, a.CountryRegion + ' Subtotal', a.StateProvince + ' Subtotal')) AS Level,
	SUM(soh.TotalDue) AS Revenue
	FROM SalesLT.Address AS a
	JOIN SalesLT.CustomerAddress AS ca
	ON a.AddressID = ca.AddressID
	JOIN SalesLT.Customer AS c
	ON ca.CustomerID = c.CustomerID
	JOIN SalesLT.SalesOrderHeader as soh
	ON c.CustomerID = soh.CustomerID
	GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
	ORDER BY a.CountryRegion, a.StateProvince;

-- Add city-level to previous query
SELECT a.CountryRegion, a.StateProvince, a.City,
	CHOOSE (1 + GROUPING_ID(a.City) + GROUPING_ID(a.StateProvince) + GROUPING_ID(a.CountryRegion),
	        a.City + ' Subtotal', a.StateProvince + ' Subtotal',
	        a.CountryRegion + ' Subtotal', 'Total') AS Level,
	SUM(soh.TotalDue) AS Revenue
	FROM SalesLT.Address AS a
	JOIN SalesLT.CustomerAddress AS ca
	ON a.AddressID = ca.AddressID
	JOIN SalesLT.Customer AS c
	ON ca.CustomerID = c.CustomerID
	JOIN SalesLT.SalesOrderHeader as soh
	ON c.CustomerID = soh.CustomerID
	GROUP BY ROLLUP(a.CountryRegion, a.StateProvince, a.City)
	ORDER BY a.CountryRegion, a.StateProvince, a.City;

-- PIVOT
SELECT * FROM
	(SELECT cat.ParentProductCategoryName, sod.LineTotal, cust.CompanyName
	 FROM SalesLT.SalesOrderDetail AS sod
	 JOIN SalesLT.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
	 JOIN SalesLT.Customer AS cust ON cust.CustomerID = soh.CustomerID
	 JOIN SalesLT.Product AS prod ON prod.ProductID = sod.ProductID
	 JOIN SalesLT.vGetAllCategories AS cat ON prod.ProductcategoryID = cat.ProductCategoryID) AS catsales
	PIVOT (SUM(LineTotal) FOR ParentProductCategoryName
	IN ([Accessories], [Bikes], [Clothing], [Components])) AS pivotedsales
	ORDER BY CompanyName;

---- Lab 9: Modifying Data
-- Insert data
INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES
('LED Lights','LT-L123',2.56,12.99,37,getdate());

-- Get last identity value that was inserted
SELECT SCOPE_IDENTITY();

-- Finish the SELECT statement
SELECT * FROM SalesLT.Product
WHERE ProductID = SCOPE_IDENTITY();


-- Insert product category
INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name)
VALUES
(4, 'Bells and Horns');

-- Insert 2 products
INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost,ListPrice,ProductCategoryID,SellStartDate)
VALUES
('Bicycle Bell', 'BB-RING', 2.47, 4.99, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE()),
('Bicycle Horn', 'BB-PARP', 1.29, 3.75, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE());

-- Check if products are properly inserted
SELECT c.Name As Category, p.Name AS Product
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory as c ON p.ProductCategoryID = c.ProductCategoryID
WHERE p.ProductCategoryID = IDENT_CURRENT('SalesLT.ProductCategory');

-- Update table column values
UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductCategoryID =
  (SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns');

-- Update value with current date
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductCategoryID = 37 AND ProductNumber <> 'LT-L123';


-- Delete records from the SalesLT.Product table
DELETE FROM SalesLT.Product
WHERE ProductCategoryID =
	(SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns');

-- Delete records from the SalesLT.ProductCategory table
DELETE FROM SalesLT.ProductCategory
WHERE ProductCategoryID =
	(SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns');

---- Lab 10: Programming with Transact-SQL
-- Using variables
DECLARE @OrderDate datetime = GETDATE();
DECLARE @DueDate datetime = DATEADD(dd, 7, GETDATE());
DECLARE @CustomerID int = 1;

INSERT INTO SalesLT.SalesOrderHeader (OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5');

PRINT SCOPE_IDENTITY();


-- if there is a SalesOrderDetail with a SalesOrderID==OrderID get order details
DECLARE @OrderDate datetime = GETDATE();
DECLARE @DueDate datetime = DATEADD(dd, 7, GETDATE());
DECLARE @CustomerID int = 1;
INSERT INTO SalesLT.SalesOrderHeader (OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5');
DECLARE @OrderID int = SCOPE_IDENTITY();

DECLARE @ProductID int = 760;
DECLARE @Quantity int = 1;
DECLARE @UnitPrice money = 782.99;

IF SCOPE_IDENTITY() (SELECT * FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = OrderID)
BEGIN
	INSERT INTO SalesLT.SalesOrderDetail (OrderID, OrderQty, ProductID, UnitPrice)
	VALUES (@OrderID, @Quantity, @ProductID, @UnitPrice)
END
ELSE
BEGIN
	PRINT 'The order does not exist'
END

-- WHILE loop example
DECLARE @MarketAverage money = 2000;
DECLARE @MarketMax money = 5000;
DECLARE @AWMax money;
DECLARE @AWAverage money;

SELECT @AWAverage = AVG(ListPrice), @AWMax = MAX(ListPrice)
FROM SalesLT.Product
WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

WHILE @AWAverage < @MarketAverage
BEGIN
   UPDATE SalesLT.Product
   SET ListPrice = ListPrice * 1.1
   WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

	SELECT @AWAverage = AVG(ListPrice), @AWMax = MAX(ListPrice)
	FROM SalesLT.Product
	WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

   IF @AWMax >= @MarketMax
      BREAK
   ELSE
      CONTINUE
END

PRINT 'New average bike price:' + CONVERT(VARCHAR, @AWAverage);
PRINT 'New maximum bike price:' + CONVERT(VARCHAR, @AWMax);

---- Lab 11: Error Handling and Transactions

-- Custom ERROR message
DECLARE @OrderID int = 0
-- Declare a custom error if the specified order doesn't exist
DECLARE @error VARCHAR(25) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

IF NOT NULL (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
BEGIN
  THROW 50001, @error, 0;
END
ELSE
BEGIN
  DELETE FROM SalesLT.SalesOrderDetail WHERE OrderID = @OrderID;
  DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID;
END


-- TRY and CATCH Examples
DECLARE @OrderID int = 71774
DECLARE @error VARCHAR(25) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

-- Wrap IF ELSE in a TRY block
BEGIN TRY
  IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
  BEGIN
    THROW 50001, @error, 0
  END
  ELSE
  BEGIN
    DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @OrderID;
    DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID;
  END
END TRY
-- Add a CATCH block to print out the error
BEGIN CATCH
  PRINT ERROR_MESSAGE();
END CATCH


-- Transactional checks
DECLARE @OrderID int = 0
DECLARE @error VARCHAR(25) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

BEGIN TRY
  IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
  BEGIN
    THROW 50001, @error, 0
  END
  ELSE
  BEGIN
    BEGIN TRANSACTION
    DELETE FROM SalesLT.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
    DELETE FROM SalesLT.SalesOrderHeader
    WHERE SalesOrderID = @OrderID;
    COMMIT TRANSACTION
  END
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
  BEGIN
    ROLLBACK TRANSACTION;
  END
  ELSE
  BEGIN
    PRINT ERROR_MESSAGE();
  END
END CATCH