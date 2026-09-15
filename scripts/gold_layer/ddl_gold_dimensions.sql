/*
===============================================================================
DDL Script: Create Gold Layer Dimension Tables
===============================================================================
Script Purpose:
    This script creates all dimension tables in the 'gold' schema:
      - dim_customer, dim_product, dim_location, dim_ship_mode, dim_order, dim_date
    Each table uses an INT IDENTITY column as a Surrogate Key (except DateKey).
===============================================================================
*/


-- Create the Customer Dimension Table
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'gold' AND t.name = 'dim_customer')
BEGIN
    CREATE TABLE gold.dim_customer (
        CustomerKey INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key 
        Customer_ID NVARCHAR(50) NOT NULL,         -- Business Key 
        Customer_Name NVARCHAR(100),
        Segment NVARCHAR(50)
    );
    PRINT '>> Table gold.dim_customer created successfully.';
END
ELSE
BEGIN
    PRINT '>> Table gold.dim_customer already exists.';
END
GO

--1.Create Product Dimension Table
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'gold' AND t.name = 'dim_product')
BEGIN
    CREATE TABLE gold.dim_product (
        ProductKey INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
        Product_ID NVARCHAR(50) NOT NULL,         -- Business Key
        Product_Name NVARCHAR(250),
        Category NVARCHAR(50),
        Sub_Category NVARCHAR(50)
    );
    PRINT '>> Table gold.dim_product created successfully.';
END
ELSE
BEGIN
    PRINT '>> Table gold.dim_product already exists.';
END
GO

-- 2. Create Location Dimension Table
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'gold' AND t.name = 'dim_location')
BEGIN
    CREATE TABLE gold.dim_location (
        LocationKey INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
        Country NVARCHAR(50),
        Region NVARCHAR(50),
        State NVARCHAR(50),
        City NVARCHAR(50),
        Postal_Code NVARCHAR(50)
    );
    PRINT '>> Table gold.dim_location created successfully.';
END
ELSE
BEGIN
    PRINT '>> Table gold.dim_location already exists.';
END
GO

-- 3. Create Ship Mode Dimension Table
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'gold' AND t.name = 'dim_ship_mode')
BEGIN
    CREATE TABLE gold.dim_ship_mode (
        ShipModeKey INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
        Ship_Mode NVARCHAR(50) NOT NULL
    );
    PRINT '>> Table gold.dim_ship_mode created successfully.';
END
ELSE
BEGIN
    PRINT '>> Table gold.dim_ship_mode already exists.';
END
GO

-- 4. Create Order Dimension Table
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'gold' AND t.name = 'dim_order')
BEGIN
    CREATE TABLE gold.dim_order (
        OrderKey INT IDENTITY(1,1) PRIMARY KEY,    -- Surrogate Key
        Order_ID NVARCHAR(50) NOT NULL             -- Business Key
    );
    PRINT '>> Table gold.dim_order created successfully.';
END
ELSE
BEGIN
    PRINT '>> Table gold.dim_order already exists.';
END
GO

-- 5. Create Date Dimension Table
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'gold' AND t.name = 'dim_date')
BEGIN
    CREATE TABLE gold.dim_date (
        DateKey INT PRIMARY KEY,                   -- Standard Date Surrogate Key (e.g., 20260915)
        FullDate DATE NOT NULL,
        Calendar_Year INT,
        Calendar_Quarter INT,
        Calendar_Month INT,
        Calendar_MonthName NVARCHAR(20),
        Calendar_Day INT,
        Calendar_DayOfWeek NVARCHAR(20)
    );
    PRINT '>> Table gold.dim_date created successfully.';
END
ELSE
BEGIN
    PRINT '>> Table gold.dim_date already exists.';
END
GO
