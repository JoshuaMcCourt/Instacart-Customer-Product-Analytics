-- 01_int_orders.sql
-- INTERMEDIATE TABLE: MERGED ORDERS + PRODUCTS + USER INFO

USE [InstacartAnalyticsWarehouse];
GO

-- Drop intermediate table if it exists

IF OBJECT_ID('dbo.int_orders', 'U') IS NOT NULL
    DROP TABLE dbo.int_orders;
GO

-- Create intermediate table by joining staging tables

SELECT
    o.order_id,
    o.user_id,
    o.order_number,
    o.order_dow,
    o.order_hour_of_day,
    o.days_since_prior_order,
    p.product_id,
    p.product_name,
    p.aisle_id,
    p.department_id,
    p.is_organic,
    op.add_to_cart_order,
    op.reordered_flag AS reordered
INTO dbo.int_orders
FROM dbo.stg_orders o
JOIN dbo.stg_order_products op 
    ON o.order_id = op.order_id
JOIN dbo.stg_products p 
    ON op.product_id = p.product_id;
GO

-- Validate intermediate table

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT product_id) AS total_products
FROM dbo.int_orders;
GO
