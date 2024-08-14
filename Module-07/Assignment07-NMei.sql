--*************************************************************************--
-- Title: Assignment07
-- Author: NMei
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,NMei,Created File
--**************************************************************************--
Begin TRY
	USE Master;
	IF EXISTS(SELECT Name
FROM SysDatabases
WHERE Name = 'Assignment07DB_NMei')
	 BEGIN
	ALTER DATABASE "Assignment07DB_NMei" SET Single_user WITH ROLLBACK Immediate;
	DROP DATABASE Assignment07DB_NMei;
END
	CREATE DATABASE Assignment07DB_NMei;
End Try
Begin CATCH
	PRINT Error_Number();
End CATCH
GO
USE Assignment07DB_NMei;

-- Create Tables (Module 01)-- 
CREATE TABLE Categories
(
	"CategoryID" "int" IDENTITY(1,1) NOT NULL 
,
	"CategoryName" "nvarchar"(100) NOT NULL
);
GO

CREATE TABLE Products
(
	"ProductID" "int" IDENTITY(1,1) NOT NULL 
,
	"ProductName" "nvarchar"(100) NOT NULL 
,
	"CategoryID" "int" NULL  
,
	"UnitPrice" "money" NOT NULL
);
GO

CREATE TABLE Employees -- New Table
(
	"EmployeeID" "int" IDENTITY(1,1) NOT NULL 
,
	"EmployeeFirstName" "nvarchar"(100) NOT NULL
,
	"EmployeeLastName" "nvarchar"(100) NOT NULL 
,
	"ManagerID" "int" NULL
);
GO

CREATE TABLE Inventories
(
	"InventoryID" "int" IDENTITY(1,1) NOT NULL
,
	"InventoryDate" "date" NOT NULL
,
	"EmployeeID" "int" NOT NULL
,
	"ProductID" "int" NOT NULL
,
	"ReorderLevel" int NOT NULL -- New Column 
,
	"Count" "int" NOT NULL
);
GO

-- Add Constraints (Module 02) -- 
BEGIN
	-- Categories
	ALTER TABLE Categories 
	 ADD CONSTRAINT pkCategories 
	  PRIMARY KEY (CategoryId);

	ALTER TABLE Categories 
	 ADD CONSTRAINT ukCategories 
	  UNIQUE (CategoryName);
END
GO

BEGIN
	-- Products
	ALTER TABLE Products 
	 ADD CONSTRAINT pkProducts 
	  PRIMARY KEY (ProductId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ukProducts 
	  UNIQUE (ProductName);

	ALTER TABLE Products 
	 ADD CONSTRAINT fkProductsToCategories 
	  FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ckProductUnitPriceZeroOrHigher 
	  CHECK (UnitPrice >= 0);
END
GO

BEGIN
	-- Employees
	ALTER TABLE Employees
	 ADD CONSTRAINT pkEmployees 
	  PRIMARY KEY (EmployeeId);

	ALTER TABLE Employees 
	 ADD CONSTRAINT fkEmployeesToEmployeesManager 
	  FOREIGN KEY (ManagerId) REFERENCES Employees(EmployeeId);
END
GO

BEGIN
	-- Inventories
	ALTER TABLE Inventories 
	 ADD CONSTRAINT pkInventories 
	  PRIMARY KEY (InventoryId);

	ALTER TABLE Inventories
	 ADD CONSTRAINT dfInventoryDate
	  DEFAULT GetDate() FOR InventoryDate;

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToProducts
	  FOREIGN KEY (ProductId) REFERENCES Products(ProductId);

	ALTER TABLE Inventories 
	 ADD CONSTRAINT ckInventoryCountZeroOrHigher 
	  CHECK ("Count" >= 0);

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToEmployees
	  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId);
END 
GO

-- Adding Data (Module 04) -- 
INSERT INTO Categories
	(CategoryName)
SELECT CategoryName
FROM Northwind.dbo.Categories
ORDER BY CategoryID;
GO

INSERT INTO Products
	(ProductName, CategoryID, UnitPrice)
SELECT ProductName, CategoryID, UnitPrice
FROM Northwind.dbo.Products
ORDER BY ProductID;
GO

INSERT INTO Employees
	(EmployeeFirstName, EmployeeLastName, ManagerID)
SELECT E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID)
FROM Northwind.dbo.Employees AS E
ORDER BY E.EmployeeID;
GO

INSERT INTO Inventories
	(InventoryDate, EmployeeID, ProductID, "Count", "ReorderLevel")
-- New column added this week
	SELECT '20170101' AS InventoryDate, 5 AS EmployeeID, ProductID, UnitsInStock, ReorderLevel
	FROM Northwind.dbo.Products
UNION
	SELECT '20170201' AS InventoryDate, 7 AS EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel
	-- Using this is to create a made up value
	FROM Northwind.dbo.Products
UNION
	SELECT '20170301' AS InventoryDate, 9 AS EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel
	-- Using this is to create a made up value
	FROM Northwind.dbo.Products
ORDER BY 1, 2
GO


