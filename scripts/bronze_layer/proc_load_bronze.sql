/*
===============================================================================
Stored Procedure: Load Bronze Layer (Staging to Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads raw data from the 'staging' schema into 
    the 'bronze' schema table ('bronze.raw_superstore').
    It performs an incremental load by inserting only new, non-existing records 
    using the EXCEPT operator.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    BEGIN TRY
        PRINT '==========================';
        PRINT 'Loading Bronze Layer';
        PRINT '==========================';

        PRINT '>> Inserting new records from Staging to Bronze...';

        --- Insert only new records from staging to bronze layer
        INSERT INTO bronze.raw_superstore (
            Row_ID,
            Order_ID,
            Order_Date,
            Ship_Date,
            Ship_Mode,
            Customer_ID,
            Customer_Name,
            Segment,
            Country,
            City,
            State,
            Postal_Code,
            Region,
            Product_ID,
            Category,
            Sub_Category,
            Product_Name,
            Sales,
            Quantity,
            Discount,
            Profit
        )
        SELECT
            Row_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,
            State,Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales,Quantity,Discount,Profit
        FROM staging.stg_superstore
        EXCEPT
        SELECT
            Row_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,
            State,Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales,Quantity,Discount,Profit
        FROM bronze.raw_superstore;

        PRINT '>> Bronze Layer Loaded Successfully!';
        PRINT '==========================';

    END TRY
    BEGIN CATCH
        PRINT 'ERROR: Failed to load Bronze Layer!';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
