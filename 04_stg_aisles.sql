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
