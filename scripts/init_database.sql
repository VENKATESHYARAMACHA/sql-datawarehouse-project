/*
----------------------------------------------------------------------------------------------
                            Create Database and Schemas
----------------------------------------------------------------------------------------------
Script Purpose:
This script creates a new database named 'DataWareHouse'. 
If the database already exists, it will be dropped and recreated.

Additionally, the script creates three schemas within the database:
- bronze
- silver
- gold

WARNING:
Running this script will permanently delete the existing 'DataWareHouse' database (if it exists).
All data will be lost. Please ensure you have proper backups before executing this script.
*/

USE master;
GO

--Drop and recreate the  'DataWareHouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse')
BEGIN
	ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWareHouse;
END;
GO

--Create the 'DataWareHouse' Database:
CREATE DATABASE DataWareHouse;
GO

USE DataWareHouse;
GO

--Create schemas:
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
Go
CREATE SCHEMA gold;
GO
