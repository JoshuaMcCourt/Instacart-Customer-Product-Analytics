-- instacart_analytics/
-- ├── data/                                 # Raw and processed CSV files
-- │   ├── raw/
-- │   │   ├── orders.csv
-- │   │   ├── order_products__prior.csv
-- │   │   ├── order_products__train.csv
-- │   │   ├── products.csv
-- │   │   ├── aisles.csv
-- │   │   └── departments.csv
-- │   │
-- │   └── processed/                        # Exported tables for analysis/Tableau
-- │       ├── dim_users.csv
-- │       ├── dim_products.csv
-- │       ├── fact_orders.csv
-- │       ├── fact_user_product.csv
-- │       └── fact_user_cohorts.csv
-- │
-- ├── sql/                                  # All SQL scripts
-- │   ├── 01_staging/
-- │   │   ├── 01_stg_orders.sql
-- │   │   ├── 02_stg_order_products.sql
-- │   │   ├── 03_stg_products.sql
-- │   │   ├── 04_stg_aisles.sql
-- │   │   ├── 05_stg_departments.sql
-- │   │   └── 06_stg_quality_checks.sql
-- │   │
-- │   ├── 02_intermediate/
-- │   │   ├── 01_int_orders.sql
-- │   │   ├── 02_int_user_orders.sql
-- │   │   ├── 03_int_product_orders.sql
-- │   │   ├── 04_int_user_product_summary.sql
-- │   │   ├── 05_int_product_metrics.sql
-- │   │   ├── 06_int_user_metrics.sql
-- │   │   └── 07_int_user_cohorts.sql
-- │   │
-- │   ├── 03_feature_engineering/
-- │   │   ├── 01_user_features.sql
-- │   │   ├── 02_product_features.sql
-- │   │   ├── 03_user_product_features.sql
-- │   │   ├── 04_cohort_features.sql
-- │   │   ├── 05_time_based_features.sql
-- │   │   ├── 06_product_diversity_features.sql
-- │   │   └── 07_advanced_engagement_features.sql
-- │   │
-- │   ├── 04_marts/
-- │   │   ├── 01_dim_users.sql
-- │   │   ├── 02_dim_products.sql
-- │   │   ├── 03_fact_orders.sql
-- │   │   ├── 04_fact_user_product.sql
-- │   │   ├── 05_fact_user_cohorts.sql
-- │   │   └── 06_export_files.sql
-- │   │
-- │   └── 05_analysis/
-- │       ├── 01_data_overview.sql
-- │       ├── 02_order_patterns.sql
-- │       ├── 03_basket_analysis.sql
-- │       ├── 04_product_analysis.sql
-- │       ├── 05_reorder_analysis.sql
-- │       ├── 06_user_behaviour.sql
-- │       └── 07_advanced_insights.sql
-- │
-- ├── docs/
-- │   ├── visuals/                          # Exported Tableau charts/screenshots
-- │   │   ├── order_patterns.png
-- │   │   ├── basket_analysis.png
-- │   │   ├── product_popularity.png
-- │   │   ├── reorder_analysis.png
-- │   │   └── user_behaviour.png
-- │   │
-- │   └── instacart_sql_pipeline_diagram.png # Optional diagram of ETL flow
-- │
-- ├── full_script/
-- │   └── full_script.sql                    # Optional: combine all SQL files in one
-- │
-- ├── README.md                              # Project overview, instructions
-- ├── .gitignore                             # Ignore raw data, temp files, system files
-- └── structure.txt   

-- View Tables

SELECT *
FROM [InstacartAnalyticsWarehouse].[dbo].[aisles];

SELECT *
FROM [InstacartAnalyticsWarehouse].[dbo].[departments];

SELECT *
FROM [InstacartAnalyticsWarehouse].[dbo].[order_products__prior];

SELECT *
FROM [InstacartAnalyticsWarehouse].[dbo].[order_products__train];

SELECT *
FROM [InstacartAnalyticsWarehouse].[dbo].[orders];

SELECT *
FROM [InstacartAnalyticsWarehouse].[dbo].[products];


-- 01_staging/

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


-- 02_stg_order_products.sql
-- STAGING TABLE: ORDER_PRODUCTS (COMBINED PRIOR + TRAIN)

USE [InstacartAnalyticsWarehouse];
GO

-- Drop staging table if it exists

