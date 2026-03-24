-- 01_user_features.sql
-- FEATURE ENGINEERING: USER LEVEL METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.fe_user_metrics', 'U') IS NOT NULL
    DROP TABLE dbo.fe_user_metrics;
GO

-- Create user feature table using CTE

;WITH user_orders AS (
    SELECT
        user_id,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(product_id) AS total_items,
        SUM(CAST(reordered AS INT)) AS total_reorders,
        AVG(CAST(days_since_prior_order AS FLOAT)) AS avg_days_between_orders
    FROM dbo.int_orders
    GROUP BY user_id
)

SELECT
    user_id,
    total_orders,
    total_items,
    total_reorders,
    total_reorders * 1.0 / NULLIF(total_orders, 0) AS reorder_rate,
    avg_days_between_orders
INTO dbo.fe_user_metrics
FROM user_orders;
GO

-- Validate features

SELECT TOP 10 *
FROM dbo.fe_user_metrics
ORDER BY total_orders DESC;
GO