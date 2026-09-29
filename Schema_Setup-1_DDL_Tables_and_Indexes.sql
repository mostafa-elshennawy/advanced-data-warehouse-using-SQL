USE SuperstoreDB;
GO

IF OBJECT_ID('Fact_Sales', 'U') IS NOT NULL DROP TABLE Fact_Sales;
IF OBJECT_ID('Dim_Customer', 'U') IS NOT NULL DROP TABLE Dim_Customer;
IF OBJECT_ID('Dim_Product', 'U') IS NOT NULL DROP TABLE Dim_Product;
IF OBJECT_ID('Dim_Location', 'U') IS NOT NULL DROP TABLE Dim_Location;
IF OBJECT_ID('Dim_Date', 'U') IS NOT NULL DROP TABLE Dim_Date;
IF OBJECT_ID('Dim_ShipMode', 'U') IS NOT NULL DROP TABLE Dim_ShipMode;
GO

-- 1. DATA MODELING: STAR SCHEMA CREATION
CREATE TABLE Dim_Customer (
    CustomerID VARCHAR(50) PRIMARY KEY,
    CustomerName VARCHAR(100),
    Segment VARCHAR(50)
);

CREATE TABLE Dim_Product (
    ProductID VARCHAR(50) PRIMARY KEY,
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    ProductName VARCHAR(255)
);

CREATE TABLE Dim_Location (
    PostalCode INT PRIMARY KEY,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Region VARCHAR(50)
);

CREATE TABLE Dim_Date (
    DateKey DATE PRIMARY KEY,
    OrderYear INT,
    OrderQuarter INT,
    OrderMonth INT
);

CREATE TABLE Dim_ShipMode (
    ShipMode VARCHAR(50) PRIMARY KEY,
    ShippingSLA_Days INT 
);

CREATE TABLE Fact_Sales (
    RowID INT PRIMARY KEY,
    OrderID VARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(50),
    CustomerID VARCHAR(50),
    ProductID VARCHAR(50),
    PostalCode INT,
    Sales DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(4,2),
    Profit DECIMAL(10,4),
    CONSTRAINT FK_Sales_Date FOREIGN KEY (OrderDate) REFERENCES Dim_Date(DateKey),
    CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerID) REFERENCES Dim_Customer(CustomerID),
    CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductID) REFERENCES Dim_Product(ProductID),
    CONSTRAINT FK_Sales_Location FOREIGN KEY (PostalCode) REFERENCES Dim_Location(PostalCode),
    CONSTRAINT FK_Sales_ShipMode FOREIGN KEY (ShipMode) REFERENCES Dim_ShipMode(ShipMode)
);
GO

-- 2. QUERY OPTIMIZATION (Indexing)
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerID ON Fact_Sales(CustomerID);
CREATE NONCLUSTERED INDEX IX_FactSales_ProductID ON Fact_Sales(ProductID);
CREATE NONCLUSTERED INDEX IX_FactSales_PostalCode ON Fact_Sales(PostalCode);
CREATE NONCLUSTERED INDEX IX_FactSales_ShipMode ON Fact_Sales(ShipMode);
GO