IF OBJECT_ID('dbo.stg_order_products', 'U') IS NOT NULL
    DROP TABLE dbo.stg_order_products;
GO

-- Create staging table by combining prior + train

SELECT *,
       CASE WHEN reordered = 1 THEN 1 ELSE 0 END AS reordered_flag
INTO dbo.stg_order_products
FROM dbo.order_products__prior
UNION ALL
SELECT *,
       CASE WHEN reordered = 1 THEN 1 ELSE 0 END AS reordered_flag
FROM dbo.order_products__train;
GO

-- Basic data validation

-- Total rows
SELECT COUNT(*) AS total_rows
FROM dbo.stg_order_products;
GO

-- Unique order-product combinations
SELECT COUNT(*) AS unique_order_products
FROM (
    SELECT order_id, product_id
    FROM dbo.stg_order_products
    GROUP BY order_id, product_id
) AS grouped;
GO

-- Missing reordered flags
SELECT SUM(CASE WHEN reordered_flag IS NULL THEN 1 ELSE 0 END) AS missing_reorder_flags
FROM dbo.stg_order_products;
GO


-- 03_stg_products.sql
-- STAGING TABLE: PRODUCTS 

USE [InstacartAnalyticsWarehouse];
GO

-- Drop staging table if it exists

IF OBJECT_ID('dbo.stg_products', 'U') IS NOT NULL
    DROP TABLE dbo.stg_products;
GO

-- Create staging table from raw products

SELECT *,
       CASE WHEN LOWER(product_name) LIKE '%organic%' THEN 1 ELSE 0 END AS is_organic
INTO dbo.stg_products
FROM dbo.products;
GO

-- Basic data validation

SELECT 
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_products
FROM dbo.stg_products;
GO


-- 04_stg_aisles.sql
-- STAGING TABLE: AISLES

USE [InstacartAnalyticsWarehouse];
GO

-- Drop staging table if it exists

IF OBJECT_ID('dbo.stg_aisles', 'U') IS NOT NULL
    DROP TABLE dbo.stg_aisles;
GO

-- Create staging table from raw aisles

SELECT DISTINCT *
INTO dbo.stg_aisles
FROM dbo.aisles;
GO

-- Validate aisles

SELECT COUNT(*) AS total_aisles
FROM dbo.stg_aisles;
GO


-- 05_stg_departments.sql
-- STAGING TABLE: DEPARTMENTS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop staging table if it exists

IF OBJECT_ID('dbo.stg_departments', 'U') IS NOT NULL
    DROP TABLE dbo.stg_departments;
GO

-- Create staging table from raw departments

SELECT DISTINCT *
INTO dbo.stg_departments
FROM dbo.departments;
GO

-- Validate departments

SELECT COUNT(*) AS total_departments
FROM dbo.stg_departments;
GO


-- 06_stg_quality_checks.sql
-- STAGING DATA QUALITY CHECKS

-- Duplicate orders
SELECT order_id, COUNT(*) AS cnt
FROM dbo.stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
GO

-- Missing products in order_products
SELECT COUNT(*) AS missing_products
FROM dbo.stg_order_products op
LEFT JOIN dbo.stg_products p
ON op.product_id = p.product_id
WHERE p.product_id IS NULL;
GO

-- Missing users in orders
SELECT COUNT(*) AS missing_users
FROM dbo.stg_orders o
LEFT JOIN dbo.stg_order_products op
ON o.order_id = op.order_id
WHERE o.user_id IS NULL;
GO

-- Duplicate products
SELECT product_id, COUNT(*) AS cnt
FROM dbo.stg_products
GROUP BY product_id
HAVING COUNT(*) > 1;
GO

-- Duplicate aisles
SELECT aisle_id, COUNT(*) AS cnt
FROM dbo.stg_aisles
GROUP BY aisle_id
HAVING COUNT(*) > 1;
GO

-- Duplicate departments
SELECT department_id, COUNT(*) AS cnt
FROM dbo.stg_departments
GROUP BY department_id
HAVING COUNT(*) > 1;
GO


-- 02_intermediate/

-- 01_int_orders.sql
-- INTERMEDIATE TABLE: MERGED ORDERS + PRODUCTS + USER INFO

USE [InstacartAnalyticsWarehouse];
GO

-- Drop intermediate table if it exists

IF OBJECT_ID('dbo.int_orders', 'U') IS NOT NULL
    DROP TABLE dbo.int_orders;
