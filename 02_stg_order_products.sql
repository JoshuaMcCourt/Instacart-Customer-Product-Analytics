-- 02_stg_order_products.sql
-- STAGING TABLE: ORDER_PRODUCTS (COMBINED PRIOR + TRAIN)

USE [InstacartAnalyticsWarehouse];
GO

-- Drop staging table if it exists

IF OBJECT_ID('dbo.stg_order_products', 'U') IS NOT NULL
    DROP TABLE dbo.stg_order_products;
GO

-- Create staging table by combining prior + train

SELECT *,
       CASE WHEN reordered = 1 THEN 1 ELSE 0 END AS reordered_flag
INTO dbo.stg_order_products
FROM dbo.order_products__prior
UNION ALL
SELECT *,
       CASE WHEN reordered = 1 THEN 1 ELSE 0 END AS reordered_flag
FROM dbo.order_products__train;
GO

-- Basic data validation

-- Total rows
SELECT COUNT(*) AS total_rows
FROM dbo.stg_order_products;
GO

-- Unique order-product combinations
SELECT COUNT(*) AS unique_order_products
FROM (
    SELECT order_id, product_id
    FROM dbo.stg_order_products
    GROUP BY order_id, product_id
) AS grouped;
GO

-- Missing reordered flags
SELECT SUM(CASE WHEN reordered_flag IS NULL THEN 1 ELSE 0 END) AS missing_reorder_flags
FROM dbo.stg_order_products;
GO
