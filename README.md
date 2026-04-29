# 📊 Retail Data Warehouse and ETL Project

This project was completed for the **IT3021 - Data Warehousing and Business Intelligence** module at **Sri Lanka Institute of Information Technology (SLIIT)**.

## 🚀 Project Overview

This project demonstrates the design and implementation of a **Retail Data Warehouse** using **SQL Server** and **SSIS**.

The project focuses on preparing retail source data, loading it into staging tables, designing a Star Schema data warehouse, implementing ETL workflows, applying Slowly Changing Dimension logic, and updating an accumulating fact table.

## 🛠️ Tools and Technologies

- Microsoft SQL Server
- SQL Server Management Studio
- SQL Server Integration Services
- SQL Server Data Tools / Visual Studio
- ETL
- Star Schema
- Slowly Changing Dimension Type 2
- Fact and Dimension Tables
- CSV and Excel Data Sources

## 📁 Dataset

The original retail dataset contained combined information about:

- Customers
- Orders
- Products
- Transactions
- Shipping methods
- Payment methods
- Feedback and ratings
- Sales amounts

The original dataset was separated into multiple sources before ETL processing.

## 🔗 Data Sources

| Source | Type | Description |
|---|---|---|
| `SrcRetailOrders` | SQL Server Table | Order and transaction data |
| `Customer_Master.csv` | CSV File | Customer master data |
| `Product_Master.xlsx` | Excel File | Product master and hierarchy data |
| `txn_completion_updates.csv` | CSV File | Transaction completion updates |

## 🗄️ Databases Used

| Database | Purpose |
|---|---|
| `Retail_SourceDB2` | Stores prepared source order data |
| `Retail_Staging2` | Stores temporary staging data |
| `Retail_DW2` | Final data warehouse database |

## 🏗️ Data Warehouse Design

The data warehouse follows a **Star Schema** design.

### Dimension Tables

- `DimDate`
- `DimCustomer`
- `DimProduct`
- `DimOrderProfile`

### Fact Table

- `FactRetailSales`

### Fact Measures

- Quantity
- UnitAmount
- SalesAmount
- Transaction process time in hours

## ⭐ Slowly Changing Dimension

The project implements **Slowly Changing Dimension Type 2** for the customer dimension.

### SCD Table

- `DimCustomer`

### Business Key

- `Customer_ID`

### Current Row Indicator

- `CurrentFlag = 'Y'` for current records
- `CurrentFlag = 'N'` for historical records

## 🔄 ETL Process

The ETL process was developed using **SSIS**.

### Main ETL Packages

| Package | Purpose |
|---|---|
| `Retail_Load_Staging.dtsx` | Loads SQL Server, CSV, and Excel source data into staging tables |
| `Retail_Load_DW.dtsx` | Loads dimension and fact tables into the data warehouse |
| `Retail_Update_AccumulatingFact.dtsx` | Updates transaction completion time and process duration |

### ETL Flow

1. Extract data from SQL Server, CSV, and Excel sources
2. Load data into staging tables
3. Clean and transform data
4. Load dimension tables
5. Apply SCD Type 2 for customer data
6. Load the `FactRetailSales` table
7. Update accumulating fact table records
8. Redirect unmatched update records to a reject file

## ⏱️ Accumulating Fact Table

The fact table includes transaction tracking columns:

- `accm_txn_create_time`
- `accm_txn_complete_time`
- `txn_process_time_hours`

A separate update file is used to update completed transactions and calculate the total processing time.

## ⚠️ Data Quality Handling

The project handled common ETL issues such as:

- Null date values
- Datatype mismatches
- Unmatched transaction update records

Unmatched update records were redirected to:

⭐ Key Features

- Retail Data Warehouse implementation
- Multiple data source types
- Staging database
- Star Schema design
- Fact and dimension tables
- SSIS ETL packages
- SCD Type 2 implementation
- Accumulating fact table update
- Lookup transformations
- Data conversion transformations
- Reject file handling