GO

-- Create intermediate table by joining staging tables

SELECT
    o.order_id,
    o.user_id,
    o.order_number,
    o.order_dow,
    o.order_hour_of_day,
    o.days_since_prior_order,
    p.product_id,
    p.product_name,
    p.aisle_id,
    p.department_id,
    p.is_organic,
    op.add_to_cart_order,
    op.reordered_flag AS reordered
INTO dbo.int_orders
FROM dbo.stg_orders o
JOIN dbo.stg_order_products op 
    ON o.order_id = op.order_id
JOIN dbo.stg_products p 
    ON op.product_id = p.product_id;
GO

-- Validate intermediate table

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT product_id) AS total_products
FROM dbo.int_orders;
GO


-- 02_int_user_orders.sql
-- INTERMEDIATE TABLE: USER ORDER HISTORY

USE [InstacartAnalyticsWarehouse];
GO

-- Drop intermediate table if it exists

IF OBJECT_ID('dbo.int_user_orders', 'U') IS NOT NULL
    DROP TABLE dbo.int_user_orders;
GO

-- Create intermediate table aggregating orders per user

SELECT 
    user_id,
    order_id,
    order_number,
    order_dow,
    order_hour_of_day,
    days_since_prior_order,
    COUNT(product_id) AS items_in_order,
    SUM(CAST(reordered AS INT)) AS reorders_in_order
INTO dbo.int_user_orders
FROM dbo.int_orders
GROUP BY user_id, order_id, order_number, order_dow, order_hour_of_day, days_since_prior_order;
GO

-- Quick validation / check top users

SELECT TOP 10
    user_id,
    COUNT(order_id) AS total_orders,
    SUM(items_in_order) AS total_items
FROM dbo.int_user_orders
GROUP BY user_id
ORDER BY total_orders DESC;
GO


-- 03_int_product_orders.sql
-- INTERMEDIATE TABLE: PRODUCT-LEVEL ORDER DATA

USE [InstacartAnalyticsWarehouse];
GO

-- Drop intermediate table if it exists

IF OBJECT_ID('dbo.int_product_orders', 'U') IS NOT NULL
    DROP TABLE dbo.int_product_orders;
GO

-- Create product-level order table from int_orders

SELECT
    product_id,
    order_id,
    user_id,
    add_to_cart_order,
    reordered
INTO dbo.int_product_orders
FROM dbo.int_orders;
GO

-- Validate table

SELECT TOP 10
    product_id,
    COUNT(order_id) AS times_ordered,
    AVG(CAST(reordered AS INT)) AS reorder_rate
FROM dbo.int_product_orders
GROUP BY product_id
ORDER BY times_ordered DESC;
GO


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


-- 05_int_product_metrics.sql
-- INTERMEDIATE TABLE: AGGREGATED PRODUCT METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.int_product_metrics', 'U') IS NOT NULL
    DROP TABLE dbo.int_product_metrics;
GO

-- Create aggregated product metrics table

SELECT
    product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(CAST(reordered AS INT)) AS total_reorders,
    AVG(CAST(add_to_cart_order AS FLOAT)) AS avg_cart_position
INTO dbo.int_product_metrics
FROM dbo.int_orders
GROUP BY product_id;
GO

-- Validate table

SELECT TOP 10 *
FROM dbo.int_product_metrics
ORDER BY total_orders DESC;
GO


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


-- 07_int_user_cohorts.sql
-- INTERMEDIATE TABLE: USER COHORTS BASED ON FIRST ORDER

USE [InstacartAnalyticsWarehouse];
GO

-- Only create table if source has data
IF EXISTS (SELECT 1 FROM dbo.int_orders)
BEGIN

    IF OBJECT_ID('dbo.int_user_cohorts', 'U') IS NOT NULL
        DROP TABLE dbo.int_user_cohorts;

    ;WITH first_orders AS (
        SELECT 
            user_id,
            MIN(order_number) AS first_order_number
        FROM dbo.int_orders
        GROUP BY user_id
    )

    SELECT 
        o.user_id,
        o.order_id,
        o.order_number,

        -- Cohort month (still approximation)
        DATEFROMPARTS(
            YEAR(DATEADD(DAY, -(o.order_number - 1), GETDATE())),
            MONTH(DATEADD(DAY, -(o.order_number - 1), GETDATE())),
            1
        ) AS cohort_month

    INTO dbo.int_user_cohorts
    FROM dbo.int_orders o
    INNER JOIN first_orders f 
        ON o.user_id = f.user_id
       AND o.order_number = f.first_order_number;  -- ✅ KEY FIX

