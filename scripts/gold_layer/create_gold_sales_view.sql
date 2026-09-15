/*
===============================================================================
View: Gold Sales Analytics View (Python-Optimized)
===============================================================================
Script Purpose:
    This view combines the central fact_sales table with all dimension tables 
    to provide a denormalized, business-ready dataset. It is specifically 
    optimized for seamless integration with Python environments (e.g., Pandas, 
    NumPy) to facilitate Exploratory Data Analysis (EDA), feature engineering, 
    and advanced analytics.
===============================================================================
*/

CREATE OR ALTER VIEW gold.vw_fact_sales_report AS
SELECT 
    -- Fact measures and identifiers
    f.Row_ID,
    f.Sales,
    f.Quantity,
    f.Discount,
    f.Profit,

    -- Date dimensions
    d_order.FullDate AS Order_Date,
    d_order.Calendar_Year AS Order_Year,
    d_order.Calendar_MonthName AS Order_Month,
    d_ship.FullDate AS Ship_Date,

    -- Customer dimensions
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,

    -- Product dimensions
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,

    -- Location dimensions
    l.Country,
    l.Region,
    l.State,
    l.City,
    l.Postal_Code,

    -- Ship Mode dimension
    sm.Ship_Mode,

    -- Order dimension
    o.Order_ID

FROM gold.fact_sales f
LEFT JOIN gold.dim_date d_order ON f.OrderDateKey = d_order.DateKey
LEFT JOIN gold.dim_date d_ship ON f.ShipDateKey = d_ship.DateKey
LEFT JOIN gold.dim_customer c ON f.CustomerKey = c.CustomerKey
LEFT JOIN gold.dim_product p ON f.ProductKey = p.ProductKey
LEFT JOIN gold.dim_location l ON f.LocationKey = l.LocationKey
LEFT JOIN gold.dim_ship_mode sm ON f.ShipModeKey = sm.ShipModeKey
LEFT JOIN gold.dim_order o ON f.OrderKey = o.OrderKey;
GO
