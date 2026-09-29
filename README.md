# E-Commerce Data Warehouse Architecture & Analytics

This repository contains the SQL Server implementation of a relational data warehouse for an e-commerce platform (Superstore dataset). The project focuses on transforming raw data into a structured **Star Schema** to enable high-performance analytical querying, business intelligence reporting, and automated KPI generation.

## Project Structure

*   `1_Schema_Setup/`: DDL scripts for dimensional modeling and non-clustered index creation.
*   `2_ETL_Pipeline/`: Data insertion scripts structuring multi-table transformations from the raw staging layer.
*   `3_Analytics/`: 
    *   17 advanced analytical queries utilizing CTEs, Subqueries, Window Functions, and standard JOINs.
    *   Executive KPI Views and Stored Procedures for dynamic reporting.

## Entity Relationship Diagram (ERD)

The data model utilizes a central Fact table surrounded by five dimensions, optimized for rapid aggregations.

```mermaid
erDiagram
    Fact_Sales {
        INT RowID PK
        VARCHAR OrderID
        DATE OrderDate FK
        DATE ShipDate
        VARCHAR ShipMode FK
        VARCHAR CustomerID FK
        VARCHAR ProductID FK
        INT PostalCode FK
        DECIMAL Sales
        INT Quantity
        DECIMAL Discount
        DECIMAL Profit
    }
    
    Dim_Customer {
        VARCHAR CustomerID PK
        VARCHAR CustomerName
        VARCHAR Segment
    }
    
    Dim_Product {
        VARCHAR ProductID PK
        VARCHAR Category
        VARCHAR SubCategory
        VARCHAR ProductName
    }
    
    Dim_Location {
        INT PostalCode PK
        VARCHAR City
        VARCHAR State
        VARCHAR Country
        VARCHAR Region
    }
    
    Dim_Date {
        DATE DateKey PK
        INT OrderYear
        INT OrderQuarter
        INT OrderMonth
    }
    
    Dim_ShipMode {
        VARCHAR ShipMode PK
        INT ShippingSLA_Days
    }

    Dim_Customer ||--o{ Fact_Sales : "places"
    Dim_Product ||--o{ Fact_Sales : "contains"
    Dim_Location ||--o{ Fact_Sales : "shipped to"
    Dim_Date ||--o{ Fact_Sales : "ordered on"
    Dim_ShipMode ||--o{ Fact_Sales : "utilizes"