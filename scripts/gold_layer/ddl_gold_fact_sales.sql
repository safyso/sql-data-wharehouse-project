/*
===============================================================================
DDL Script: Create Gold Layer Fact Table (fact_sales)
===============================================================================
Script Purpose:
    This script creates the 'fact_sales' table in the 'gold' schema.
    It serves as the central Fact table in the Star Schema, containing 
    performance measures (Sales, Profit, Quantity, Discount) and 
    foreign keys (Surrogate Keys) linking to all dimension tables.
===============================================================================
*/
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'gold' AND t.name = 'fact_sales')
BEGIN
    CREATE TABLE gold.fact_sales (
        
        -- Surrogate Keys
        OrderDateKey INT,
        ShipDateKey INT,
        CustomerKey INT,
        ProductKey INT,
        LocationKey INT,
        ShipModeKey INT,
        OrderKey INT,

        -- Business Key / Traceability
        Row_ID INT,

        -- Measures
        Sales DECIMAL(18, 4),
        Quantity INT,
        Discount DECIMAL(18, 4),
        Profit DECIMAL(18, 4)
    );
    PRINT '>> Table gold.fact_sales created successfully.';
END
ELSE
BEGIN
    PRINT '>> Table gold.fact_sales already exists.';
END
GO
