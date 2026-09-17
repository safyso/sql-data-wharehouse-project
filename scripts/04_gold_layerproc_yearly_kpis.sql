/*
=============================================================================
Script Purpose:
    Creates a dynamic stored procedure to calculate yearly KPIs 
    (Total Orders, Sales, Profit, and Profit Margin) for a specific year.

Usage Example:
    EXEC gold.calc_yearly_kpis @TargetYear = 2013;
=============================================================================
*/
CREATE OR ALTER PROCEDURE gold.calc_yearly_kpis
    @TargetYear INT
AS
BEGIN
    SELECT 
        @TargetYear AS Report_Year,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit,
        -- Calculate Profit Margin % and handle division by zero
        CAST((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100 AS DECIMAL(10,2)) AS Profit_Margin_Percentage
    FROM gold.vw_fact_sales_report
    WHERE Order_Year = @TargetYear;
END;
GO
