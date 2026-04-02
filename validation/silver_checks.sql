/*
===============================================================================
				Quality Checks – Silver Layer
===============================================================================

Script Purpose:
    This script performs data quality checks on the Silver layer to ensure 
    consistency, accuracy, and standardization of transformed data.

    The checks include:
    - Validation of primary keys (nulls and duplicates)
    - Detection of unwanted leading/trailing spaces in string fields
    - Verification of standardized values
    - Validation of date ranges and logical date relationships
    - Consistency checks across related fields

Usage Notes:
    - Execute this script after loading data into the Silver layer.
    - Review and investigate any records returned by the queries.
    - Resolve identified data issues before proceeding to the Gold layer.

*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No records should be returned

SELECT 
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for leading or trailing spaces
-- Expectation: No records should be returned

SELECT 
    cst_firstname,
	cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);

-- Validate standardized values for marital status

SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No records should be returned

SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for leading or trailing spaces
-- Expectation: No records should be returned

SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No records should be returned

SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- -- Validate standardized values for product_line

SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No records should be returned

SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Date Range Validation (realistic boundaries)
-- Expectation: No records should be returned

SELECT *
FROM silver.crm_sales_details
WHERE 
    (sls_order_dt IS NOT NULL AND 
        (sls_order_dt < '2000-01-01' OR sls_order_dt > GETDATE()))
 OR (sls_ship_dt IS NOT NULL AND sls_order_dt IS NOT NULL AND
		sls_ship_dt > DATEADD(DAY, 30, sls_order_dt))
 OR (sls_due_dt IS NOT NULL AND sls_order_dt IS NOT NULL AND
		sls_due_dt > DATEADD(DAY, 60, sls_order_dt));

-- Date Sequence Validation (Order ≤ Ship ≤ Due)
-- Expectation: No records should be returned

SELECT *
FROM silver.crm_sales_details
WHERE 
    (sls_order_dt IS NOT NULL AND sls_ship_dt IS NOT NULL 
        AND sls_order_dt > sls_ship_dt)
 OR (sls_order_dt IS NOT NULL AND sls_due_dt IS NOT NULL 
        AND sls_order_dt > sls_due_dt)
 OR (sls_ship_dt IS NOT NULL AND sls_due_dt IS NOT NULL 
        AND sls_ship_dt > sls_due_dt);

-- NULL Check on Critical Fields (Completeness)
-- Expectation: No records should be returned

SELECT *
FROM silver.crm_sales_details
WHERE 
    sls_ord_num IS NULL
 OR sls_prd_key IS NULL
 OR sls_cust_id IS NULL
 OR sls_sales IS NULL
 OR sls_quantity IS NULL
 OR sls_price IS NULL;

-- Business Rule Validation (sales = quantity × price (with tolerance))
-- Expectation: No records should be returned

SELECT *
FROM silver.crm_sales_details
WHERE 
    sls_sales IS NOT NULL
 AND sls_quantity IS NOT NULL
 AND sls_price IS NOT NULL
 AND ABS(sls_sales - (sls_quantity * sls_price)) > 0.01;

-- Positive Value Validation
-- Expectation: No records should be returned

SELECT *
FROM silver.crm_sales_details
WHERE 
    (sls_sales IS NOT NULL AND sls_sales <= 0)
 OR (sls_quantity IS NOT NULL AND sls_quantity <= 0)
 OR (sls_price IS NOT NULL AND sls_price <= 0);

-- Duplicate Check (Business Key)
-- Expectation: No records should be returned

SELECT 
    sls_ord_num,
    sls_prd_key,
    COUNT(*) AS record_count
FROM silver.crm_sales_details
GROUP BY 
    sls_ord_num,
    sls_prd_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1900-01-01 and Today

SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1900-01-01' 
   OR bdate > GETDATE();

-- Validate standardized values for gender

SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Validate standardized values for country

SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Check for leading or trailing spaces
-- Expectation: No records should be returned

SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Validate standardized values for maintenance

SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;

