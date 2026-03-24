-- 02_fe_product_metrics.sql
-- FEATURE ENGINEERING: PRODUCT LEVEL METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.fe_product_metrics', 'U') IS NOT NULL
    DROP TABLE dbo.fe_product_metrics;
GO

-- Create product feature table

;WITH product_orders AS (
    SELECT
        product_id,
        COUNT(*) AS total_orders,
        COUNT(DISTINCT user_id) AS unique_users,
        SUM(CAST(reordered AS INT)) AS total_reorders,
        AVG(CAST(add_to_cart_order AS FLOAT)) AS avg_cart_position
    FROM dbo.int_orders
    GROUP BY product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.department_id,
    p.aisle_id,
    p.is_organic,
    po.total_orders,
    po.unique_users,
    po.total_reorders,
    po.total_reorders * 1.0 / NULLIF(po.total_orders, 0) AS reorder_rate,
    po.avg_cart_position
INTO dbo.fe_product_metrics
FROM dbo.stg_products p
JOIN product_orders po 
    ON p.product_id = po.product_id;
GO

-- Quick validation

SELECT TOP 10 *
FROM dbo.fe_product_metrics
ORDER BY total_orders DESC;
GO