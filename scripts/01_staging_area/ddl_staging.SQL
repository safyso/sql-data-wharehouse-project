/*
===============================================================================
DDL Script: Create Staging Table
===============================================================================
Script Purpose:
    This script creates the 'stg_superstore' table in the 'staging' schema.
    It uses 'IF NOT EXISTS' to ensure the table is only created if it doesn't
    already exist in the database.

NOTE:
    All columns are defined as NVARCHAR(250) to safely accommodate raw data
    from the source CSV file before any transformations are applied.
===============================================================================
*/


-- Create the staging area
        IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'staging' AND t.name = 'stg_superstore')
        BEGIN
        CREATE TABLE staging.stg_superstore (
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
            Profit NVARCHAR(250)
        );
        END

      
   
