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