END
GO

-- Validation
IF OBJECT_ID('dbo.int_user_cohorts', 'U') IS NOT NULL
BEGIN
    SELECT 
        cohort_month, 
        COUNT(DISTINCT user_id) AS num_users
    FROM dbo.int_user_cohorts
    GROUP BY cohort_month
    ORDER BY cohort_month;
END
GO


-- 03_feature_engineering/

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


-- 04_fe_user_cohorts.sql
-- FEATURE ENGINEERING: USER COHORT METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.fe_user_cohorts', 'U') IS NOT NULL
    DROP TABLE dbo.fe_user_cohorts;
GO

-- Get FIRST ORDER per user

;WITH first_order AS (
    SELECT
        user_id,
        MIN(order_number) AS first_order_number
    FROM dbo.int_orders
    GROUP BY user_id
)

-- Create cohort table

SELECT
    u.user_id,
    u.order_id,
    u.order_number,

    -- Correct first order attributes (no MIN misuse), dow = day of week
    u.order_dow AS first_order_dow,
    u.order_hour_of_day AS first_order_hour,

    -- Cohort month (approximation)
    DATEFROMPARTS(
        YEAR(DATEADD(DAY, -(u.order_number - 1), GETDATE())),
        MONTH(DATEADD(DAY, -(u.order_number - 1), GETDATE())),
        1
    ) AS cohort_month

INTO dbo.fe_user_cohorts
FROM dbo.int_orders u
INNER JOIN first_order f 
    ON u.user_id = f.user_id
   AND u.order_number = f.first_order_number;
GO

-- Validate cohorts

SELECT 
    cohort_month, 
    COUNT(DISTINCT user_id) AS num_users
FROM dbo.fe_user_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;
GO


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


-- 06_product_diversity_features.sql
-- FEATURE ENGINEERING: USER PRODUCT DIVERSITY METRICS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if it exists

IF OBJECT_ID('dbo.fe_user_product_diversity', 'U') IS NOT NULL
    DROP TABLE dbo.fe_user_product_diversity;
GO

-- Create the diversity features table

SELECT
    user_id,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(DISTINCT aisle_id) AS unique_aisles,
    COUNT(DISTINCT department_id) AS unique_departments
INTO dbo.fe_user_product_diversity
FROM dbo.int_orders
GROUP BY user_id;
GO

-- Validation - shows the top 10 most diverse users

SELECT TOP 10 *
FROM dbo.fe_user_product_diversity
ORDER BY unique_products DESC;
GO


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


-- 04_marts/

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


-- 02_dim_products.sql
-- DIMENSION TABLE: PRODUCTS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if exists

IF OBJECT_ID('dbo.dim_products', 'U') IS NOT NULL
    DROP TABLE dbo.dim_products;
GO

-- Create dimension table

SELECT
    p.product_id,
    p.product_name,

    -- Hierarchy
    p.department_id,
    d.department AS department_name,   -- FIXED
    p.aisle_id,
    a.aisle AS aisle_name,             -- FIXED

    -- Product attributes
    p.is_organic,

    -- Performance metrics
    pm.total_orders,
    pm.unique_users,
    pm.total_reorders,
    pm.reorder_rate,
    pm.avg_cart_position

INTO dbo.dim_products
FROM dbo.fe_product_metrics pm
INNER JOIN dbo.stg_products p 
    ON pm.product_id = p.product_id
INNER JOIN dbo.stg_aisles a 
    ON p.aisle_id = a.aisle_id
INNER JOIN dbo.stg_departments d 
    ON p.department_id = d.department_id;
GO

-- Add indexes

CREATE INDEX idx_dim_products_product_id 
ON dbo.dim_products(product_id);
GO

CREATE INDEX idx_dim_products_department 
ON dbo.dim_products(department_id);
GO

CREATE INDEX idx_dim_products_is_organic 
ON dbo.dim_products(is_organic);
GO

-- Validation

SELECT TOP 10 *
FROM dbo.dim_products
ORDER BY total_orders DESC;
GO


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


-- 04_fact_user_product.sql
-- FACT TABLE: USER × PRODUCT

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if exists

