
# Retail Sales & Customer Insights — Advanced SQL Project

---

**Objective:** Built a complete SQL analytics solution on MySQL: modeled schema, loaded 4 CSVs (~2000 orders, 3947 lines). Delivered RFM/ABC analyses, window-function insights, CLV view, and a stored procedure for top-N profitability. Deployed on GitHub with documentation and reproducible SQL scripts. This project demonstrating advanced skills: data modeling, data loading, cleaning, analysis with **window functions, CTEs**, RFM, ABC, profitability, and stored procedures

---

## Project Structure
```
Retail-SQL-Analytics-Project/
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── orders.csv
│   └── order_details.csv
├── sql_scripts/
    ├── 01_create_tables.sql
    ├── 02_load_data.sql
    ├── 03_data_cleaning.sql
    ├── 04_analysis_queries.sql
    └── 05_views_procedures.sql

```
---

## Dataset description
- **Time range:** 2023-01-01 to 2025-08-15 with seasonality and weekend boosts.
- **Integrity:** Foreign keys ensure consistency between orders and details.
- **Economics:** `price >= cost` enforced; profits derived in views.

---

## How to Run (MySQL 8+)
1. Create a database user with permission to load local files.
2. In MySQL client, run:
   ```sql
   SOURCE sql_scripts/01_create_tables.sql;
   ```
3. Enable local infile if needed:
   ```sql
   SHOW VARIABLES LIKE 'local_infile';
   SET GLOBAL local_infile = 1;
   ```
4. Load data (adjust paths if needed):
   ```sql
   SOURCE sql_scripts/02_load_data.sql;
   ```
5. Cleaning & Derived Views:
   ```sql
   SOURCE sql_scripts/03_data_cleaning.sql;
   ```
6. Run analysis:
   ```sql
   SOURCE sql_scripts/04_analysis_queries.sql;
   ```
7. Create views, procedures, triggers:
   ```sql
   SOURCE sql_scripts/05_views_procedures.sql;
   ```
---

> **Tip:** If `LOAD DATA LOCAL INFILE` fails, you can import CSVs using your MySQL GUI (Workbench) into the tables created by `01_create_tables.sql`.


## What This Demonstrates
- Designed relational schema and indexes for a retail analytics warehouse.
- Built ETL-style ingestion with CSVs and `LOAD DATA` for performance.
- Wrote advanced SQL using **CTEs, window functions (RANK, LAG, NTILE)**, dynamic date filters.
- Implemented **RFM segmentation**, **ABC analysis**, and **profitability** metrics.
- Created reusable **views** and a **stored procedure**; added a **trigger** for data integrity.
- Produced monthly trend, top-N, churn detection, category margins, and CLV.

---

## Future work: Visualization
Export results to **Power BI/Tableau** for charts:
- Monthly revenue & profit trend
- Top products & customers
- RFM segment distribution
- Margin by category & month

---
