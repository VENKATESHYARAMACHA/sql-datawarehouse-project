/*
===============================================================================
				DDL Script: Create Gold Layer Views
===============================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final presentation layer, structured using a 
    Star Schema (dimension and fact views).

    These views transform and integrate data from the Silver layer to provide 
    a clean, enriched, and business-ready dataset for analytics and reporting.

Usage:
    - These views serve as the primary source for reporting and BI tools.
    - They can be queried directly by analysts and downstream applications.

*/
-- =============================================================================
-- Create Dimension: gold.dim_customer
-- =============================================================================
IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO
CREATE VIEW gold.dim_customer AS
-- Customer Dimension: Combines CRM and ERP data to provide enriched customer attributes
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id, ci.cst_key) AS customer_key, -- Surrogate key
	ci.cst_id		 AS customer_id,
	ci.cst_key		 AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname  AS last_name,
	la.cntry		 AS country,

	-- Use CRM as primary source for gender, fallback to ERP if missing
	CASE 
			WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr 
			ELSE COALESCE(ca.gen,'n/a')             
	END				AS gender,

	ci.cst_marital_status AS marital_status,
	ca.bdate			  AS birth_date,
	ci.cst_create_date	  AS create_date 

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid;
GO

-- =============================================================================
-- Create Dimension: gold.dim_product
-- =============================================================================

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO
CREATE VIEW gold.dim_product AS
-- Product Dimension: Combines product and category data for reporting
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key, -- Surrogate key
	pn.prd_id		AS product_id,
	pn.prd_key		AS product_number,
	pn.prd_nm		AS product_name,
	pn.cat_id		AS category_id,	
	pc.cat			AS category,
	pc.subcat		AS sub_category,
	pc.maintenance  AS maintenance,
	pn.prd_cost		AS product_cost,
	pn.prd_line		AS product_line,
	pn.prd_start_dt AS start_date

FROM silver.crm_prd_info pn

LEFT JOIN silver.erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id

WHERE pn.prd_end_dt IS NULL; -- Keep only active products (exclude historical records)
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
-- Fact Table: Stores transactional sales data linked to dimensions
SELECT 
	sd.sls_ord_num  AS order_number,
	dp.product_key  AS product_key,
	dc.customer_key AS customer_key ,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt  AS shipping_date,
	sd.sls_due_dt   AS due_date,
	sd.sls_sales    AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price    AS price

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_product dp
	ON sd.sls_prd_key = dp.product_number

LEFT JOIN gold.dim_customer dc
	ON sd.sls_cust_id = dc.customer_id;
GO
