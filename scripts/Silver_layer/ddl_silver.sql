/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema.
    It defines the structure for cleansed and standardized data, utilizing proper 
    data types (e.g., DATE, DECIMAL) and incorporates Data Quality flags.
    Run this script to re-define the DDL structure of 'silver' tables.
===============================================================================
*/
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'silver' AND t.name = 'cleansed_superstore')
BEGIN
    CREATE TABLE silver.cleansed_superstore (
        Row_ID INT NOT NULL,
        Order_ID NVARCHAR(50),
        Order_Date DATE,
        Ship_Date DATE,
        Ship_Mode NVARCHAR(50),
        Customer_ID NVARCHAR(50),
        Customer_Name NVARCHAR(100),
        Segment NVARCHAR(50),
        Country NVARCHAR(50),
        City NVARCHAR(50),
        State NVARCHAR(50),
        Postal_Code NVARCHAR(50),
        Region NVARCHAR(50),
        Product_ID NVARCHAR(50),
        Category NVARCHAR(50),
        Sub_Category NVARCHAR(50),
        Product_Name NVARCHAR(250),
        Sales DECIMAL(18, 4),
        Quantity INT,
        Discount DECIMAL(18, 4),
        Profit DECIMAL(18, 4),
        -- Data Quality Flags 
        has_missing_value BIT NOT NULL DEFAULT 0,
        has_invalid_value BIT NOT NULL DEFAULT 0,
        has_outlier_value BIT NOT NULL DEFAULT 0,
        CONSTRAINT PK_silver_superstore PRIMARY KEY (Row_ID)
    );
    PRINT '>> Table silver.cleansed_superstore created successfully.';
END;
GO
