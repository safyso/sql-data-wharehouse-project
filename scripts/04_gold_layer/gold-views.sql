/*
=============================================================================
DDL Script: Create Gold Layer Views
=============================================================================

Script Purpose:
    This script creates the Gold layer views (Star Schema) for the Data Warehouse.
    It splits the cleansed flat table (silver.cleansed_superstore) into Dimension 
    and Fact views, and provides a final master view (vw_fact_sales_report) 
    that joins them together.

Usage:
    - Provides read-only access for data analytics and reporting.
    - The master view can be directly imported into Python/Pandas for EDA.
=============================================================================
*/

PRINT '==================================================';
PRINT ' Gold Layer: Virtual Dimensional Modeling (Views)';
PRINT '==================================================';
GO

-- 1. Create Customer Dimension View
CREATE OR ALTER VIEW gold.dim_customer AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Customer_ID) AS CustomerKey, 
    Customer_ID, 
    Customer_Name, 
    Segment
FROM (
    SELECT DISTINCT Customer_ID, Customer_Name, Segment 
    FROM silver.cleansed_superstore 
    WHERE Customer_ID IS NOT NULL
) c;
GO
PRINT '>> View gold.dim_customer created successfully.';
GO

-- 2. Create Product Dimension View
CREATE OR ALTER VIEW gold.dim_product AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Product_ID) AS ProductKey, 
    Product_ID, 
    Product_Name, 
    Category, 
    Sub_Category
FROM (
    SELECT DISTINCT Product_ID, Product_Name, Category, Sub_Category 
    FROM silver.cleansed_superstore 
    WHERE Product_ID IS NOT NULL
) p;
GO
PRINT '>> View gold.dim_product created successfully.';
GO

-- 3. Create Location Dimension View
CREATE OR ALTER VIEW gold.dim_location AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Country, Region, State, City, Postal_Code) AS LocationKey, 
    Country, 
    Region, 
    State, 
    City, 
    Postal_Code
FROM (
    SELECT DISTINCT Country, Region, State, City, Postal_Code 
    FROM silver.cleansed_superstore 
    WHERE Country IS NOT NULL
) l;
GO
PRINT '>> View gold.dim_location created successfully.';
GO

-- 4. Create Ship Mode Dimension View
CREATE OR ALTER VIEW gold.dim_ship_mode AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Ship_Mode) AS ShipModeKey, 
    Ship_Mode
FROM (
    SELECT DISTINCT Ship_Mode 
    FROM silver.cleansed_superstore 
    WHERE Ship_Mode IS NOT NULL
) sm;
GO
PRINT '>> View gold.dim_ship_mode created successfully.';
GO

-- 5. Create Order Dimension View
CREATE OR ALTER VIEW gold.dim_order AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Order_ID) AS OrderKey, 
    Order_ID
FROM (
    SELECT DISTINCT Order_ID 
    FROM silver.cleansed_superstore 
    WHERE Order_ID IS NOT NULL
) o;
GO
PRINT '>> View gold.dim_order created successfully.';
GO

-- 6. Create Date Dimension View
CREATE OR ALTER VIEW gold.dim_date AS
SELECT 
    CAST(FORMAT(date_value, 'yyyyMMdd') AS INT) AS DateKey,
    date_value AS FullDate,
    YEAR(date_value) AS Calendar_Year,
    DATEPART(QUARTER, date_value) AS Calendar_Quarter,
    MONTH(date_value) AS Calendar_Month,
    DATENAME(MONTH, date_value) AS Calendar_MonthName,
    DAY(date_value) AS Calendar_Day,
    DATENAME(WEEKDAY, date_value) AS Calendar_DayOfWeek
FROM (
    SELECT DISTINCT Order_Date AS date_value FROM silver.cleansed_superstore WHERE Order_Date IS NOT NULL
    UNION
    SELECT DISTINCT Ship_Date AS date_value FROM silver.cleansed_superstore WHERE Ship_Date IS NOT NULL
) d;
GO
PRINT '>> View gold.dim_date created successfully.';
GO

-- 7. Create Fact Sales View (The Star Schema Core)
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    CAST(FORMAT(s.Order_Date, 'yyyyMMdd') AS INT) AS OrderDateKey,
    CAST(FORMAT(s.Ship_Date, 'yyyyMMdd') AS INT) AS ShipDateKey,
    c.CustomerKey,
    p.ProductKey,
    l.LocationKey,
    sm.ShipModeKey,
    o.OrderKey,
    s.Row_ID,
    s.Sales,
    s.Quantity,
    s.Discount,
    s.Profit
FROM silver.cleansed_superstore s
LEFT JOIN gold.dim_customer c ON s.Customer_ID = c.Customer_ID
LEFT JOIN gold.dim_product p ON s.Product_ID = p.Product_ID
LEFT JOIN gold.dim_location l 
    ON s.Country = l.Country 
    AND s.Region = l.Region 
    AND s.State = l.State 
    AND s.City = l.City 
    AND s.Postal_Code = l.Postal_Code
LEFT JOIN gold.dim_ship_mode sm ON s.Ship_Mode = sm.Ship_Mode
LEFT JOIN gold.dim_order o ON s.Order_ID = o.Order_ID;
GO
PRINT '>> View gold.fact_sales created successfully.';
GO

-- 8. Create Master Report View (For Advanced Analytics & Python)
CREATE OR ALTER VIEW gold.vw_fact_sales_report AS
SELECT 
    -- Fact measures and identifiers
    f.Row_ID,
    f.Sales,
    f.Quantity,
    f.Discount,
    f.Profit,

    -- Date dimensions
    d_order.FullDate AS Order_Date,
    d_order.Calendar_Year AS Order_Year,
    d_order.Calendar_MonthName AS Order_Month,
    d_ship.FullDate AS Ship_Date,

    -- Customer dimensions
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,

    -- Product dimensions
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,

    -- Location dimensions
    l.Country,
    l.Region,
    l.State,
    l.City,
    l.Postal_Code,

    -- Ship Mode dimension
    sm.Ship_Mode,

    -- Order dimension
    o.Order_ID

FROM gold.fact_sales f
LEFT JOIN gold.dim_date d_order ON f.OrderDateKey = d_order.DateKey
LEFT JOIN gold.dim_date d_ship ON f.ShipDateKey = d_ship.DateKey
LEFT JOIN gold.dim_customer c ON f.CustomerKey = c.CustomerKey
LEFT JOIN gold.dim_product p ON f.ProductKey = p.ProductKey
LEFT JOIN gold.dim_location l ON f.LocationKey = l.LocationKey
LEFT JOIN gold.dim_ship_mode sm ON f.ShipModeKey = sm.ShipModeKey
LEFT JOIN gold.dim_order o ON f.OrderKey = o.OrderKey;
GO

PRINT '>> View gold.vw_fact_sales_report created successfully.';
PRINT '==================================================';
PRINT ' Virtual Star Schema Created Successfully!';
PRINT '==================================================';
GO
