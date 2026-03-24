-- 06_stg_quality_checks.sql
-- STAGING DATA QUALITY CHECKS

USE [InstacartAnalyticsWarehouse];
GO

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