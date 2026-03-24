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