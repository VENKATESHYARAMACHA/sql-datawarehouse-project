# SQL Data Warehouse using Medallion Architecture

Building a modern data warehouse using SQL, including ETL processes, data modelling, and analytics ready datasets.

## Project Overview

This project demonstrates the implementation of a data warehouse using the Medallion Architecture approach. The goal is to transform raw data into structured and reliable datasets that can be used for analytics and reporting.

The architecture is divided into three layers to improve data quality, performance, and usability.

## Architecture

### Bronze Layer
The Bronze layer stores raw data as it is received from the source. No major transformations are applied at this stage. It acts as the base layer for all further processing.

### Silver Layer
The Silver layer focuses on data cleaning and standardisation. In this layer, data is processed to remove inconsistencies, handle missing values, and ensure a structured format.

### Gold Layer
The Gold layer contains business ready data. It includes aggregated and transformed datasets that can be directly used for reporting, dashboards, and analysis.
