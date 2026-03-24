-- 03_fe_user_product_metrics.sql
-- FEATURE ENGINEERING: USER-PRODUCT INTERACTIONS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.fe_user_product_metrics', 'U') IS NOT NULL
    DROP TABLE dbo.fe_user_product_metrics;
GO

-- Create user-product feature table

SELECT
    user_id,
    product_id,
    COUNT(*) AS times_ordered,
    SUM(CAST(reordered AS INT)) AS total_reorders,
    AVG(CAST(add_to_cart_order AS FLOAT)) AS avg_cart_position,
    SUM(CAST(reordered AS INT)) * 1.0 / COUNT(*) AS reorder_rate
INTO dbo.fe_user_product_metrics
FROM dbo.int_orders
GROUP BY user_id, product_id;
GO

-- Validate table

SELECT TOP 10 *
FROM dbo.fe_user_product_metrics
ORDER BY times_ordered DESC;
GO