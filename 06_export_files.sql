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
FROM dbo.dim_fact_orders;

-- 4) fact_user_product
SELECT * 
FROM dbo.dim_fact_user_product;

-- 5) fact_user_cohorts
SELECT * 
FROM dbo.dim_fact_user_cohorts;

