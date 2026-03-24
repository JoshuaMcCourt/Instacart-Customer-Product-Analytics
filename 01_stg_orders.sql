-- 01_stg_orders.sql
-- STAGING TABLE: ORDERS

-- Set to the correct database

USE [InstacartAnalyticsWarehouse];
GO

-- Drop the staging table if it exists

IF OBJECT_ID('dbo.stg_orders', 'U') IS NOT NULL
    DROP TABLE dbo.stg_orders;
GO

-- Create the staging table from dbo.orders

SELECT
    TRY_CAST(order_id AS INT) AS order_id,
    TRY_CAST(user_id AS INT) AS user_id,
    TRY_CAST(order_number AS INT) AS order_number,
    TRY_CAST(order_dow AS INT) AS order_dow,
    TRY_CAST(order_hour_of_day AS INT) AS order_hour_of_day,
    TRY_CAST(days_since_prior_order AS INT) AS days_since_prior_order,
    eval_set,
    GETDATE() AS created_at
INTO dbo.stg_orders
FROM dbo.orders;
GO

-- Basic quality checks

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS missing_users
FROM dbo.stg_orders;
GO
