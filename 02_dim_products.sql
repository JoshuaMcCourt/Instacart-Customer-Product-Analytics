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