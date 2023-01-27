CREATE DATABASE OverallDB

USE OverallDB;

--Create all tables
--Task 1, 2, 3 
CREATE TABLE Category(
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryDescription NVARCHAR(MAX) 
)
GO
CREATE TABLE Employee(
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    Firstname NVARCHAR(100) NOT NULL,
    Lastname NVARCHAR(100) NOT NULL,
    Age SMALLINT CHECK(Age > 17),
    Salary INT,
)
GO

CREATE TABLE [Order] (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID) ON DELETE SET NULL,
    CategoryID INT FOREIGN KEY REFERENCES Category(CategoryID) ON DELETE SET NULL,
    [CountT] INT,
    [Unit Price] DECIMAL(6, 2) CHECK([Unit Price] > 20),
)
GO
--Insert data 
--Task 4
GO
ALTER TABLE [Order] ADD OrderName NVARCHAR(100);

INSERT Category(CategoryName, CategoryDescription) VALUES
('Beverages', 'Soft drinks including lemonades'),
('Alcohol','Mixed and non-mixed alcoholic drinks'),
('Bakery', 'Baked breads and sandwiches'),
('Sweets', 'All chocolates and candies')

GO
INSERT Employee(Firstname, Lastname, Age, Salary) VALUES
('Araz', 'Aghayev', 42, 64000),
('Emil', 'Azadly', 33, 43000),
('Hamid', 'Mammadov', 26, 24500),
('Isgandar', 'Mustafazadeh', 23, 13000)

GO
INSERT [Order](EmployeeID, CategoryID, OrderName, [CountT], [Unit Price]) VALUES
(3, 2, 'Heineken', 200000, 32.65),
(4, 4, 'Milka chocolate', 30000, 47.45),
(2, 1, 'Coca cola', 400000, 28.65),
(2, 3, 'Pretzel', 1000, 22.25)

--Prevent Deleting and Log info
CREATE TABLE LogHistory(
    LogID INT PRIMARY KEY IDENTITY(1,1),
    RecordID INT,
    [User] NVARCHAR,
    [Date] DATETIME
)

GO

CREATE TRIGGER [TR_Order_Log_Delete_Query] 
ON [Order]
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @recordID INT;
    SELECT @recordID = OrderID FROM DELETED;
    INSERT LogHistory(RecordID, [User], [Date]) VALUES
    (@recordID, SUSER_ID(), GETDATE());
    PRINT(CONCAT(SUSER_NAME(), ' user tried to delete record with id ', @recordID, ' on ', GETDATE()));
END

delete from [Order] where OrderID = 6

--Rollback on inserting more than 5 records
--Task 6
GO
CREATE TRIGGER [TR_Category_Rollback_Insert_Five_Records]
ON Category
FOR INSERT
NOT FOR REPLICATION
AS
BEGIN
    BEGIN TRAN
    DECLARE @numberOfRecords INT;
    SELECT @numberOfRecords = COUNT(*) FROM inserted;
    IF @numberOfRecords > 5 
    BEGIN
        PRINT('Error! No more than 5 records can be inserted at a time');
        ROLLBACK;
    END
    ELSE COMMIT
END

INSERT Category(CategoryName, CategoryDescription) VALUES
('C', 'C'), ('D', 'D'), ('E', 'E'), ('F', 'F'), ('G', 'G'), ('H', 'H')

--Stored Procedure to insert an employee
--Task7
GO
CREATE PROCEDURE sp_insert_employee_get_id
(@firstname NVARCHAR(100), @lastname NVARCHAR(100), @age SMALLINT, @salary INT,
@ID INT OUTPUT)
AS
BEGIN
    INSERT Employee VALUES(@firstname, @lastname, @age, @salary)
    SELECT @ID = @@IDENTITY
END

DECLARE @lastID INT;
EXEC sp_insert_employee_get_id 'Emin', 'Huseynov', 31, 11000, @lastID OUTPUT
SELECT @lastID

--Stored Procedure to get top 10 sales
--Task 8
GO
CREATE PROC sp_get_top_ten_sales
AS
BEGIN
    SELECT TOP 10 OrderName, [CountT], [Unit Price], ([CountT] * [Unit Price]) as [Total Amount] 
    FROM [Order] ORDER BY ([CountT] * [Unit Price]) DESC
END

EXEC sp_get_top_ten_sales

--View to see sum
--Task 9
GO
CREATE VIEW vw_sum_of_sales_by_category
AS 
SELECT CategoryName, SUM(([CountT] * [Unit Price])) AS [Total Sale] FROM [Order] AS O
JOIN Category AS C 
ON O.CategoryID = C.CategoryID
GROUP BY CategoryName

SELECT * FROM vw_sum_of_sales_by_category

