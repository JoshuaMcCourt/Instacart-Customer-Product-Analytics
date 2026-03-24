-- 05_fe_user_time_features.sql
-- FEATURE ENGINEERING: TIME-BASED USER METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.fe_user_time_features', 'U') IS NOT NULL
    DROP TABLE dbo.fe_user_time_features;
GO

-- Create feature table

;WITH user_orders AS (
    SELECT
        user_id,
        order_dow,
        order_hour_of_day,
        COUNT(order_id) AS orders_per_slot
    FROM dbo.int_orders
    GROUP BY user_id, order_dow, order_hour_of_day
)

SELECT
    user_id,
    AVG(CAST(order_dow AS FLOAT)) AS avg_order_day_of_week,
    AVG(CAST(order_hour_of_day AS FLOAT)) AS avg_order_hour,
    COUNT(DISTINCT order_dow) AS active_days_of_week,
    COUNT(DISTINCT order_hour_of_day) AS active_hours_of_day
INTO dbo.fe_user_time_features
FROM user_orders
GROUP BY user_id;
GO

-- Validate

SELECT TOP 10 *
FROM dbo.fe_user_time_features;
GO