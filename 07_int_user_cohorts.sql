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
