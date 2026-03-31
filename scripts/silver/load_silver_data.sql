/*
===============================================================================
        Stored Procedure: Load Silver Layer (Bronze → Silver)
===============================================================================

Script Purpose:
This stored procedure performs the ETL (Extract, Transform, Load) process
to populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
- Truncates Silver tables (full refresh)
- Cleans, transforms, and standardizes data
- Loads refined data into Silver layer

Parameters: None

Usage: EXEC silver.load_silver;
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		SET @batch_start_time = GETDATE();
		SET @start_time = GETDATE();

		PRINT '=================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=================================================';

		PRINT '-------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------------------';
		
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT '>> Inserting Data into Table: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,

		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 ELSE 'n/a'
		END AS cst_marital_status,  -- Convert marital status codes to readable values

		CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			 ELSE 'n/a'
		END AS cst_gndr,  -- Convert gender codes to readable values

		cst_create_date
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_latest
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
			)t 
		WHERE flag_latest = 1 -- Select the latest record per customer

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '
			  + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			  +' seconds';

		PRINT '-------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT '>> Inserting Data into Table: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info
		(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, -- Extract category ID from product key
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,	   -- Extract product key from source field
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost, -- Replace NULL values with 0
			
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Road'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				 ELSE 'n/a'
			END AS prd_line, -- Convert product line codes to descriptive values

			prd_start_dt,

			DATEADD(
					DAY,
					-1,
					LEAD(prd_start_dt) OVER (
						PARTITION BY prd_key 
						ORDER BY prd_start_dt
						)
					) AS prd_end_dt -- Calculate end date as one day before the next start date.
		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '
			  + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			  + ' seconds';

		PRINT '-------------------------------------------------';
	
		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT '>> Inserting Data into Table: silver.crm_sales_details';
		WITH data_clean AS
		(

		 /* STEP 1:  Normalize numeric values (handle negatives and zeros)
		     - Convert negative values to positive using ABS()
		     - Convert 0 to NULL using NULLIF() */

		 SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			NULLIF(ABS(sls_price),0) AS p,		-- Normalize price
			NULLIF(ABS(sls_quantity),0) AS q,	-- Normalize quantity
			NULLIF(ABS(sls_sales),0) AS s		-- Normalize sales
		 FROM bronze.crm_sales_details
		),

		Fix_price AS
		(

			/* STEP 2: Derive price when missing or invalid
			   Logic:
					If price exists → keep it
					Else if sales & quantity exist → price = sales / quantity */

		SELECT 
			*,
			CASE WHEN p IS NOT NULL THEN p
				 WHEN q IS NOT NULL AND s IS NOT NULL 
					THEN s/NULLIF(q,0)  -- Safe division
			END	AS final_p
		FROM data_clean
		),
		Fix_quantity AS
		(

		/* STEP 3: Derive quantity using corrected price
		   IMPORTANT:
	          Use derived price (final_p) to ensure consistent calculations */

		SELECT 
			*,
			CASE WHEN q IS NOT NULL THEN q
				 WHEN final_p IS NOT NULL AND s IS NOT NULL THEN s/NULLIF(final_p,0)
			END	AS final_q
		FROM Fix_price
		)
		-- STEP 4: Insert cleaned and transformed data into SILVER layer

		INSERT INTO silver.crm_sales_details( 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,

				/* STEP 5: Convert integer to dates (YYYYMMDD → DATE)
			       Handle NULL, 0, and invalid length
			       Use conditional checks to avoid invalid conversions */

			CASE WHEN sls_order_dt <=0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,

			CASE WHEN sls_ship_dt <=0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,

			CASE WHEN sls_due_dt <=0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,

			/* STEP 6: Enforce business rule: sales = quantity × price */

			CASE WHEN final_q IS NOT NULL AND final_p IS NOT NULL 
					THEN final_q * final_p
				 ELSE NULL
			END	AS sls_sales,
			final_q AS sls_quantity,
			final_p AS sls_price
		FROM Fix_quantity;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '
			  + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			  + ' seconds';

		PRINT '-------------------------------------------------';

		PRINT '-------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-------------------------------------------------';
			
		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT '>> Inserting Data into Table: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 

			CASE 
				 WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4 ,LEN(cid)) -- Remove 'NAS' prefix from customer ID if present
				 ELSE cid
			END AS cid,

			CASE 
				 WHEN bdate > GETDATE() THEN NULL  -- Set future birth dates to NULL
				 ELSE bdate
			END AS bdate,

			CASE 
				  WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'	
	 			  WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'	
				  ELSE 'n/a'
			 END AS gen -- Normalize gender values and handle unknown cases

		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '
			  + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			  + ' seconds';

		PRINT '-------------------------------------------------';
	
		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT '>> Inserting Data into Table: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(cid,cntry)
		SELECT 
			REPLACE(cid,'-','') AS cid, -- Remove hyphens from customer ID

			CASE 
				 WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				 WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry  -- Normalize country values and handle missing or blank entries

		 FROM bronze.erp_loc_a101;

		 SET @end_time = GETDATE();

		 PRINT '>> Load Duration: '
			   + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			   + ' seconds';

		PRINT '-------------------------------------------------';
	 
		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT '>> Inserting Data into Table: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		 )
		 SELECT 
			 id,
			 cat,
			 subcat,
			 maintenance
		 FROM bronze.erp_px_cat_g1v2;

		 SET @end_time = GETDATE();

		 PRINT '>> Load Duration: '
			   + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			   + ' seconds';

		 PRINT '-------------------------------------------------';

		 SET @batch_end_time = GETDATE();

		 PRINT '=================================================';
		 PRINT '>> Silver Layer loading completed';
		 PRINT '>> Total Load Duration: '
			   + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)
			   + ' seconds';
		 PRINT '=================================================';
	END TRY

	BEGIN CATCH

		 PRINT '=================================================';
		 PRINT 'Error occurred during Silver Layer Loading';
		 PRINT 'Error Message: ' + ERROR_MESSAGE();
		 PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		 PRINT 'ERROR_STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
		 PRINT '=================================================';

	END CATCH
END
