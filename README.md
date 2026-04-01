# SQL Data Warehouse using Medallion Architecture

## 📌 Project Overview

Built a SQL based data warehouse to centralize raw ERP and CRM data into a structured analytical system using a Medallion Architecture (Bronze, Silver, Gold). Implemented ETL pipelines and data transformations to prepare clean, reliable, and analysis-ready data.

## ❗ Problem Statement

Organizations often store data across multiple systems such as ERP and CRM platforms. This leads to:
- Data inconsistency across sources  
- Difficulty in preparing reliable datasets for analysis  
- Time consuming data cleaning processes  
- Lack of a single source of truth
  
A structured data warehouse is required to consolidate, clean, and standardize data before it can be used for analytics.

## 💡 Solution

To address this, I designed and implemented a **SQL based Data Warehouse** that:
- Integrates raw data from ERP and CRM systems  
- Uses a layered architecture (Bronze → Silver → Gold)  
- Implements ETL pipelines for data transformation  
- Structures data into clean, analysis ready models  
- Ensures consistency through standardized naming conventions  

## 🧱 Architecture

![Data Architecture](https://github.com/user-attachments/assets/e88a4866-dadb-43e8-b974-a6cb1bd24800)

The project follows a **Medallion Architecture** approach:

### 🥉 Bronze Layer (Raw Data)
- Stores raw data ingested from ERP and CRM systems  
- No transformations applied  
- Acts as the source of truth  

### 🥈 Silver Layer (Cleaned & Transformed)
- Data is cleaned, validated, and standardized  
- Handles missing values and inconsistencies  
- Prepares data for modeling  

### 🥇 Gold Layer (Business-Ready Data)
- Data is structured into **fact and dimension tables**  
- SQL views are used to organize and aggregate data  
- Provides clean, reliable datasets ready for downstream analytics

## 🔁 Data Flow

![Data Flow](https://github.com/user-attachments/assets/de473170-1b59-41d1-9b20-e1025864ffad)

### Flow Explanation:
- Data is sourced from ERP (3 tables) and CRM (3 tables) systems.  
- All 6 tables are loaded into the Bronze layer in raw format without any changes.  
- The data is then moved to the Silver layer, where it is cleaned, standardized, and validated.  
- From the Silver layer, data is modeled and organized into the Gold layer as analytical views:  
  - fact_sales → contains transactional/measurable data
  - dim_customers → contains customer details
  - dim_products → contains product information

## 🔄 ETL Process

1. **Extract**
   - Data loaded from ERP and CRM sources into Bronze layer  

2. **Transform**
   - Data cleaned, standardized, and validated in Silver layer  

3. **Load**
   - Data structured into fact and dimension models in Gold layer

## 🗃️ Data Model

![Data Model](https://github.com/user-attachments/assets/d7e855a5-002a-4df1-ba47-ed0c329a0322)

### ⭐ Star Schema (Gold Layer)

The Gold layer follows a **Star Schema** design:

- **Fact Table (`fact_sales`)**
  - Stores transactional data such as sales amount, quantity, pricing, and order details

- **Dimension Tables**
  - `dim_customer` → contains customer-related information  
  - `dim_products` → contains product-related information  

These tables are connected using primary and foreign keys, enabling efficient querying and making the data ready for downstream analytics and reporting.

## 📂 Project Structure

```
sql-data-warehouse-project/
│
├── README.md
├── .gitignore
│
├── data/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── sql/
│   ├── bronze/        # raw data loading
│   ├── silver/        # transformations
│   ├── gold/          # fact, dimension tables & views
│
├── etl/
│   ├── extract.sql
│   ├── transform.sql
│   └── load.sql
│
├── docs/
│   ├── architecture.png
│   ├── data_model.png
```

## 📏 Naming Conventions

To maintain consistency and readability across the data warehouse, the following naming standards are followed:

- All object names use **snake_case** and lowercase letters  
- Bronze and Silver tables follow: `<source>_<table_name>`  
  - Example: `crm_customer_info`, `erp_product_data`  

- Gold layer uses business-friendly naming:
  - Fact tables → `fact_<entity>` (e.g., `fact_sales`)  
  - Dimension tables → `dim_<entity>` (e.g., `dim_customers`)  

- Surrogate keys use `_key` suffix  
  - Example: `customer_key`  

- Metadata columns use `dwh_` prefix  
  - Example: `dwh_load_date`  

> For detailed naming rules, refer to [naming conventions](documents/naming%20conventions.md)

## 📈 Results

- Centralized data from ERP and CRM systems into a single data warehouse  
- Improved data quality through structured cleaning and transformation in the Silver layer  
- Standardized data using consistent naming conventions and modeling practices  
- Built a scalable data model (fact and dimension views) for downstream analytics and BI tools  

## 🛠️ Technologies Used

- T-SQL (SQL Server) for ETL processes, data transformation, and modeling  
- Git & GitHub for version control  

## 🚀 How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/sql-data-warehouse-project.git
   cd sql-data-warehouse-project
   ```

2. Set up SQL Server and create a database:
   ```sql
   CREATE DATABASE data_warehouse;
   ```

3. Execute SQL scripts layer by layer:

   - **Bronze Layer**
     - Run DDL scripts (table creation)
     - Run data load scripts (raw data ingestion)

   - **Silver Layer**
     - Run DDL scripts (cleaned table creation)
     - Run transformation scripts (data cleaning and standardization)

   - **Gold Layer**
     - Run the script to create fact and dimension views

> Each SQL file contains inline comments explaining execution steps.

## 🙌 Acknowledgements
This project was built as part of a hands-on data engineering learning experience inspired by Bara’s Data Warehouse project.
