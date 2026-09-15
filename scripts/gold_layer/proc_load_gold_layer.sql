/*
===============================================================================
Stored Procedure: Load Gold Layer (Star Schema)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to populate the Gold layer.
    It executes in two main phases:
    1. Dimension Load: Inserts new, distinct records into all dimension tables,
       generating Surrogate Keys automatically.
    2. Fact Load: Joins the cleansed Silver data with the populated dimensions 
       to resolve Surrogate Keys, then loads the central fact_sales table.
===============================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_star_schema
AS
BEGIN
    PRINT '==================================================';
    PRINT ' Executing Stored Procedure: gold.load_star_schema';
    PRINT '==================================================';

    --------------------------------------------------
    -- 1. Load dim_customer
    --------------------------------------------------
    PRINT '>> Loading Dimension: dim_customer...';
    
    INSERT INTO gold.dim_customer (Customer_ID, Customer_Name, Segment)
    SELECT DISTINCT 
        Customer_ID, 
        Customer_Name, 
        Segment
    FROM silver.cleansed_superstore
    WHERE Customer_ID IS NOT NULL
      -- Ensure only new customers are inserted to prevent duplication
      AND Customer_ID NOT IN (SELECT Customer_ID FROM gold.dim_customer);

    PRINT '>> dim_customer loaded successfully.';
    
    --------------------------------------------------
    -- 2. Load dim_product
    --------------------------------------------------
    PRINT '>> Loading Dimension: dim_product...';
    
    INSERT INTO gold.dim_product (Product_ID, Product_Name, Category, Sub_Category)
    SELECT DISTINCT 
        Product_ID, 
        Product_Name, 
        Category, 
        Sub_Category
    FROM silver.cleansed_superstore
    WHERE Product_ID IS NOT NULL
      AND Product_ID NOT IN (SELECT Product_ID FROM gold.dim_product);

    --------------------------------------------------
    -- 3. Load dim_location
    --------------------------------------------------
    PRINT '>> Loading Dimension: dim_location...';
    
    INSERT INTO gold.dim_location (Country, Region, State, City, Postal_Code)
    SELECT DISTINCT 
        Country, 
        Region, 
        State, 
        City, 
        Postal_Code
    FROM silver.cleansed_superstore
    WHERE Country IS NOT NULL
      -- Using EXCEPT to easily find completely new locations
      EXCEPT
    SELECT Country, Region, State, City, Postal_Code FROM gold.dim_location;

    --------------------------------------------------
    -- 4. Load dim_ship_mode
    --------------------------------------------------
    PRINT '>> Loading Dimension: dim_ship_mode...';
    
    INSERT INTO gold.dim_ship_mode (Ship_Mode)
    SELECT DISTINCT 
        Ship_Mode
    FROM silver.cleansed_superstore
    WHERE Ship_Mode IS NOT NULL
      AND Ship_Mode NOT IN (SELECT Ship_Mode FROM gold.dim_ship_mode);

    --------------------------------------------------
    -- 5. Load dim_order
    --------------------------------------------------
    PRINT '>> Loading Dimension: dim_order...';
    
    INSERT INTO gold.dim_order (Order_ID)
    SELECT DISTINCT 
        Order_ID
    FROM silver.cleansed_superstore
    WHERE Order_ID IS NOT NULL
      AND Order_ID NOT IN (SELECT Order_ID FROM gold.dim_order);

    --------------------------------------------------
    -- 6. Load dim_date (Smart Key Generation)
    --------------------------------------------------
    PRINT '>> Loading Dimension: dim_date...';
    
    -- Extract all unique dates from both Order_Date and Ship_Date
    WITH all_dates AS (
        SELECT DISTINCT Order_Date AS date_value FROM silver.cleansed_superstore WHERE Order_Date IS NOT NULL
        UNION
        SELECT DISTINCT Ship_Date AS date_value FROM silver.cleansed_superstore WHERE Ship_Date IS NOT NULL
    )
    INSERT INTO gold.dim_date (DateKey, FullDate, Calendar_Year, Calendar_Quarter, Calendar_Month, Calendar_MonthName, Calendar_Day, Calendar_DayOfWeek)
    SELECT 
        -- Generate the Smart Key (YYYYMMDD)
        CAST(FORMAT(date_value, 'yyyyMMdd') AS INT) AS DateKey,
        date_value AS FullDate,
        YEAR(date_value) AS Calendar_Year,
        DATEPART(QUARTER, date_value) AS Calendar_Quarter,
        MONTH(date_value) AS Calendar_Month,
        DATENAME(MONTH, date_value) AS Calendar_MonthName,
        DAY(date_value) AS Calendar_Day,
        DATENAME(WEEKDAY, date_value) AS Calendar_DayOfWeek
    FROM all_dates
    WHERE CAST(FORMAT(date_value, 'yyyyMMdd') AS INT) NOT IN (SELECT DateKey FROM gold.dim_date);

    PRINT '>> All Dimensions loaded successfully.';
    
    --------------------------------------------------
    -- 7. Load fact_sales (The Star Schema Core)
    --------------------------------------------------
    PRINT '>> Loading Fact Table: fact_sales...';
    
    INSERT INTO gold.fact_sales (
        OrderDateKey, ShipDateKey, CustomerKey, ProductKey, 
        LocationKey, ShipModeKey, OrderKey, Row_ID, 
        Sales, Quantity, Discount, Profit
    )
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
    LEFT JOIN gold.dim_order o ON s.Order_ID = o.Order_ID
    -- Prevent duplicate rows from being inserted in the fact table
    WHERE s.Row_ID NOT IN (SELECT Row_ID FROM gold.fact_sales);

    PRINT '>> All Gold Layer tables loaded successfully.';
    PRINT '==================================================';
    PRINT ' ETL Process Completed!';
    PRINT '==================================================';

END;
GO
