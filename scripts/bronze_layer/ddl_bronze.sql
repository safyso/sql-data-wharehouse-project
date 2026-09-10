/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' tables.
===============================================================================
*/

IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'bronze' AND t.name = 'raw_superstore')
BEGIN
CREATE TABLE bronze.raw_superstore (
    bronze_id INT IDENTITY(1,1) PRIMARY KEY,
    Row_ID NVARCHAR(250),
    Order_ID NVARCHAR(250),
    Order_Date NVARCHAR(250),
    Ship_Date NVARCHAR(250),
    Ship_Mode NVARCHAR(250),
    Customer_ID NVARCHAR(250),
    Customer_Name NVARCHAR(250),
    Segment NVARCHAR(250),
    Country NVARCHAR(250),
    City NVARCHAR(250),
    State NVARCHAR(250),
    Postal_Code NVARCHAR(250),
    Region NVARCHAR(250),
    Product_ID NVARCHAR(250),
    Category NVARCHAR(250),
    Sub_Category NVARCHAR(250),
    Product_Name NVARCHAR(250),
    Sales NVARCHAR(250),
    Quantity NVARCHAR(250),
    Discount NVARCHAR(250),
    Profit NVARCHAR(250));
END
GO
