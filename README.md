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
  - dim_customer → contains customer details
  - dim_product → contains product information

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
  - `dim_product` → contains product-related information  

These tables are connected using primary and foreign keys, enabling efficient querying and making the data ready for downstream analytics and reporting.

## 📂 Project Structure

```
data-warehouse-project/
│
├── data/                             # Raw source data used for the project
│ ├── source_crm/                     # CRM system data files (customers, products, sales)
│ ├── source_erp/                     # ERP system data files (customer info, locations, categories)
│
├── docs/                             # Project documentation and diagrams
│ ├── data_architecture.jpg           # High-level architecture of the data warehouse
│ ├── data_flow.jpg                   # ETL flow (Bronze → Silver → Gold)
│ ├── data_model.jpg                  # Star schema (fact and dimension design)
│ ├── naming_conventions.md           # Rules for naming tables, columns, and objects
│
├── scripts/                          # SQL scripts for building the data warehouse
│
│ ├── create_database.sql             # Creates database and schemas (bronze, silver, gold)
│ 
│ ├── bronze/                         # Bronze layer (raw data ingestion)
│ │ ├── create_bronze_tables.sql      # Defines raw tables exactly as source structure (no transformations)
│ │ └── load_bronze_data.sql          # Loads data from source files into bronze tables
│
│ ├── silver/                         # Silver layer (cleaned and transformed data)
│ │ ├── create_silver_tables.sql      # Creates cleaned tables with corrected data types and metadata columns
│ │ └── load_silver_data.sql          # Transforms bronze data (cleaning, standardization, business logic)
│
│ ├── gold/                           # Gold layer (business-ready data model)
│ │ └── create_gold_views.sql         # Creates dimension and fact views (star schema)
│
├── validation/                       # Data quality and validation scripts
│ ├── silver_checks.sql               # Validates silver layer (NULLs, duplicates, business rules)
│ └── gold_checks.sql                 # Validates gold layer (key integrity, relationships)
│
├── README.md                         # Project overview and execution steps
└── LICENSE                           # License information
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

> For detailed naming rules, refer to [naming conventions](documents/naming_conventions.md)

## 📈 Results

- Centralized data from ERP and CRM systems into a single data warehouse  
- Improved data quality through structured cleaning and transformation in the Silver layer  
- Standardized data using consistent naming conventions and modeling practices  
- Built a scalable data model (fact and dimension views) for downstream analytics and BI tools  

## 🛠️ Technologies Used

- T-SQL (SQL Server) for ETL processes, data transformation, and modeling  
- Git & GitHub for version control  

## 🚀 How to Run

### 1. Clone the repository
```bash
git clone https://github.com/VENKATESHYARAMACHA/sql-datawarehouse-project.git
cd sql-datawarehouse-project
```
### 2. Open SQL Server Management Studio (SSMS)
     - Connect to your SQL Server
     - Open a new query window
### 3. Run scripts in order
```SQL
  -- Setup
scripts/setup/create_database.sql
```
```SQL
-- Bronze Layer
scripts/bronze/create_bronze_tables.sql
scripts/bronze/load_bronze_data.sql
```
```SQL
-- Silver Layer
scripts/silver/create_silver_tables.sql
scripts/silver/load_silver_data.sql
```
```SQL
-- Gold Layer
scripts/gold/create_gold_views.sql
```

```SQL
-- Validation (Optional)
validation/silver_checks.sql
validation/gold_checks.sql
```
📌 Notes
- Execute scripts sequentially: setup → bronze → silver → gold
- Update file paths in BULK INSERT based on your local system
- Each script includes inline comments for guidance

## Key Learnings

This project strengthened my understanding of:

• Medallion Architecture

• ETL design

• Data validation

• Dimensional modelling

• SQL Server scripting

• Star schema design

## 🙌 Acknowledgements

The implementation approach adopted in this project was inspired by industry standard data warehousing practices and the Data Warehouse project shared by Dr. Bara.
This project was independently developed to deepen my practical understanding of SQL based data warehousing, ETL processes, dimensional modelling and analytics ready data platforms.
