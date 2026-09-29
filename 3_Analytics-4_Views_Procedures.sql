USE SuperstoreDB;
GO

IF OBJECT_ID('sp_AnalyzeSegmentProfitability', 'P') IS NOT NULL DROP PROCEDURE sp_AnalyzeSegmentProfitability;
IF OBJECT_ID('sp_GetRegionalSales', 'P') IS NOT NULL DROP PROCEDURE sp_GetRegionalSales;
IF OBJECT_ID('vw_Executive_KPI', 'V') IS NOT NULL DROP VIEW vw_Executive_KPI;
IF OBJECT_ID('vw_Product_Profitability', 'V') IS NOT NULL DROP VIEW vw_Product_Profitability;
GO

CREATE VIEW vw_Executive_KPI AS
SELECT d.OrderYear, d.OrderMonth, SUM(s.Sales) AS Total_Revenue, SUM(s.Profit) AS Net_Profit,
    CASE WHEN SUM(s.Sales) = 0 THEN 0 ELSE (SUM(s.Profit) / SUM(s.Sales)) * 100 END AS Profit_Margin_Percent
FROM Fact_Sales s JOIN Dim_Date d ON s.OrderDate = d.DateKey GROUP BY d.OrderYear, d.OrderMonth;
GO

CREATE VIEW vw_Product_Profitability AS
SELECT p.Category, p.SubCategory, SUM(s.Sales) AS Total_Sales, SUM(s.Profit) AS Total_Profit, COUNT(s.OrderID) AS Order_Count
FROM Fact_Sales s JOIN Dim_Product p ON s.ProductID = p.ProductID GROUP BY p.Category, p.SubCategory;
GO

CREATE PROCEDURE sp_AnalyzeSegmentProfitability @TargetSegment VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON; 
    SELECT c.Segment, COUNT(DISTINCT s.OrderID) AS Total_Orders, SUM(s.Profit) AS Segment_Profit
    FROM Fact_Sales s JOIN Dim_Customer c ON s.CustomerID = c.CustomerID WHERE c.Segment = @TargetSegment GROUP BY c.Segment;
END;
GO

CREATE PROCEDURE sp_GetRegionalSales @RegionName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON; 
    SELECT l.State, SUM(s.Sales) AS Total_Sales, SUM(s.Profit) AS Total_Profit
    FROM Fact_Sales s JOIN Dim_Location l ON s.PostalCode = l.PostalCode WHERE l.Region = @RegionName GROUP BY l.State ORDER BY Total_Sales DESC;
END;
GO