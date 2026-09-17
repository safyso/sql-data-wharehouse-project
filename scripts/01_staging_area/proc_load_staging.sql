/*
===============================================================================
Stored Procedure: Load Staging Layer (CSV to Staging)
===============================================================================
Script Purpose:
    This stored procedure performs a Full Load operation to refresh the 
    staging table 'staging.stg_superstore' with raw data from the source CSV file.
    
    The process includes:
    1. Truncating the existing staging table to clear old data.
    2. Using BULK INSERT to load fresh raw data from the CSV file.
    3. Error handling using TRY...CATCH to capture and report any load failures.

Parameters:
    None. 
(This stored procedure doesn't accept any parameters)

Usage Example:
    EXEC Staging.load_Staging;
===============================================================================
*/

--create a stored procedure to load data from csv file to staging layer
CREATE OR ALTER PROCEDURE Staging.load_Staging AS
BEGIN
    BEGIN TRY
        PRINT '==========================';
        PRINT 'Loading Staging Layer';
        PRINT '==========================';

        PRINT '>> Truncating Table: staging.stg_superstore';
        TRUNCATE TABLE staging.stg_superstore;

        PRINT '>> Bulk Inserting Data into: staging.stg_superstore';
        BULK INSERT staging.stg_superstore
        FROM 'E:\Central_Superstore.csv'
        WITH (
            FIRSTROW = 2,                  -- skip the header row
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            FORMAT = 'CSV',
            FIELDQUOTE = '"', -- Properly read the comma inside the double quotations
            CODEPAGE = '65001',        -- UTF-8
            MAXERRORS = 0,
            ERRORFILE = 'E:\Central_Superstore_err.log'
        );

        PRINT '>> Staging Layer Loaded Successfully!';
        PRINT '--------------------------';

        SELECT TOP 10 *
        FROM staging.stg_superstore;

    END TRY
    BEGIN CATCH
        PRINT 'ERROR: Failed to load Staging Layer!';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

