/*
==========================================================
Stored Procedure: Load Bronze Layer (Source → Bronze)
==========================================================

Script Purpose:
This stored procedure loads raw data into the 'bronze' schema from external CSV files.

The Bronze layer represents the raw data layer where data is ingested 
from source systems (CRM and ERP) without any transformations.

The procedure performs the following actions:
- Truncates existing data in bronze tables
- Loads fresh data using BULK INSERT from CSV files

Parameters:
- None

Usage:
EXEC bronze.load_bronze;
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		-- Defining reusable File Paths
		DECLARE @crm_path NVARCHAR(200) = 'E:\Venkatesh\1. SQL\Baraa\sql-data-warehouse-project\data\source_crm\';
		DECLARE @erp_path NVARCHAR(200) = 'E:\Venkatesh\1. SQL\Baraa\sql-data-warehouse-project\data\source_erp\';
		DECLARE @sql NVARCHAR(MAX);

		SET @batch_start_time = GETDATE();
		PRINT '===============================================';
		PRINT 'Loading Bronze Layer:';
		PRINT '===============================================';

		PRINT '-----------------------------------------------';
		PRINT 'Loading CRM Tables:';
		PRINT '-----------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table:bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data into : bronze.crm_cust_info';

		SET @sql = '
			BULK INSERT bronze.crm_cust_info
			FROM ''' + @crm_path + 'cust_info.csv''
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			TABLOCK
			);';

		EXEC(@sql);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'

		PRINT '-----------------------------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data into : bronze.crm_prd_info';

		SET @sql = '
			BULK INSERT bronze.crm_prd_info
			FROM ''' + @crm_path + 'prd_info.csv''
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			TABLOCK
			);';

		EXEC(@sql);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'

		PRINT '-----------------------------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table:bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data into :bronze.crm_sales_details';

		SET @sql = '
			BULK INSERT bronze.crm_sales_details
			FROM ''' + @crm_path + 'sales_details.csv''
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			TABLOCK
			);';

		EXEC(@sql);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'

		PRINT '-----------------------------------------------'

		PRINT '-----------------------------------------------';
		PRINT 'Loading ERP Tables:';
		PRINT '-----------------------------------------------';


		SET @start_time = GETDATE();

		PRINT '>> Truncating Table:bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Data into :bronze.erp_cust_az12';

		SET @sql = '
			BULK INSERT bronze.erp_cust_az12
			FROM ''' + @erp_path + 'CUST_AZ12.csv''
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			TABLOCK
			);';

		EXEC(@sql);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'

		PRINT '-----------------------------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table:bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data into :bronze.erp_loc_a101';

		SET @sql = '
			BULK INSERT bronze.erp_loc_a101
			FROM ''' + @erp_path + 'LOC_A101.csv''
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			TABLOCK
			);';

		EXEC(@sql);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'

		PRINT '-----------------------------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table:bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data into :bronze.erp_px_cat_g1v2';

		SET @sql = '
			BULK INSERT bronze.erp_px_cat_g1v2
			FROM ''' + @erp_path + 'PX_CAT_G1V2.csv''
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			TABLOCK
			);';

		EXEC(@sql);

		SET @end_time = GETDATE();

		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'

		PRINT '-----------------------------------------------'

		SET @batch_end_time = GETDATE();

		PRINT '===============================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '>> Total Duration: '+ CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds'
		PRINT '==============================================='; 

	END TRY
	BEGIN CATCH

		PRINT '===============================================';
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE:' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER:'  + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE:'   + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===============================================';

	END CATCH

END
