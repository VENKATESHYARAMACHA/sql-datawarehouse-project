# Naming Conventions

This document defines the standard naming conventions for schemas, tables, columns, and stored procedures used in the data warehouse.

---

## 1. General Principles

- Use **snake_case** (lowercase letters with underscores `_`).
- Use **English** for all object names.
- Avoid using **SQL reserved keywords**.
- Keep names **clear, consistent, and meaningful**.

---

## 2. Table Naming Conventions

### 2.1 Bronze & Silver Layers

- Preserve source system naming.
- Format:

  <source_system>_<entity>

- Examples:
  - crm_customer_info
  - erp_sales_orders

---

### 2.2 Gold Layer

- Use **business-friendly names** aligned with analytics.
- Format:

  <category>_<entity>

- Categories:
  - dim_ → Dimension tables
  - fact_ → Fact tables
  - report_ → Reporting views (optional)

- Examples:
  - dim_customer
  - dim_product
  - fact_sales

---

## 3. Column Naming Conventions

### 3.1 Surrogate Keys

- Use suffix `_key` for dimension primary keys.

  <table_name>_key

- Example:
  - customer_key

---

### 3.2 Technical Columns

- Use prefix `dwh_` for system-generated metadata.

  dwh_<column_name>

- Example:
  - dwh_create_date

---

## 4. Stored Procedure Naming

- Use consistent naming for data loading procedures.

  load_<layer>
  
- Examples:
  - load_bronze
  - load_silver

---

## 5. Key Guidelines

- Maintain **consistency across all layers**.
- Prefer **singular names** (e.g., dim_customer, not dim_customers).
- Use **descriptive and business-aligned naming** in the Gold layer.

---
