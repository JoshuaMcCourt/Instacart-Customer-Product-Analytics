-- 07_advanced_engagement_features.sql
-- FEATURE ENGINEERING: ADVANCED ENGAGEMENT METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.fe_user_engagement', 'U') IS NOT NULL
    DROP TABLE dbo.fe_user_engagement;
GO

-- Create engagement features table

SELECT
    um.user_id,

    um.total_orders,
    um.total_items,
    um.reorder_rate,

    pd.unique_products,
    pd.unique_aisles,
    pd.unique_departments,

    -- Derived metrics (safe division)
    CAST(um.total_items AS FLOAT) / NULLIF(um.total_orders, 0) AS avg_items_per_order,
    CAST(um.total_orders AS FLOAT) / NULLIF(pd.unique_products, 0) AS avg_orders_per_product

INTO dbo.fe_user_engagement
FROM dbo.fe_user_metrics um
INNER JOIN dbo.fe_user_product_diversity pd 
    ON um.user_id = pd.user_id;
GO

-- Validation

SELECT TOP 10 *
FROM dbo.fe_user_engagement
ORDER BY total_orders DESC;
GO