-- Adding Views (Module 06) -- 
CREATE VIEW vCategories
WITH
	SchemaBinding
AS
	SELECT CategoryID, CategoryName
	FROM dbo.Categories;
GO
CREATE VIEW vProducts
WITH
	SchemaBinding
AS
	SELECT ProductID, ProductName, CategoryID, UnitPrice
	FROM dbo.Products;
GO
CREATE VIEW vEmployees
WITH
	SchemaBinding
AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM dbo.Employees;
GO
CREATE VIEW vInventories
WITH
	SchemaBinding
AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, "Count"
	FROM dbo.Inventories;
GO

-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT *
FROM vCategories;
GO
SELECT *
FROM vProducts;
GO
SELECT *
FROM vEmployees;
GO
SELECT *
FROM vInventories;
GO

/********************************* Questions and Answers *********************************/
PRINT
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- Let's first look at the columns for the vProducts view again
/*
SELECT * FROM vProducts;
GO
*/

-- We want to SELECT the "ProductName" and "UnitPrice" columnsAND we need to format the "UnitPrice" in US Dollars
-- We want to use the "Currency" format as described in:
--     https://learn.microsoft.com/en-us/sql/t-sql/functions/format-transact-sql?view=sql-server-ver15#c-format-with-numeric-types
/*
SELECT P.ProductName, FORMAT(P.UnitPrice, 'C', 'en-us') AS UnitPrice
FROM vProducts AS P;
GO
*/

-- Finally, also need to order by ProductName
SELECT P.ProductName, FORMAT(P.UnitPrice, 'C', 'en-us') AS UnitPrice
FROM vProducts AS P
ORDER BY P.ProductName;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- Since we explored the vProducts view in Question 1 we know that there is a "CategoryID"
-- column that we can use to JOIN the vCategories view
/*
SELECT C.CategoryName, P.ProductName, FORMAT(P.UnitPrice, 'C', 'en-us') AS UnitPrice
FROM vProducts AS P
JOIN vCategories AS C ON C.CategoryID = P.CategoryID;
GO
*/

-- Finally, we need to ORDER BY CategoryName and ProductName
SELECT C.CategoryName, P.ProductName, FORMAT(P.UnitPrice, 'C', 'en-us') AS UnitPrice
FROM vProducts AS P
	JOIN vCategories AS C ON C.CategoryID = P.CategoryID
ORDER BY C.CategoryName, P.ProductName;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- We've already explored the vProducts view in Question 1 & 2 so let's take a look at vInventories
/*
SELECT * FROM vInventories;
GO
*/

-- Let's start by JOINing the vProducts and vInventories views to get "ProductName", "InventoryDate", and "Count"
/*
SELECT P.ProductName, I.InventoryDate, I."Count"
FROM vInventories AS I
JOIN vProducts AS P ON P.ProductID = I.ProductID;
GO
*/

-- Now we need to convert our numerical month to a month name
-- Let's try using DATENAME: https://learn.microsoft.com/en-us/sql/t-sql/functions/datename-transact-sql?view=sql-server-ver16
/*
SELECT P.ProductName, DATENAME(month, I.InventoryDate) + ', ' + DATENAME(year, I.InventoryDate) AS InventoryDate, I."Count"
FROM vInventories AS I
JOIN vProducts AS P ON P.ProductID = I.ProductID;
GO
*/

-- A better way to accomplish the conversion would be to use FORMAT though so let's use that instead
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/format-transact-sql?view=sql-server-ver16
-- Also had to refer to this to determine the proper format strings:
--    https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
/*
SELECT P.ProductName, FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate, I."Count"
FROM vInventories AS I
JOIN vProducts AS P ON P.ProductID = I.ProductID;
GO
*/

-- Finally we need to order by ProductName and InventoryDate
SELECT P.ProductName, FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate, I."Count" AS InventoryCount
FROM vInventories AS I
	JOIN vProducts AS P ON P.ProductID = I.ProductID
ORDER BY P.ProductName, I.InventoryDate;
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- This is pretty much just taking the SELECT developed in Question 3 and turning it into a VIEW
CREATE VIEW vProductInventories
WITH
	SCHEMABINDING
AS
	SELECT P.ProductName, FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate, I."Count" AS InventoryCount
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID;
GO

-- Check that it works: Select * From vProductInventories;
-- I don't think it's good to try to use ORDER BY when creating a view so here
-- is an example query using the newly created view with the desired ordering

-- Because the new InventoryDate uses full month names, the ordering is going to be off if we ORDER BY it
-- (e.g. February alphabetically comes before January). So need to figure a way to get our numerical date back
/*
SELECT CONVERT(date, vProductInventories.InventoryDate), vProductInventories.InventoryDate
FROM vProductInventories AS V
ORDER BY V.ProductName, V.InventoryDate;
GO
*/

-- It looks like using CONVERT or TRY_CONVERT and converting our 'MMMM, yyyy' format to a 'date' works
-- So final query would look like
SELECT *
FROM vProductInventories AS V
ORDER BY V.ProductName, CONVERT(date, V.InventoryDate);
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- In order to show Categories CategoryName column and Inventories columns together we will need to JOIN
-- Categories to Products, then Products to Inventories all as a new view of course

