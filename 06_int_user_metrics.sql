-- 06_int_user_metrics.sql
-- INTERMEDIATE TABLE: AGGREGATED USER METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.int_user_metrics', 'U') IS NOT NULL
    DROP TABLE dbo.int_user_metrics;
GO

-- Create aggregated user metrics table

SELECT
    user_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(product_id) AS total_items,
    SUM(CAST(reordered AS INT)) AS total_reorders,
    AVG(CAST(days_since_prior_order AS FLOAT)) AS avg_days_between_orders,
    SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS reorder_rate
INTO dbo.int_user_metrics
FROM dbo.int_orders
GROUP BY user_id;
GO

-- Validate table

SELECT TOP 10 *
FROM dbo.int_user_metrics
ORDER BY total_orders DESC;
GO