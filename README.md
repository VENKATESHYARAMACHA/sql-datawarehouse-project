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

The architecture is divided into three layers to improve data quality, performance, and usability.

## 🧱 Architecture

![Data Architecture](https://github.com/user-attachments/assets/e54c5fa9-a2fa-4371-8339-2da1e2b43e5d)

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

## 🔄 ETL Process

1. **Extract**
   - Data loaded from ERP and CRM sources into Bronze layer  

2. **Transform**
   - Data cleaned, standardized, and validated in Silver layer  

3. **Load**
   - Data structured into fact and dimension models in Gold layer

## 🗃️ Data Model

The Gold layer follows a **Star Schema** design:

- **Fact Tables**
  - Store measurable business metrics (prepared for analysis)

- **Dimension Tables**
  - Store descriptive attributes for context

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

To ensure consistency and maintainability, standardized naming conventions were followed:

- Tables: `layer_entity_description`  
  - Example: `silver_customer_cleaned`

- Fact tables: `fact_<business_process>`  
  - Example: `fact_sales`

- Dimension tables: `dim_<entity>`  
  - Example: `dim_customer`

- Views: `vw_<purpose>`  
  - Example: `vw_sales_summary`

## 📈 Results

- Centralized data from multiple sources into a single system  
- Improved data quality through transformation pipelines  
- Standardized and structured data for analytics use cases  
- Created a scalable foundation for downstream reporting and BI tools

## 🛠️ Technologies Used
- SQL  
- (Add your DB: PostgreSQL / MySQL / SQL Server)  
- Git & GitHub  

## 🚀 How to Run

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/sql-data-warehouse-project.git
cd sql-data-warehouse-project
```

---

### 2. Set Up Database
- Install and open your SQL database (PostgreSQL / MySQL / SQL Server)
- Create a new database:
```sql
CREATE DATABASE data_warehouse;
```

---

### 3. Execute SQL Scripts (Follow Order)

#### 🥉 Step 1: Load Bronze Layer (Raw Data)
- Navigate to `/sql/bronze/`
- Run scripts to load raw ERP and CRM data  

---

#### 🥈 Step 2: Transform into Silver Layer
- Navigate to `/sql/silver/`
- Execute scripts to clean and standardize data  

---

#### 🥇 Step 3: Create Gold Layer
- Navigate to `/sql/gold/`
- Run scripts to create:
  - Fact tables  
  - Dimension tables  
  - Views for structured data  

### 📝 Note
Each SQL script contains inline comments explaining execution steps and logic.

## 🙌 Acknowledgements
This project was built as part of a hands-on data engineering learning experience inspired by Bara’s Data Warehouse project.
