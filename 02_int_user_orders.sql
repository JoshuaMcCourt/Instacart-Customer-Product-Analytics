-- 02_int_user_orders.sql
-- INTERMEDIATE TABLE: USER ORDER HISTORY

USE [InstacartAnalyticsWarehouse];
GO

-- Drop intermediate table if it exists

IF OBJECT_ID('dbo.int_user_orders', 'U') IS NOT NULL
    DROP TABLE dbo.int_user_orders;
GO

-- Create intermediate table aggregating orders per user

SELECT 
    user_id,
    order_id,
    order_number,
    order_dow,
    order_hour_of_day,
    days_since_prior_order,
    COUNT(product_id) AS items_in_order,
    SUM(CAST(reordered AS INT)) AS reorders_in_order
INTO dbo.int_user_orders
FROM dbo.int_orders
GROUP BY user_id, order_id, order_number, order_dow, order_hour_of_day, days_since_prior_order;
GO

-- Quick validation / check top users

SELECT TOP 10
    user_id,
    COUNT(order_id) AS total_orders,
    SUM(items_in_order) AS total_items
FROM dbo.int_user_orders
GROUP BY user_id
ORDER BY total_orders DESC;
GO