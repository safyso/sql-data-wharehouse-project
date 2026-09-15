/*
===============================================================================
Stored Procedure: Load Cleansed Data into Silver Layer
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to load data into the 'silver' schema.
    Key transformations include:
      - Deduplication of raw data (using ROW_NUMBER).
      - Data type casting and standardization.
      - Data Quality validation (identifying missing and invalid values).
      - Statistical Outlier detection using Interquartile Range (IQR).
      - Upserting (MERGE) the cleansed data into silver.cleansed_superstore.
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_cleansed_superstore
AS
BEGIN
    PRINT '==================================================';
    PRINT ' Clean and Load Superstore into Silver Layer';
    PRINT '==================================================';

    -- CTE 1: Fetch raw data and remove duplicates using ROW_NUMBER
    WITH raw_data AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY Row_ID ORDER BY bronze_id DESC) AS rn
        FROM bronze.raw_superstore
        WHERE NULLIF(LTRIM(RTRIM(Row_ID)), '') IS NOT NULL
    ),
    
    -- CTE 2: Cast data types and prepare raw versions for validation
    cleaned_data AS (
        SELECT 
            TRY_CAST(LTRIM(RTRIM(Row_ID)) AS INT) AS Row_ID,
            NULLIF(LTRIM(RTRIM(Order_ID)), '') AS Order_ID,
            
            TRY_CAST(NULLIF(LTRIM(RTRIM(Order_Date)), '') AS DATE) AS Order_Date,
            NULLIF(LTRIM(RTRIM(Order_Date)), '') AS raw_order_date,
            
            TRY_CAST(NULLIF(LTRIM(RTRIM(Ship_Date)), '') AS DATE) AS Ship_Date,
            NULLIF(LTRIM(RTRIM(Ship_Date)), '') AS raw_ship_date,
            
            NULLIF(LTRIM(RTRIM(Ship_Mode)), '') AS Ship_Mode,
            NULLIF(LTRIM(RTRIM(Customer_ID)), '') AS Customer_ID,
            NULLIF(LTRIM(RTRIM(Customer_Name)), '') AS Customer_Name,
            NULLIF(LTRIM(RTRIM(Segment)), '') AS Segment,
            NULLIF(LTRIM(RTRIM(Country)), '') AS Country,
            NULLIF(LTRIM(RTRIM(City)), '') AS City,
            NULLIF(LTRIM(RTRIM(State)), '') AS State,
            NULLIF(LTRIM(RTRIM(Postal_Code)), '') AS Postal_Code,
            NULLIF(LTRIM(RTRIM(Region)), '') AS Region,
            NULLIF(LTRIM(RTRIM(Product_ID)), '') AS Product_ID,
            NULLIF(LTRIM(RTRIM(Category)), '') AS Category,
            NULLIF(LTRIM(RTRIM(Sub_Category)), '') AS Sub_Category,
            NULLIF(LTRIM(RTRIM(Product_Name)), '') AS Product_Name,
            
            TRY_CAST(NULLIF(LTRIM(RTRIM(Sales)), '') AS DECIMAL(18, 4)) AS Sales,
            NULLIF(LTRIM(RTRIM(Sales)), '') AS raw_sales,
            
            TRY_CAST(NULLIF(LTRIM(RTRIM(Quantity)), '') AS INT) AS Quantity,
            NULLIF(LTRIM(RTRIM(Quantity)), '') AS raw_quantity,
            
            TRY_CAST(NULLIF(LTRIM(RTRIM(Discount)), '') AS DECIMAL(18, 4)) AS Discount,
            NULLIF(LTRIM(RTRIM(Discount)), '') AS raw_discount,
            
            TRY_CAST(NULLIF(LTRIM(RTRIM(Profit)), '') AS DECIMAL(18, 4)) AS Profit,
            NULLIF(LTRIM(RTRIM(Profit)), '') AS raw_profit
        FROM raw_data
        WHERE rn = 1
    ),
    
    -- CTE 3: Calculate IQR bounds for Outlier detection (Sales, Profit, Quantity)
    iqr_bounds AS (
        SELECT DISTINCT
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Sales) OVER () AS q1_sales,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Sales) OVER () AS q3_sales,
            
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Profit) OVER () AS q1_profit,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Profit) OVER () AS q3_profit,
            
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantity) OVER () AS q1_quantity,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantity) OVER () AS q3_quantity
        FROM cleaned_data
    ),
    
    -- CTE 4: Generate Data Quality Flags
    flagged_data AS (
        SELECT 
            c.*,
            
            -- Flag 1: Check for missing essential data
            CASE 
                WHEN c.Order_ID IS NULL OR c.Customer_ID IS NULL OR c.Product_ID IS NULL OR c.Order_Date IS NULL THEN 1 
                ELSE 0 
            END AS has_missing_value,
            
            -- Flag 2: Check for casting failures or invalid business rules
            CASE 
                WHEN (c.raw_order_date IS NOT NULL AND c.Order_Date IS NULL)
                  OR (c.raw_ship_date IS NOT NULL AND c.Ship_Date IS NULL)
                  OR (c.raw_sales IS NOT NULL AND c.Sales IS NULL)
                  OR (c.raw_quantity IS NOT NULL AND c.Quantity IS NULL)
                  OR (c.raw_discount IS NOT NULL AND c.Discount IS NULL)
                  OR (c.raw_profit IS NOT NULL AND c.Profit IS NULL)
                  OR c.Sales < 0 
                  OR c.Quantity <= 0 
                  OR c.Discount < 0
                THEN 1 
                ELSE 0 
            END AS has_invalid_value,
            
            -- Flag 3: Check for statistical outliers using IQR formulas
            CASE 
                WHEN c.Sales > (i.q3_sales + 1.5 * (i.q3_sales - i.q1_sales)) 
                  OR c.Sales < (i.q1_sales - 1.5 * (i.q3_sales - i.q1_sales))
                  OR c.Profit > (i.q3_profit + 1.5 * (i.q3_profit - i.q1_profit)) 
                  OR c.Profit < (i.q1_profit - 1.5 * (i.q3_profit - i.q1_profit))
                  OR c.Quantity > (i.q3_quantity + 1.5 * (i.q3_quantity - i.q1_quantity)) 
                  OR c.Quantity < (i.q1_quantity - 1.5 * (i.q3_quantity - i.q1_quantity))
                THEN 1 
                ELSE 0 
            END AS has_outlier_value
            
        FROM cleaned_data c
        CROSS JOIN iqr_bounds i
    )

    -- Final Step: Upsert data into the Silver Layer physical table
    MERGE silver.cleansed_superstore AS tgt
    USING flagged_data AS src
    ON tgt.Row_ID = src.Row_ID
    WHEN MATCHED THEN
        UPDATE SET
            tgt.Order_ID = src.Order_ID,
            tgt.Order_Date = src.Order_Date,
            tgt.Ship_Date = src.Ship_Date,
            tgt.Ship_Mode = src.Ship_Mode,
            tgt.Customer_ID = src.Customer_ID,
            tgt.Customer_Name = src.Customer_Name,
            tgt.Segment = src.Segment,
            tgt.Country = src.Country,
            tgt.City = src.City,
            tgt.State = src.State,
            tgt.Postal_Code = src.Postal_Code,
            tgt.Region = src.Region,
            tgt.Product_ID = src.Product_ID,
            tgt.Category = src.Category,
            tgt.Sub_Category = src.Sub_Category,
            tgt.Product_Name = src.Product_Name,
            tgt.Sales = src.Sales,
            tgt.Quantity = src.Quantity,
            tgt.Discount = src.Discount,
            tgt.Profit = src.Profit,
            tgt.has_missing_value = src.has_missing_value,
            tgt.has_invalid_value = src.has_invalid_value,
            tgt.has_outlier_value = src.has_outlier_value
    WHEN NOT MATCHED THEN
        INSERT (
            Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Customer_Name, 
            Segment, Country, City, State, Postal_Code, Region, Product_ID, Category, 
            Sub_Category, Product_Name, Sales, Quantity, Discount, Profit, 
            has_missing_value, has_invalid_value, has_outlier_value
        )
        VALUES (
            src.Row_ID, src.Order_ID, src.Order_Date, src.Ship_Date, src.Ship_Mode, src.Customer_ID, src.Customer_Name, 
            src.Segment, src.Country, src.City, src.State, src.Postal_Code, src.Region, src.Product_ID, src.Category, 
            src.Sub_Category, src.Product_Name, src.Sales, src.Quantity, src.Discount, src.Profit, 
            src.has_missing_value, src.has_invalid_value, src.has_outlier_value
        );

    PRINT '>> Data successfully transformed and loaded into silver.cleansed_superstore.';
END;
GO
