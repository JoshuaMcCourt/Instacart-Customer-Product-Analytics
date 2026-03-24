-- 01_dim_users.sql
-- DIMENSION TABLE: USERS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if exists

IF OBJECT_ID('dbo.dim_users', 'U') IS NOT NULL
    DROP TABLE dbo.dim_users;
GO

-- Create dimension table

SELECT
    um.user_id,

    -- Core metrics
    um.total_orders,
    um.total_items,
    um.total_reorders,
    um.reorder_rate,

    -- Time behaviour
    ut.avg_order_hour,
    ut.avg_order_day_of_week,

    -- Diversity metrics
    pd.unique_products,
    pd.unique_aisles,
    pd.unique_departments,

    -- Segmentation (business logic)
    CASE
        WHEN um.reorder_rate > 0.8 THEN 'loyal'
        WHEN um.reorder_rate > 0.5 THEN 'regular'
        ELSE 'explorer'
    END AS user_segment

INTO dbo.dim_users
FROM dbo.fe_user_metrics um
INNER JOIN dbo.fe_user_time_features ut 
    ON um.user_id = ut.user_id
INNER JOIN dbo.fe_user_product_diversity pd 
    ON um.user_id = pd.user_id;
GO

-- Add indexes (minimal + high impact only)

-- Primary join key 
CREATE INDEX idx_dim_users_user_id 
ON dbo.dim_users(user_id);
GO

-- Improves filtering by segment (useful in Tableau)
CREATE INDEX idx_dim_users_segment 
ON dbo.dim_users(user_segment);
GO

-- Validation

SELECT TOP 10 *
FROM dbo.dim_users
ORDER BY total_orders DESC;
GO