--*************************************************************************--
-- Title: Assignment06
-- Author: NMei
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,Unknown,Created File
-- 2024-08-05,NMei,Finished Script
--**************************************************************************--
Begin TRY
	USE Master;
	IF EXISTS(SELECT Name
FROM SysDatabases
WHERE Name = 'Assignment06DB_NMei')
	 BEGIN
	ALTER DATABASE "Assignment06DB_NMei" SET Single_user WITH ROLLBACK Immediate;
	DROP DATABASE Assignment06DB_NMei;
END
	CREATE DATABASE Assignment06DB_NMei;
End Try
Begin CATCH
	PRINT Error_Number();
End Catch
GO
USE Assignment06DB_NMei;

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
	"EmployeeID" "int" NOT NULL -- New Column
,
	"ProductID" "int" NOT NULL
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
	(InventoryDate, EmployeeID, ProductID, "Count")
	SELECT '20170101' AS InventoryDate, 5 AS EmployeeID, ProductID, UnitsInStock
	FROM Northwind.dbo.Products
UNION
	SELECT '20170201' AS InventoryDate, 7 AS EmployeeID, ProductID, UnitsInStock + 10
	-- Using this is to create a made up value
	FROM Northwind.dbo.Products
UNION
	SELECT '20170301' AS InventoryDate, 9 AS EmployeeID, ProductID, UnitsInStock + 20
	-- Using this is to create a made up value
	FROM Northwind.dbo.Products
ORDER BY 1, 2
GO

-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT *
FROM Categories;
GO
SELECT *
FROM Products;
GO
SELECT *
FROM Employees;
GO
SELECT *
FROM Inventories;
GO

/********************************* Questions and Answers *********************************/
PRINT 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
GO

-- ********** NMei Notes **********
-- IMPORTANT: I will NOT being using TOP to force ORDER BY compatability for created views
--			  instead I will put a demonstration query from the view utilizing the ORDER BY
-- Rationale: https://stackoverflow.com/questions/15187676/create-a-view-with-order-by-clause
-- See also: https://learn.microsoft.com/en-us/sql/t-sql/statements/create-view-transact-sql?view=sql-server-ver15
--			 Relevant quote (ESPECIALLY the 2nd sentence):
-- 		      	The ORDER BY clause is used only to determine the rows that are returned by the
--			  	TOP or OFFSET clause in the view definition. The ORDER BY clause does not guarantee
--			  	ordered results when the view is queried, unless ORDER BY is also specified in the
--            	query itself.
-- ********************************         

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Create view for Categories
-- First explore the vanilla Categories table
/*
SELECT * FROM Categories;
GO
*/

-- Now we know the column names so go and create the VIEW
CREATE VIEW vCategories
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryID, C.CategoryName
	FROM dbo.Categories AS C;
GO

-- Create view for Products
-- First explore the vanilla Products table
/*
SELECT * FROM Products;
GO
*/

-- Now we know the column names so go and create the VIEW
CREATE VIEW vProducts
WITH
	SCHEMABINDING
AS
	SELECT P.ProductID, P.ProductName, P.CategoryID, P.UnitPrice
	FROM dbo.Products AS P;
GO

-- Create view for Employees
-- First explore the vanilla Employees table
/*
SELECT * FROM Employees;
GO
*/

-- Now we know the column names so go and create the VIEW
CREATE VIEW vEmployees
WITH
	SCHEMABINDING
AS
	SELECT E.EmployeeID, E.EmployeeFirstName, E.EmployeeLastName, E.ManagerID
	FROM dbo.Employees AS E;
GO


-- Create view for Inventories
-- First explore the vanilla Inventories table
/*
SELECT * FROM Inventories;
GO
*/

-- Now we know the column names so go and create the VIEW
CREATE VIEW vInventories
WITH
	SCHEMABINDING