IF OBJECT_ID('dbo.fact_user_product', 'U') IS NOT NULL
    DROP TABLE dbo.fact_user_product;
GO

-- Create lean fact table

SELECT
    CAST(up.user_id AS INT) AS user_id,
    CAST(up.product_id AS INT) AS product_id,

    -- Core interaction metrics
    CAST(up.times_ordered AS SMALLINT) AS times_ordered,
    CAST(up.total_reorders AS SMALLINT) AS total_reorders,
    CAST(up.reorder_rate AS FLOAT) AS reorder_rate,
    CAST(up.avg_cart_position AS TINYINT) AS avg_cart_position

INTO dbo.fact_user_product
FROM dbo.fe_user_product_metrics up;
GO

-- Indexes

-- Clustered index
CREATE CLUSTERED INDEX cidx_fact_user_product
ON dbo.fact_user_product(user_id, product_id);
GO

-- Product filtering
CREATE NONCLUSTERED INDEX idx_fact_user_product_product
ON dbo.fact_user_product(product_id);
GO

-- Validation

SELECT TOP 10 *
FROM dbo.fact_user_product
ORDER BY times_ordered DESC;
GO


-- 05_fact_user_cohorts.sql
-- FACT TABLE: USER COHORT ANALYSIS

USE [InstacartAnalyticsWarehouse];
GO

-- Drop table if exists

IF OBJECT_ID('dbo.fact_user_cohorts', 'U') IS NOT NULL
    DROP TABLE dbo.fact_user_cohorts;
GO

-- Create lean cohort table

SELECT
    CAST(c.user_id AS INT) AS user_id,
    CAST(c.cohort_month AS DATE) AS cohort_month
INTO dbo.fact_user_cohorts
FROM dbo.fe_user_cohorts c;
GO

-- Indexes

-- Clustered index (best for grouping + scans)
CREATE CLUSTERED INDEX cidx_fact_user_cohorts
ON dbo.fact_user_cohorts(cohort_month, user_id);
GO

-- User lookup
CREATE NONCLUSTERED INDEX idx_fact_user_cohorts_user
ON dbo.fact_user_cohorts(user_id);
GO

-- Validation

SELECT 
    cohort_month, 
    COUNT(*) AS num_users
FROM dbo.fact_user_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;
GO


-- 06_export_files.sql
-- Export processed marts tables to CSV 

-- 1) dim_users
SELECT * 
FROM dbo.dim_users;

-- 2) dim_products
SELECT * 
FROM dbo.dim_products;

-- 3) fact_orders
SELECT * 
FROM dbo.fact_orders;

-- 4) fact_user_product
SELECT * 
FROM dbo.fact_user_product;

-- 5) fact_user_cohorts
SELECT * 
FROM dbo.fact_user_cohorts;


-- 05_analysis/

-- 01_data_overview.sql
-- DATA OVERVIEW & SANITY CHECKS

SET NOCOUNT ON;

-- Ensure clean temp table (idempotent execution)
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize base once
SELECT 
    user_id,
    order_id,
    product_id
INTO #base
FROM dbo.fact_orders;

-- Core cardinality metrics
SELECT
    COUNT_BIG(*) AS total_rows,
    COUNT_BIG(DISTINCT order_id) AS total_orders,
    COUNT_BIG(DISTINCT user_id) AS total_users,
    COUNT_BIG(DISTINCT product_id) AS total_products
FROM #base;

-- Basket size metrics (avg + median)
SELECT TOP 1
    AVG(CAST(cnt AS FLOAT)) OVER () AS avg_products_per_order,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY cnt) 
        OVER () AS median_products_per_order
FROM (
    SELECT order_id, COUNT_BIG(*) AS cnt
    FROM #base
    GROUP BY order_id
) AS order_counts;

-- Orders per user distribution
SELECT
    order_count,
    COUNT_BIG(*) AS num_users
FROM (
    SELECT user_id, COUNT_BIG(DISTINCT order_id) AS order_count
    FROM #base
    GROUP BY user_id
) AS user_orders
GROUP BY order_count
ORDER BY order_count;

-- Null checks (data quality)
SELECT
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_users,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_products,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_orders
FROM #base;

-- Cleanup
DROP TABLE #base;


-- 02_order_patterns.sql
-- TEMPORAL ORDER PATTERNS

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize required columns only
SELECT 
    order_dow,
    order_hour_of_day,
    days_since_prior_order
