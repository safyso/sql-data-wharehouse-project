/*
=============================================================================
Script Purpose:
    End-to-End Pipeline Execution Test.
    This script tests the execution of all stored procedures sequentially 
    (Staging -> Bronze -> Silver) and tests the Gold Layer Views and Reports.
=============================================================================
*/

USE Superstore_DW;
GO

PRINT '==================================================';
PRINT ' 1. Testing Staging Layer Load';
PRINT '==================================================';
-- Execute staging load procedure
EXEC staging.load_staging; 
GO

PRINT '==================================================';
PRINT ' 2. Testing Bronze Layer Load';
PRINT '==================================================';
-- Execute bronze load procedure
EXEC bronze.load_bronze;
GO

PRINT '==================================================';
PRINT ' 3. Testing Silver Layer Load';
PRINT '==================================================';
-- Execute silver load procedure
EXEC silver.load_silver;
GO

PRINT '==================================================';
PRINT ' 4. Testing Gold Layer (Master View Output)';
PRINT '==================================================';
-- Verify the master view by selecting the top 5 rows
SELECT TOP 5 * 
FROM gold.vw_fact_sales_report;
GO

PRINT '==================================================';
PRINT ' 5. Testing Gold Layer (Dynamic KPI Report)';
PRINT '==================================================';
-- Test the dynamic KPI stored procedure for the year 2013
EXEC gold.calc_yearly_kpis @TargetYear = 2013;
GO

PRINT '==================================================';
PRINT ' Pipeline Execution Test Completed Successfully!';
PRINT '===