AS
	SELECT I.InventoryID, I.InventoryDate, I.EmployeeID, I.ProductID, I."Count"
	FROM dbo.Inventories AS I;
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Ensure we are setting these permissions on the right database
USE Assignment06DB_NMei;
GO

-- Set permissions for Categories and vCategories
DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC; 
GO

-- Set permissions for Products and vProducts
DENY SELECT ON Products TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;
GO

-- Set permissions for Employees and vEmployees
DENY SELECT ON Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;
GO

-- Set permissoins for Inventories and vInventories
DENY SELECT ON Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
-- This is basically the answer to Question 1 of Assignment05, I cleaned it up a bit by using AS aliasing
CREATE VIEW vProductsByCategories
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryName, P.ProductName, P.UnitPrice
	FROM dbo.vProducts AS P
		JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID;
GO

-- Demonstrate how to query new view with the desired ordering
SELECT *
FROM vProductsByCategories
ORDER BY vProductsByCategories.CategoryName, vProductsByCategories.ProductName;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
-- This is basically the answer to Question 2 of Assignment05, I cleaned it up a bit by using AS aliasing
CREATE VIEW vInventoriesByProductsByDates
WITH
	SCHEMABINDING
AS
	SELECT P.ProductName, I.InventoryDate, I."Count"
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID;
GO

-- Demonstrate how to query new view with the desired ordering
SELECT *
FROM vInventoriesByProductsByDates AS V
ORDER BY V.ProductName, V.InventoryDate, V."Count";
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
-- This is basically the answer to Question 3 of Assignment05, I cleaned it up a bit by using AS aliasing
CREATE VIEW vInventoriesByEmployeesByDates
WITH
	SCHEMABINDING
AS
	SELECT DISTINCT I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
	FROM dbo.vEmployees AS E
		JOIN dbo.vInventories AS I ON I.EmployeeID = E.EmployeeID;
GO

-- Demonstrate how to query new view with the desired ordering
SELECT *
FROM vInventoriesByEmployeesByDates AS V
ORDER BY V.InventoryDate;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
-- This is basically the answer to Question 4 of Assignment05, I cleaned it up a bit by using AS aliasing
CREATE VIEW vInventoriesByProductsByCategories
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryName, P.ProductName, I.InventoryDate, I."Count"
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID
		JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID;
GO

-- Demonstrate how to query new view with the desired ordering
SELECT *
FROM vInventoriesByProductsByCategories AS V
ORDER BY V.CategoryName, V.ProductName, V.InventoryDate, V."Count";
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
-- This is basically the answer to Question 5 of Assignment05, I cleaned it up a bit by using AS aliasing
CREATE VIEW vInventoriesByProductsByEmployees
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryName, P.ProductName, I.InventoryDate, I."Count", E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID
		JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID
		JOIN dbo.vEmployees AS E ON E.EmployeeID = I.EmployeeID;
GO

-- Demonstrate how to query new view with the desired ordering
SELECT *
FROM vInventoriesByProductsByEmployees AS V
ORDER BY V.InventoryDate, V.CategoryName, V.ProductName, V.EmployeeName;
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'?
-- This is basically the answer to Question 6 of Assignment05, I cleaned it up a bit by using AS aliasing
CREATE VIEW vInventoriesForChaiAndChangByEmployees
WITH
	SCHEMABINDING
AS
	SELECT C.CategoryName, P.ProductName, I.InventoryDate, I."Count", E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
	FROM dbo.vInventories AS I
		JOIN dbo.vProducts AS P ON P.ProductID = I.ProductID
		JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID
		JOIN dbo.vEmployees AS E ON E.EmployeeID = I.EmployeeID
	WHERE P.ProductName IN ('Chai', 'Chang');
GO

-- Demonstrate how to query new view with the desired ordering
SELECT *
FROM vInventoriesForChaiAndChangByEmployees AS V
ORDER BY V.InventoryDate, V.CategoryName, V.ProductName;
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
-- This is basically the answer to Question 7 of Assignment05, I cleaned it up a bit by using AS aliasing
CREATE VIEW vEmployeesByManager
WITH
	SCHEMABINDING
