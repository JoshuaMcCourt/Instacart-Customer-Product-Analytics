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