INTO #base
FROM dbo.fact_orders;

-- Orders by hour (with % of total)
WITH hourly AS (
    SELECT 
        order_hour_of_day,
        COUNT_BIG(*) AS total_orders
    FROM #base
    GROUP BY order_hour_of_day
)
SELECT
    order_hour_of_day,
    total_orders,
    CAST(100.0 * total_orders / SUM(total_orders) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM hourly
ORDER BY order_hour_of_day;

-- Orders by day of week (with rank)
WITH dow AS (
    SELECT 
        order_dow,
        COUNT_BIG(*) AS total_orders
    FROM #base
    GROUP BY order_dow
)
SELECT
    order_dow,
    total_orders,
    RANK() OVER (ORDER BY total_orders DESC) AS popularity_rank
FROM dow
ORDER BY popularity_rank;

-- Weekday vs weekend split (0=Sunday, 6=Saturday)
SELECT
    CASE 
        WHEN order_dow IN (0,6) THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    COUNT_BIG(*) AS total_orders,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM #base
GROUP BY 
    CASE 
        WHEN order_dow IN (0,6) THEN 'weekend'
        ELSE 'weekday'
    END;

-- Time between orders distribution
SELECT
    days_since_prior_order,
    COUNT_BIG(*) AS frequency
FROM #base
GROUP BY days_since_prior_order
ORDER BY days_since_prior_order;

-- Heatmap base: day of week × hour
SELECT
    order_dow,
    order_hour_of_day,
    COUNT_BIG(*) AS order_volume
FROM #base
GROUP BY order_dow, order_hour_of_day
ORDER BY order_dow, order_hour_of_day;

-- Cleanup
DROP TABLE #base;


-- 03_basket_analysis.sql
-- BASKET SIZE & COMPOSITION 

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize required columns with product attributes
SELECT 
    f.order_id,
    f.user_id,
    f.product_id,
    p.aisle_id,
    p.department_id
INTO #base
FROM dbo.fact_orders f
INNER JOIN dbo.dim_products p
    ON f.product_id = p.product_id;

-- Basket size per order
WITH basket_sizes AS (
    SELECT 
        order_id, 
        COUNT_BIG(product_id) AS basket_size
    FROM #base
    GROUP BY order_id
)
SELECT
    basket_size,
    COUNT_BIG(*) AS num_orders,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM basket_sizes
GROUP BY basket_size
ORDER BY basket_size;

-- Basket statistics: avg, median, max
SELECT TOP 1
    AVG(CAST(basket_size AS FLOAT)) OVER () AS avg_basket,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY basket_size) 
        OVER () AS median_basket,
    MAX(basket_size) OVER () AS max_basket
FROM (
    SELECT order_id, COUNT_BIG(product_id) AS basket_size
    FROM #base
    GROUP BY order_id
) AS order_counts;

-- Heavy vs light shoppers (basket categories)
SELECT
    CASE
        WHEN basket_size <= 5 THEN 'small'
        WHEN basket_size <= 15 THEN 'medium'
        ELSE 'large'
    END AS basket_category,
    COUNT_BIG(*) AS num_orders,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM (
    SELECT order_id, COUNT_BIG(product_id) AS basket_size
    FROM #base
    GROUP BY order_id
) AS order_counts
GROUP BY 
    CASE
        WHEN basket_size <= 5 THEN 'small'
        WHEN basket_size <= 15 THEN 'medium'
        ELSE 'large'
    END
ORDER BY basket_category;

-- Basket diversity per user
SELECT
    f.user_id,
    COUNT(DISTINCT f.product_id) AS unique_products,
    COUNT(DISTINCT p.aisle_id) AS unique_aisles,
    COUNT(DISTINCT p.department_id) AS unique_departments
FROM #base f
INNER JOIN dbo.dim_products p
    ON f.product_id = p.product_id
GROUP BY f.user_id
ORDER BY unique_products DESC;

-- Cleanup
DROP TABLE #base;


-- 04_product_analysis.sql
-- PRODUCT PERFORMANCE & STRUCTURE 

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize fact + product dimension
SELECT 
    fo.product_id,
    dp.product_name,
    dp.department_id,
    dp.department_name,
    dp.aisle_id,
    dp.aisle_name
INTO #base
FROM dbo.fact_orders fo
INNER JOIN dbo.dim_products dp
    ON fo.product_id = dp.product_id;