AS
	SELECT M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
	FROM dbo.vEmployees AS E
		JOIN dbo.vEmployees AS M ON M.EmployeeID = E.ManagerID;
GO

-- Demonstrate how to query new view with the desired ordering
-- For some reason, the example screenshot in the main Assignment06.docx for question 9
-- shows the results *also* ordered by Employee after Manager let's do that as well
SELECT *
FROM vEmployeesByManager AS V
ORDER BY Manager, Employee;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- This one is a new query and was not in Assignment05 so let's develop the SELECT portion first
-- basically we want to JOIN everything (including vEmployees to itself as a Managers view)

/*
-- Splitting this SELECT's columns into separate lines because it is otherwise excessively long
SELECT
	C.CategoryID,
	C.CategoryName,
	P.ProductID,
	P.ProductName,
	P.UnitPrice,
	I.InventoryID,
	I.InventoryDate,
	I."Count",
	E.EmployeeID,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee,
	M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
FROM dbo.vCategories AS C
	JOIN dbo.vProducts AS P ON P.CategoryID = C.CategoryID
	JOIN dbo.vInventories AS I ON I.ProductID = P.ProductID
	JOIN dbo.vEmployees AS E ON E.EmployeeID = I.EmployeeID
	JOIN dbo.vEmployees AS M ON M.EmployeeID = E.ManagerID;
GO
*/

-- Now that we've prototyped the SELECT portion, let's create the view
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
WITH
	SCHEMABINDING
AS
	-- Splitting this SELECT's columns into separate lines because it is otherwise excessively long
	SELECT
		C.CategoryID,
		C.CategoryName,
		P.ProductID,
		P.ProductName,
		P.UnitPrice,
		I.InventoryID,
		I.InventoryDate,
		I."Count",
		E.EmployeeID,
		E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee,
		M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
	FROM dbo.vCategories AS C
		JOIN dbo.vProducts AS P ON P.CategoryID = C.CategoryID
		JOIN dbo.vInventories AS I ON I.ProductID = P.ProductID
		JOIN dbo.vEmployees AS E ON E.EmployeeID = I.EmployeeID
		JOIN dbo.vEmployees AS M ON M.EmployeeID = E.ManagerID;
GO

-- Demonstrate how to query new view with the desired ordering
-- I interpreted the ORDER BY `Product` in the question prompt as `ProductName`
SELECT *
FROM vInventoriesByProductsByCategoriesByEmployees AS V
ORDER BY V.CategoryName, V.ProductName, V.InventoryID, V.Employee;
GO

-- However it looks like the screenshot in the main Assignment06.docx for question 10
-- shows the results ordered by CategoryName, ProductID, InventoryID, Employee
-- so let's do that as well
SELECT *
FROM vInventoriesByProductsByCategoriesByEmployees AS V
ORDER BY V.CategoryName, V.ProductID, V.InventoryID, V.Employee;
GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
PRINT 'Note: You will get an error until the views are created!'
SELECT *
FROM "dbo"."vCategories"
SELECT *
FROM "dbo"."vProducts"
SELECT *
FROM "dbo"."vInventories"
SELECT *
FROM "dbo"."vEmployees"

SELECT *
FROM "dbo"."vProductsByCategories"
SELECT *
FROM "dbo"."vInventoriesByProductsByDates"
SELECT *
FROM "dbo"."vInventoriesByEmployeesByDates"
SELECT *
FROM "dbo"."vInventoriesByProductsByCategories"
SELECT *
FROM "dbo"."vInventoriesByProductsByEmployees"
SELECT *
FROM "dbo"."vInventoriesForChaiAndChangByEmployees"
SELECT *
FROM "dbo"."vEmployeesByManager"
SELECT *
FROM "dbo"."vInventoriesByProductsByCategoriesByEmployees"
GO

/***************************************************************************************/