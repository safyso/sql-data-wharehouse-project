# 📊 Central Superstore Data Warehouse - Medallion Architecture 🚀

Hello friends! 👋 Welcome to my Central Superstore Data Warehouse project repository. This project is built to transform raw operational retail data into a structured analytical relational database for executive reporting and KPI monitoring.

---

## 🏢 Business Scenario
A retail organization wants to transform its operational data into an analytical relational database for executive reporting and KPI monitoring. The goal is to build a robust, secure, and easily queryable Data Warehouse that serves Business Intelligence (BI) tools and empowers Data Analysts to perform Exploratory Data Analysis (EDA) efficiently using Python and Pandas.

---

## 🏗️ Architecture Design (Medallion Architecture)

The data pipeline is designed across four distinct layers to ensure data quality and progressive transformation:

1. **Staging Area (`01_staging_area`):** Acts as the initial landing zone for raw data (imported as `NVARCHAR` to prevent data-type collisions).
2. **Bronze Layer (`02_bronze_layer`):** Stores the raw, unprocessed data as a historical baseline.
3. **Silver Layer (`03_silver_layer`):** The cleansed and conformed layer where data types are cast, NULLs are handled, and basic transformations are applied.
4. **Gold Layer (`04_gold_layer`):** The presentation layer modeled as a **Virtual Star Schema**. 
   - **Data Security:** Built using Virtual Views to restrict direct database modifications.
   - **Master Report View:** Includes `vw_fact_sales_report` designed for seamless Python/Pandas EDA.

[<img width="951" height="693" alt="Screenshot 2026-09-21 165335" src="https://github.com/user-attachments/assets/62472276-45e3-4997-91bb-e1519e0d2588" />
]

---

## 📋 Required Tasks & Technical Requirements

This project successfully fulfills and exceeds all required technical specifications:

* ✅ **Tables & Modeling:** Normalized dataset into fact and dimension tables (Star Schema) with proper PK/FK relationships.
* ✅ **Advanced SQL:** Includes analytical queries (`05_analytics_queries.sql`) utilizing JOINs, Subqueries, CASE statements, and CTEs.
* ✅ **Programmability:** Developed dynamic stored procedures and SQL views for KPI calculations.
* ✅ **Reporting & Optimization:** Created optimized analytical reports for profitability, customer behavior, and sales trends.
* ✅ **Data Quality & Testing:** Implemented a dedicated `tests` folder for End-to-End pipeline execution and data integrity checks.

---

## 📂 Repository Structure

```text
📦 central-superstore-data-warehouse
 ┣ 📂 01_staging_area       # DDL and ETL scripts for the Staging layer
 ┣ 📂 02_bronze_layer       # DDL and ETL scripts for the Bronze layer
 ┣ 📂 03_silver_layer       # DDL and ETL scripts for the Silver layer
 ┣ 📂 04_gold_layer         # Virtual Star Schema (Views) & Dynamic KPI Procedures
 ┣ 📂 tests                 # End-to-End Pipeline Execution & Data Quality Checks
 ┣ 📜 05_analytics_queries.sql # Advanced analytical SQL queries
 ┗ 📜 README.md             # Project documentation
