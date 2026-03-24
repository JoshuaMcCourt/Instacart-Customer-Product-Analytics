-- 03_int_product_orders.sql
-- INTERMEDIATE TABLE: PRODUCT-LEVEL ORDER DATA

USE [InstacartAnalyticsWarehouse];
GO

-- Drop intermediate table if it exists

IF OBJECT_ID('dbo.int_product_orders', 'U') IS NOT NULL
    DROP TABLE dbo.int_product_orders;
GO

-- Create product-level order table from int_orders

SELECT
    product_id,
    order_id,
    user_id,
    add_to_cart_order,
    reordered
INTO dbo.int_product_orders
FROM dbo.int_orders;
GO

-- Validate table

SELECT TOP 10
    product_id,
    COUNT(order_id) AS times_ordered,
    AVG(CAST(reordered AS INT)) AS reorder_rate
FROM dbo.int_product_orders
GROUP BY product_id
ORDER BY times_ordered DESC;
GO