USE SuperstoreDB;
GO

-- ETL: LOAD DATA FROM EXCEL (dbo.Central_Superstore) INTO STAR SCHEMA
INSERT INTO Dim_Customer (CustomerID, CustomerName, Segment)
SELECT Customer_ID, MAX(Customer_Name), MAX(Segment)
FROM Central_Superstore GROUP BY Customer_ID;

INSERT INTO Dim_Product (ProductID, Category, SubCategory, ProductName)
SELECT Product_ID, MAX(Category), MAX(Sub_Category), MAX(Product_Name)
FROM Central_Superstore GROUP BY Product_ID;

INSERT INTO Dim_Location (PostalCode, City, State, Country, Region)
SELECT Postal_Code, MAX(City), MAX(State), MAX(Country), MAX(Region)
FROM Central_Superstore GROUP BY Postal_Code;

INSERT INTO Dim_Date (DateKey, OrderYear, OrderQuarter, OrderMonth)
SELECT DISTINCT CAST(Order_Date AS DATE), YEAR(Order_Date), DATEPART(qq, Order_Date), MONTH(Order_Date)
FROM Central_Superstore WHERE Order_Date IS NOT NULL;

INSERT INTO Dim_ShipMode (ShipMode, ShippingSLA_Days)
SELECT DISTINCT Ship_Mode,
    CASE WHEN Ship_Mode = 'Same Day' THEN 0 WHEN Ship_Mode = 'First Class' THEN 2
         WHEN Ship_Mode = 'Second Class' THEN 4 ELSE 7 END
FROM Central_Superstore WHERE Ship_Mode IS NOT NULL;

INSERT INTO Fact_Sales (RowID, OrderID, OrderDate, ShipDate, ShipMode, CustomerID, ProductID, PostalCode, Sales, Quantity, Discount, Profit)
SELECT Row_ID, Order_ID, CAST(Order_Date AS DATE), CAST(Ship_Date AS DATE), Ship_Mode, Customer_ID, Product_ID, Postal_Code, Sales, Quantity, Discount, Profit
FROM Central_Superstore;
GO