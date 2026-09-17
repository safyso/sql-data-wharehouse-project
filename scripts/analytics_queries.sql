
/*
===============================================================================
Advanced Analytical Queries (Business Scenarios)
===============================================================================
Script Purpose:
    This script contains 15 advanced SQL queries designed to analyze 
    profitability, customer behavior, and sales trends.
    It fulfills the project requirements using Joins, CTEs, Subqueries, 
    CASE statements, and Window Functions.
===============================================================================
*/

-- ============================================================================
-- 1. Customer Profitability Classification (CTE & CASE Statement)
-- ============================================================================
WITH CustomerProfitability AS (
    SELECT 
        Customer_Name, 
        SUM(Sales) AS Total_Sales, 
        SUM(Profit) AS Total_Profit
    FROM gold.vw_fact_sales_report
    GROUP BY Customer_Name
)
SELECT 
    Customer_Name, 
    Total_Sales, 
    Total_Profit,
    CASE 
        WHEN Total_Profit > 1000 THEN 'VIP / High Value'
        WHEN Total_Profit > 0 AND Total_Profit <= 1000 THEN 'Standard / Medium Value'
        ELSE 'Loss Making'
    END AS Customer_Category
FROM CustomerProfitability
ORDER BY Total_Profit DESC;

-- ============================================================================
-- 2. Products with Above-Average Sales (Subquery)
-- ============================================================================
SELECT 
    Product_Name, 
    Category,
    SUM(Sales) AS Total_Sales
FROM gold.vw_fact_sales_report
GROUP BY Product_Name, Category
HAVING SUM(Sales) > (SELECT AVG(Sales) FROM gold.vw_fact_sales_report)
ORDER BY Total_Sales DESC;

-- ============================================================================
-- 3. State Profitability Ranking (JOIN & CTE)
-- ============================================================================
WITH StatePerformance AS (
    SELECT 
        l.State, 
        SUM(f.Profit) AS Total_Profit
    FROM gold.fact_sales f
    JOIN gold.dim_location l ON f.LocationKey = l.LocationKey
    GROUP BY l.State
)
SELECT * FROM StatePerformance
ORDER BY Total_Profit DESC;

-- ============================================================================
-- 4. Top 5 Most Profitable Cities (Sales Trends)
-- ============================================================================
SELECT TOP 5
    City,
    State,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM gold.vw_fact_sales_report
GROUP BY City, State
ORDER BY Total_Profit DESC;

-- ============================================================================
-- 5. Yearly and Quarterly Sales Trends
-- ============================================================================
SELECT 
    Order_Year,
    DATEPART(QUARTER, Order_Date) AS Quarter_Number,
    SUM(Sales) AS Total_Sales,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM gold.vw_fact_sales_report
GROUP BY Order_Year, DATEPART(QUARTER, Order_Date)
ORDER BY Order_Year, Quarter_Number;

-- ============================================================================
-- 6. Customer Behavior: Order Count by Segment
-- ============================================================================
SELECT 
    Segment,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Segment_Sales
FROM gold.vw_fact_sales_report
GROUP BY Segment
ORDER BY Total_Segment_Sales DESC;

-- ============================================================================
-- 7. Sub-Category Performance (CASE Statement)
-- ============================================================================
SELECT 
    Sub_Category,
    SUM(Profit) AS Total_Profit,
    CASE 
        WHEN SUM(Profit) >= 5000 THEN 'Excellent'
        WHEN SUM(Profit) >= 1000 AND SUM(Profit) < 5000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS Performance_Rating
FROM gold.vw_fact_sales_report
GROUP BY Sub_Category
ORDER BY Total_Profit DESC;

-- ============================================================================
-- 8. Impact of Discount on Profitability 
-- ============================================================================
SELECT 
    f.Discount,
    COUNT(f.Row_ID) AS Number_Of_Transactions,
    SUM(f.Sales) AS Total_Sales,
    SUM(f.Profit) AS Total_Profit
FROM gold.fact_sales f
JOIN gold.dim_product p ON f.ProductKey = p.ProductKey
GROUP BY f.Discount
ORDER BY f.Discount ASC;

-- ============================================================================
-- 9. Shipping Mode Efficiency
-- ============================================================================
SELECT 
    Ship_Mode,
    AVG(Sales) AS Average_Sales_Per_Order,
    SUM(Quantity) AS Total_Quantity_Shipped
FROM gold.vw_fact_sales_report
GROUP BY Ship_Mode
ORDER BY Total_Quantity_Shipped DESC;

-- ============================================================================
-- 10. Loss-Making Orders Analysis (Filtering & Analysis)
-- ============================================================================
SELECT 
    Order_ID,
    Customer_Name,
    State,
    Sales,
    Profit,
    Discount
FROM gold.vw_fact_sales_report
WHERE Profit < 0
ORDER BY Profit ASC; -- ASC brings the biggest losses to the top

-- ============================================================================
-- 11. Top 3 Customers per Region (Window Function - Advanced)
-- ============================================================================
WITH CustomerRanks AS (
    SELECT 
        Region,
        Customer_Name,
        SUM(Sales) AS Total_Sales,
        ROW_NUMBER() OVER(PARTITION BY Region ORDER BY SUM(Sales) DESC) AS Rank_In_Region
    FROM gold.vw_fact_sales_report
    GROUP BY Region, Customer_Name
)
SELECT * 
FROM CustomerRanks
WHERE Rank_In_Region <= 3;

-- ============================================================================
-- 12. Year-Over-Year (YoY) Sales Growth (Window Function)
-- ============================================================================
WITH YearlySales AS (
    SELECT 
        Order_Year,
        SUM(Sales) AS Current_Year_Sales
    FROM gold.vw_fact_sales_report
    GROUP BY Order_Year
)
SELECT 
    Order_Year,
    Current_Year_Sales,
    LAG(Current_Year_Sales, 1) OVER (ORDER BY Order_Year) AS Previous_Year_Sales,
    Current_Year_Sales - LAG(Current_Year_Sales, 1) OVER (ORDER BY Order_Year) AS YoY_Difference
FROM YearlySales;

-- ============================================================================
-- 13. Average Quantity Sold per Category
-- ============================================================================
SELECT 
    Category,
    AVG(CAST(Quantity AS DECIMAL(10,2))) AS Avg_Quantity_Per_Transaction
FROM gold.vw_fact_sales_report
GROUP BY Category
ORDER BY Avg_Quantity_Per_Transaction DESC;

-- ============================================================================
-- 14. Customers who ordered more than 10 times (Subquery in WHERE)
-- ============================================================================
SELECT 
    Customer_ID,
    Customer_Name,
    Segment
FROM gold.dim_customer
WHERE Customer_ID IN (
    SELECT Customer_ID
    FROM gold.vw_fact_sales_report
    GROUP BY Customer_ID
    HAVING COUNT(DISTINCT Order_ID) > 10
);

-- ============================================================================
-- 15. Summary of Overall Metrics (Quick KPI check)
-- ============================================================================
SELECT 
    COUNT(DISTINCT Order_ID) AS Total_Orders_Ever,
    SUM(Sales) AS Total_Sales_Ever,
    SUM(Profit) AS Total_Profit_Ever,
    COUNT(DISTINCT Customer_ID) AS Total_Unique_Customers
FROM gold.vw_fact_sales_report;
GO

