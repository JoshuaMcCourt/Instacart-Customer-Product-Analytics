-- 05_int_product_metrics.sql
-- INTERMEDIATE TABLE: AGGREGATED PRODUCT METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.int_product_metrics', 'U') IS NOT NULL
    DROP TABLE dbo.int_product_metrics;
GO

-- Create aggregated product metrics table

SELECT
    product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(CAST(reordered AS INT)) AS total_reorders,
    AVG(CAST(add_to_cart_order AS FLOAT)) AS avg_cart_position
INTO dbo.int_product_metrics
FROM dbo.int_orders
GROUP BY product_id;
GO

-- Validate table

SELECT TOP 10 *
FROM dbo.int_product_metrics
ORDER BY total_orders DESC;
GO
