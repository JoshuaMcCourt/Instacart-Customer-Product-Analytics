-- 06_export_files.sql
-- Export processed marts tables to CSV 

USE [InstacartAnalyticsWarehouse];
GO

-- Reduce fact_orders for Tableau usage
-- Drop table if exists

IF OBJECT_ID('dbo.fact_orders_tableau', 'U') IS NOT NULL
    DROP TABLE dbo.fact_orders_tableau;
GO

-- Table Creation
SELECT *
INTO dbo.fact_orders_tableau
FROM dbo.fact_orders
WHERE user_id % 10 = 0
  AND order_number <= 20;

-- Reduce fact_user_product for Tableau usage
-- Drop table if exists

IF OBJECT_ID('dbo.fact_user_product_tableau', 'U') IS NOT NULL
    DROP TABLE dbo.fact_user_product_tableau;
GO

-- Table Creation
SELECT *
INTO dbo.fact_user_product_tableau
FROM dbo.fact_user_product
WHERE user_id % 10 = 0


-- 1) dim_users
SELECT * 
FROM dbo.dim_users;

-- 2) dim_products
SELECT * 
FROM dbo.dim_products;

-- 3) fact_orders
SELECT * 
FROM dbo.fact_orders;

-- 4) fact_orders_tableau
SELECT * 
FROM dbo.fact_orders_tableau;

-- 5) fact_user_product
SELECT * 
FROM dbo.fact_user_product;

-- 6) fact_user_product_tableau
SELECT * 
FROM dbo.fact_user_product_tableau;

-- 7) fact_user_cohorts
SELECT * 
FROM dbo.fact_user_cohorts;
