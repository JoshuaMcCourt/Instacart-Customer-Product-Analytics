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