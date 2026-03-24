-- 03_stg_products.sql
-- STAGING TABLE: PRODUCTS 

USE [InstacartAnalyticsWarehouse];
GO

-- Drop staging table if it exists

IF OBJECT_ID('dbo.stg_products', 'U') IS NOT NULL
    DROP TABLE dbo.stg_products;
GO

-- Create staging table from raw products

SELECT *,
       CASE WHEN LOWER(product_name) LIKE '%organic%' THEN 1 ELSE 0 END AS is_organic
INTO dbo.stg_products
FROM dbo.products;
GO

-- Basic data validation

SELECT 
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_products
FROM dbo.stg_products;
GO
