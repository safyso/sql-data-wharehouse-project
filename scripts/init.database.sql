/*
===============================================================================
Create Database and Schemas
===============================================================================
Script Purpose:
    This script creates a new database named 'Superstore_DW' after checking 
    if it already exists. If it does not exist, it is created safely. 
    Additionally, the script sets up four schemas within the database: 
    'staging', 'bronze', 'silver', and 'gold'.

NOTE:
    This script uses 'IF NOT EXISTS' logic. It is safe to run multiple times 
    without the risk of dropping the database or losing any existing data.
===============================================================================
*/

-- Create the Superstore_DW database if it does not exist
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Superstore_DW')
    CREATE DATABASE Superstore_DW;
GO
 select * from sys.databases;

-- Use the Superstore_DW database
USE Superstore_DW;
GO

  -- Schemas for the four data warehouse layers
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