-- Top selling products
SELECT TOP 20
    product_name,
    COUNT_BIG(*) AS total_orders,
    DENSE_RANK() OVER (ORDER BY COUNT_BIG(*) DESC) AS rank
FROM #base
GROUP BY product_name
ORDER BY total_orders DESC;

-- Product popularity distribution
SELECT
    product_id,
    COUNT_BIG(*) AS purchase_count,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_of_total
FROM #base
GROUP BY product_id
ORDER BY purchase_count DESC;

-- Department-level sales
SELECT
    department_name,
    COUNT_BIG(*) AS total_sales,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_sales
FROM #base
GROUP BY department_name
ORDER BY total_sales DESC;

-- Aisle-level ranking
SELECT
    aisle_name,
    COUNT_BIG(*) AS total_sales,
    RANK() OVER (ORDER BY COUNT_BIG(*) DESC) AS aisle_rank,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_sales
FROM #base
GROUP BY aisle_name
ORDER BY aisle_rank;

-- Cleanup
DROP TABLE #base;


-- 05_reorder_analysis.sql
-- REORDER BEHAVIOR ANALYSIS

USE [InstacartAnalyticsWarehouse];
GO

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize fact + product dimension
SELECT 
    fo.user_id,
    fo.order_id,
    fo.order_number,
    fo.product_id,
    fo.reordered,
    fo.days_since_prior_order,
    dp.product_name
INTO #base
FROM dbo.fact_orders fo
INNER JOIN dbo.dim_products dp
    ON fo.product_id = dp.product_id;

-- Overall reorder rate
SELECT 
    CAST(100.0 * SUM(CAST(reordered AS INT)) / COUNT_BIG(*) AS DECIMAL(5,2)) AS reorder_rate_pct
FROM #base;

-- Reorder rate per product
SELECT
    product_name,
    COUNT_BIG(*) AS total_orders,
    CAST(100.0 * AVG(CAST(reordered AS FLOAT)) AS DECIMAL(5,2)) AS reorder_rate_pct
FROM #base
GROUP BY product_name
HAVING COUNT_BIG(*) > 50
ORDER BY reorder_rate_pct DESC;

-- Reorder probability vs time gap
SELECT
    days_since_prior_order,
    COUNT_BIG(*) AS num_orders,
    CAST(100.0 * AVG(CAST(reordered AS FLOAT)) AS DECIMAL(5,2)) AS reorder_probability_pct
FROM #base
GROUP BY days_since_prior_order
ORDER BY days_since_prior_order;

-- Reorder streak detection
SELECT
    user_id,
    order_id,
    order_number,
    SUM(CAST(reordered AS INT)) OVER (
        PARTITION BY user_id
        ORDER BY order_number
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS recent_reorders
FROM #base
ORDER BY user_id, order_number;

-- Cleanup
DROP TABLE #base;


-- 06_user_behaviour.sql
-- USER SEGMENTATION & BEHAVIOUR

USE [InstacartAnalyticsWarehouse];
GO

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize only required columns
SELECT 
    user_id,
    order_id,
    product_id,
    days_since_prior_order,
    reordered
INTO #base
FROM dbo.fact_orders;

-- Core user metrics
SELECT
    user_id,
    COUNT_BIG(DISTINCT order_id) AS total_orders,
    COUNT_BIG(product_id) AS total_items,
    CAST(AVG(CAST(days_since_prior_order AS FLOAT)) AS DECIMAL(10,2)) AS avg_days_between_orders,
    CAST(100.0 * AVG(CAST(reordered AS FLOAT)) AS DECIMAL(5,2)) AS reorder_rate_pct
FROM #base
GROUP BY user_id
ORDER BY total_orders DESC;

-- User segmentation distribution (dimension table)
SELECT
    user_segment,
    COUNT_BIG(*) AS num_users,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_users
FROM dbo.dim_users
GROUP BY user_segment
ORDER BY num_users DESC;

-- Power users (top 5% by total_orders)
-- SQL Server requires OVER() for PERCENTILE_CONT
WITH threshold AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.95) 
        WITHIN GROUP (ORDER BY total_orders) 
        OVER () AS cutoff
    FROM dbo.dim_users
)
SELECT du.*
FROM dbo.dim_users du
CROSS JOIN threshold t
WHERE du.total_orders >= t.cutoff
ORDER BY du.total_orders DESC;

