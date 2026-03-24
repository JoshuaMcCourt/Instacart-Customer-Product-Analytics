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