/*
CREATE VIEW vCategoryInventories
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryName, I.InventoryDate, I."Count"
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID
		JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID;
GO
*/

-- Now we need to convert the InventoryDate using the FORMAT strategy we used in Question 3
/*
CREATE VIEW vCategoryInventories
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryName, FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate, I."Count"
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID
		JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID;
GO
*/

-- We are still missing an "InventoryCountByCategory" and to achieve this we need to GROUP BY and SUM
CREATE VIEW vCategoryInventories
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryName, FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate, SUM(I."Count") AS InventoryCountByCategory
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID
		JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID
	GROUP BY C.CategoryName, InventoryDate
GO

-- Check that it works: Select * From vCategoryInventories;
-- I don't think it's good to try to use ORDER BY when creating a view so here
-- is an example query using the newly created view with the desired ordering

-- NOTE: The question asks to "Order the results by the Product and Date."
--       but becuase ProductName is not a valid column in this view, I think it probably should be CategoryName
SELECT *
FROM vCategoryInventories AS V
ORDER BY V.CategoryName, CONVERT(date, V.InventoryDate);
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- Let's first start with the SELECT statement developed in Question 4
/*
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
WITH
	SCHEMABINDING
AS
	SELECT P.ProductName, FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate, I."Count"
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID;
GO
*/

-- Because we need the previous month count, let's use the LAG functionality to create the desired PreviousMonthCount column
-- Looking up the documentation, shows that we can set a `default` param for LAG that will return a value when LAG is out of range (returns a NULL)
-- See: https://learn.microsoft.com/en-us/sql/t-sql/functions/lag-transact-sql?view=sql-server-ver16
/*
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
WITH
	SCHEMABINDING
AS
	SELECT
		P.ProductName,
		FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate,
		I."Count",
		LAG(I."Count", 1, 0) OVER (ORDER BY I.InventoryDate) AS PreviousMonthCount
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID;
GO
*/

-- The previous LAG usage in the SELECT statement got us closer, but the values don't look correct.
-- Further investigation showed that the "PreviousMonthCount" was not respecting each ProductName.
-- A bit of digging in the documentation reveals that we can use PARTITION BY so that LAG only
-- considers PreviousMonthCount within a given ProductName partition
-- See: https://learn.microsoft.com/en-us/sql/t-sql/functions/lag-transact-sql?view=sql-server-ver16#b-compare-values-within-partitions
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
WITH
	SCHEMABINDING
AS
	SELECT
		P.ProductName,
		FORMAT(I.InventoryDate, 'MMMM, yyyy', 'en-us') AS InventoryDate,
		I."Count" AS InventoryCount,
		LAG(I."Count", 1, 0) OVER (PARTITION BY P.ProductName ORDER BY I.InventoryDate) AS PreviousMonthCount
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
-- I don't think it's good to try to use ORDER BY when creating a view so here
-- is an example query using the newly created view with the desired ordering
SELECT *
FROM vProductInventoriesWithPreviousMonthCounts AS V
ORDER BY V.ProductName, CONVERT(date, V.InventoryDate);
GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- This new view must use the vProductInventoriesWithPreviousMonthCounts created in the previous question (6) so let's start there
/*
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
WITH
	SCHEMABINDING
AS
	SELECT
		V.ProductName,
		V.InventoryDate,
		V.InventoryCount,
		V.PreviousMonthCount
	FROM dbo.vProductInventoriesWithPreviousMonthCounts AS V;
GO
*/

-- We need to add a new column called "CountVsPreviousCountKPI", seems like a CASE statement will accomplish what we want
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
WITH
	SCHEMABINDING
AS
	SELECT
		V.ProductName,
		V.InventoryDate,
		V.InventoryCount,
		V.PreviousMonthCount,
		CASE
			WHEN V.InventoryCount > V.PreviousMonthCount THEN 1
			WHEN V.InventoryCount = V.PreviousMonthCount THEN 0
			WHEN V.InventoryCount < V.PreviousMonthCount THEN -1
		END
		AS CountVsPreviousCountKPI
	FROM dbo.vProductInventoriesWithPreviousMonthCounts AS V;
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
-- I don't think it's good to try to use ORDER BY when creating a view so here
-- is an example query using the newly created view with the desired ordering
SELECT *
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs AS V
ORDER BY V.ProductName, CONVERT(date, V.InventoryDate);
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- For this function, we can make use of the vProductInventoriesWithPreviousMonthCountsWithKPIs view we created in the previous question
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI_value int)
RETURNS TABLE
AS
RETURN
(
	SELECT
		V.ProductName,
		V.InventoryDate,
		V.InventoryCount,
		V.PreviousMonthCount,
		V.CountVsPreviousCountKPI
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs AS V
	WHERE V.CountVsPreviousCountKPI = @KPI_value
);
GO

-- Check that it works:
SELECT *
FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
SELECT *
FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
SELECT *
FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO

/***************************************************************************************/