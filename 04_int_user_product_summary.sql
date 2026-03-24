-- 04_int_user_product_summary.sql
-- INTERMEDIATE TABLE: USER-PRODUCT INTERACTIONS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.int_user_product_summary', 'U') IS NOT NULL
    DROP TABLE dbo.int_user_product_summary;
GO

-- Create aggregated user-product table

SELECT
    user_id,
    product_id,
    COUNT(*) AS times_ordered,
    SUM(CAST(reordered AS INT)) AS total_reorders,
    AVG(CAST(add_to_cart_order AS FLOAT)) AS avg_cart_position
INTO dbo.int_user_product_summary
FROM dbo.int_orders
GROUP BY user_id, product_id;
GO

-- Validate table

SELECT TOP 10 *
FROM dbo.int_user_product_summary;
GO
