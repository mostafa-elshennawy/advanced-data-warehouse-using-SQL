USE SuperstoreDB;
GO

-- Q1. Total Profit by Category (JOIN)
SELECT p.Category, SUM(s.Profit) AS TotalProfit
FROM Fact_Sales s JOIN Dim_Product p ON s.ProductID = p.ProductID GROUP BY p.Category;

-- Q2. Top 5 States by Sales Volume (JOIN)
SELECT TOP 5 l.State, SUM(s.Sales) AS TotalSales
FROM Fact_Sales s JOIN Dim_Location l ON s.PostalCode = l.PostalCode GROUP BY l.State ORDER BY TotalSales DESC;

-- Q3. Monthly Sales Trends (JOIN)
SELECT d.OrderYear, d.OrderMonth, SUM(s.Sales) AS MonthlySales
FROM Fact_Sales s JOIN Dim_Date d ON s.OrderDate = d.DateKey GROUP BY d.OrderYear, d.OrderMonth ORDER BY d.OrderYear, d.OrderMonth;

-- Q4. Identify High-Value Orders (Subquery 1)
SELECT CustomerName FROM Dim_Customer 
WHERE CustomerID IN (SELECT CustomerID FROM Fact_Sales WHERE Sales > 1500);

-- Q5. Calculate Average Order Value (AOV) per Segment (JOIN)
SELECT c.Segment, AVG(s.Sales) AS AvgOrderValue
FROM Fact_Sales s JOIN Dim_Customer c ON s.CustomerID = c.CustomerID GROUP BY c.Segment;

-- Q6. Order Profitability Tiers (CASE Statement 1)
SELECT OrderID, Profit,
    CASE WHEN Profit > 100 THEN 'High Margin' WHEN Profit > 0 THEN 'Standard Margin' ELSE 'Loss Maker' END AS ProfitTier
FROM Fact_Sales;

-- Q7. Above-Average Customer Spending (CTE 1 & Subquery 2)
WITH CustomerTotals AS (SELECT CustomerID, SUM(Sales) AS TotalSpend FROM Fact_Sales GROUP BY CustomerID)
SELECT CustomerID, TotalSpend FROM CustomerTotals WHERE TotalSpend > (SELECT AVG(TotalSpend) FROM CustomerTotals);

-- Q8. Running Total of Sales (CTE 2 & Window Function)
WITH MonthlyAgg AS (SELECT OrderDate, SUM(Sales) AS DailySales FROM Fact_Sales GROUP BY OrderDate)
SELECT OrderDate, DailySales, SUM(DailySales) OVER (ORDER BY OrderDate) AS RunningTotal FROM MonthlyAgg;

-- Q9. Unprofitable Sub-Categories (JOIN)
SELECT p.SubCategory, SUM(s.Profit) AS NetLoss
FROM Fact_Sales s JOIN Dim_Product p ON s.ProductID = p.ProductID WHERE s.Profit < 0 GROUP BY p.SubCategory ORDER BY NetLoss ASC;

-- Q10. Shipping Mode Preference by Quantity (JOIN)
SELECT sm.ShipMode, SUM(s.Quantity) AS ItemsShipped 
FROM Fact_Sales s JOIN Dim_ShipMode sm ON s.ShipMode = sm.ShipMode GROUP BY sm.ShipMode ORDER BY ItemsShipped DESC;

-- Q11. Discount Impact on Profitability
SELECT Discount, AVG(Profit) AS AvgProfit FROM Fact_Sales GROUP BY Discount ORDER BY Discount;

-- Q12. Count of Unique Customers per State (JOIN)
SELECT l.State, COUNT(DISTINCT s.CustomerID) AS CustomerBase
FROM Fact_Sales s JOIN Dim_Location l ON s.PostalCode = l.PostalCode GROUP BY l.State ORDER BY CustomerBase DESC;

-- Q13. Highest Selling Product (Subquery 3)
SELECT ProductName FROM Dim_Product 
WHERE ProductID = (SELECT TOP 1 ProductID FROM Fact_Sales GROUP BY ProductID ORDER BY SUM(Sales) DESC);

-- Q14. Year-over-Year Sales Growth 
SELECT YEAR(OrderDate) AS SalesYear, SUM(Sales) AS AnnualSales FROM Fact_Sales GROUP BY YEAR(OrderDate) ORDER BY SalesYear;

-- Q15. Average Discount given to Corporate Segment (JOIN)
SELECT c.Segment, AVG(s.Discount) AS AvgDiscount
FROM Fact_Sales s JOIN Dim_Customer c ON s.CustomerID = c.CustomerID WHERE c.Segment = 'Corporate' GROUP BY c.Segment;

-- Q16. Top Performing Customer per Region (CTE 3)
WITH RegionalCust_Rank AS (
    SELECT l.Region, c.CustomerName, SUM(s.Sales) AS TotalSales, ROW_NUMBER() OVER(PARTITION BY l.Region ORDER BY SUM(s.Sales) DESC) AS RankVal
    FROM Fact_Sales s JOIN Dim_Location l ON s.PostalCode = l.PostalCode JOIN Dim_Customer c ON s.CustomerID = c.CustomerID GROUP BY l.Region, c.CustomerName
)
SELECT Region, CustomerName, TotalSales FROM RegionalCust_Rank WHERE RankVal = 1;

-- Q17. Shipping Duration Categorization (CASE Statement 2)
SELECT OrderID, OrderDate, ShipDate, DATEDIFF(day, OrderDate, ShipDate) AS DaysToShip,
    CASE WHEN DATEDIFF(day, OrderDate, ShipDate) <= 2 THEN 'Fast' WHEN DATEDIFF(day, OrderDate, ShipDate) <= 5 THEN 'Normal' ELSE 'Slow' END AS ShippingSpeed
FROM Fact_Sales;
GO