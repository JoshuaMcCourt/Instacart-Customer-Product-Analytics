-- 03_fact_orders.sql
-- FACT TABLE: ORDERS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if exists

IF OBJECT_ID('dbo.fact_orders', 'U') IS NOT NULL
    DROP TABLE dbo.fact_orders;
GO

-- Create fact table

SELECT
    CAST(o.order_id AS INT) AS order_id,
    CAST(o.user_id AS INT) AS user_id,
    CAST(o.product_id AS INT) AS product_id,

    -- Order behaviour (compact types)
    CAST(o.order_number AS SMALLINT) AS order_number,
    CAST(o.order_dow AS TINYINT) AS order_dow,
    CAST(o.order_hour_of_day AS TINYINT) AS order_hour_of_day,
    CAST(o.days_since_prior_order AS SMALLINT) AS days_since_prior_order,

    -- Binary flag
    CAST(o.reordered AS BIT) AS reordered

INTO dbo.fact_orders
FROM dbo.int_orders o;
GO

-- Indexes

-- Clustered index (best for large scans)
CREATE CLUSTERED INDEX cidx_fact_orders_order_id
ON dbo.fact_orders(order_id);
GO

-- Core join indexes 
CREATE NONCLUSTERED INDEX idx_fact_orders_user_id 
ON dbo.fact_orders(user_id);
GO

CREATE NONCLUSTERED INDEX idx_fact_orders_product_id 
ON dbo.fact_orders(product_id);
GO

-- Time analysis 
CREATE NONCLUSTERED INDEX idx_fact_orders_time 
ON dbo.fact_orders(order_dow, order_hour_of_day);
GO

-- Validation

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT product_id) AS unique_products
FROM dbo.fact_orders;
GO