-- Habitual users (always reorder)
SELECT
    user_id,
    total_orders,
    reorder_rate
FROM dbo.dim_users
WHERE reorder_rate = 1
ORDER BY total_orders DESC;

-- High-value engaged users (improved business signal)
SELECT TOP 20
    user_id,
    total_orders,
    total_items,
    reorder_rate
FROM dbo.dim_users
WHERE total_orders >= 10
  AND reorder_rate >= 0.7
ORDER BY total_orders DESC;

-- Cleanup
DROP TABLE #base;


-- 07_advanced_insights.sql
-- ADVANCED ANALYTICS & BUSINESS INSIGHTS

USE [InstacartAnalyticsWarehouse];
GO

SET NOCOUNT ON;

-- Materialize relevant columns from fact_orders

IF OBJECT_ID('tempdb..#orders') IS NOT NULL DROP TABLE #orders;

SELECT
    user_id,
    order_id,
    order_number,
    product_id,
    days_since_prior_order,
    reordered
INTO #orders
FROM dbo.fact_orders;
GO

-- Product switching behaviour (user variety segmentation)

;WITH user_product_counts AS (
    SELECT
        user_id,
        COUNT(DISTINCT product_id) AS unique_products
    FROM #orders
    GROUP BY user_id
)
SELECT
    CASE 
        WHEN unique_products < 10 THEN 'low variety'
        WHEN unique_products < 30 THEN 'medium variety'
        ELSE 'high variety'
    END AS behaviour,
    COUNT_BIG(*) AS num_users,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_users
FROM user_product_counts
GROUP BY 
    CASE 
        WHEN unique_products < 10 THEN 'low variety'
        WHEN unique_products < 30 THEN 'medium variety'
        ELSE 'high variety'
    END
ORDER BY num_users DESC;
GO

-- Predictable users

;WITH user_orders AS (
    SELECT 
        user_id,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) AS total_reorders
    FROM dbo.fact_orders
    GROUP BY user_id
)
SELECT TOP 20
    user_id,
    total_orders,
    CAST(1.0 * total_reorders / total_orders * 100 AS DECIMAL(5,2)) AS reorder_rate_pct
FROM user_orders
WHERE total_orders > 1  -- only users with at least 2 orders
ORDER BY reorder_rate_pct DESC, total_orders DESC;
GO

-- Product dependency (average purchase position)

;WITH high_signal_products AS (
    SELECT
        product_id,
        COUNT_BIG(*) AS total_purchases,
        AVG(CAST(order_number AS FLOAT)) AS avg_purchase_position
    FROM #orders
    GROUP BY product_id
    HAVING COUNT_BIG(*) > 50  -- ignore low-signal products
)
SELECT *
FROM high_signal_products
ORDER BY avg_purchase_position;
GO

-- Cross-product affinity (co-occurrence)

;WITH top_products AS (
    SELECT TOP 500 product_id
    FROM #orders
    GROUP BY product_id
    ORDER BY COUNT_BIG(*) DESC
)
SELECT TOP 50
    a.product_id AS product_a,
    b.product_id AS product_b,
    COUNT_BIG(*) AS co_occurrence
FROM #orders a
JOIN #orders b
    ON a.order_id = b.order_id
    AND a.product_id < b.product_id
WHERE a.product_id IN (SELECT product_id FROM top_products)
  AND b.product_id IN (SELECT product_id FROM top_products)
GROUP BY a.product_id, b.product_id
HAVING COUNT_BIG(*) > 100
ORDER BY co_occurrence DESC;
GO

-- Pareto analysis (cumulative product contribution)

;WITH product_sales AS (
    SELECT
        product_id,
        COUNT_BIG(*) AS total_orders
    FROM #orders
    GROUP BY product_id
),
ranked AS (
    SELECT
        product_id,
        total_orders,
        SUM(total_orders) OVER (ORDER BY total_orders DESC ROWS UNBOUNDED PRECEDING) AS cumulative_orders,
        SUM(total_orders) OVER () AS total_all_orders
    FROM product_sales
)
SELECT
    product_id,
    total_orders,
    CAST(100.0 * cumulative_orders / total_all_orders AS DECIMAL(5,2)) AS cumulative_pct
FROM ranked
ORDER BY total_orders DESC;
GO

-- Cleanup temporary table

DROP TABLE #orders;
GO
