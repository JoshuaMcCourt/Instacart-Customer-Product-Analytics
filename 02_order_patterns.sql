-- 02_order_patterns.sql
-- TEMPORAL ORDER PATTERNS

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize required columns only
SELECT 
    order_dow,
    order_hour_of_day,
    days_since_prior_order
INTO #base
FROM dbo.fact_orders;

-- Orders by hour (with % of total)
WITH hourly AS (
    SELECT 
        order_hour_of_day,
        COUNT_BIG(*) AS total_orders
    FROM #base
    GROUP BY order_hour_of_day
)
SELECT
    order_hour_of_day,
    total_orders,
    CAST(100.0 * total_orders / SUM(total_orders) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM hourly
ORDER BY order_hour_of_day;

-- Orders by day of week (with rank)
WITH dow AS (
    SELECT 
        order_dow,
        COUNT_BIG(*) AS total_orders
    FROM #base
    GROUP BY order_dow
)
SELECT
    order_dow,
    total_orders,
    RANK() OVER (ORDER BY total_orders DESC) AS popularity_rank
FROM dow
ORDER BY popularity_rank;

-- Weekday vs weekend split (0=Sunday, 6=Saturday)
SELECT
    CASE 
        WHEN order_dow IN (0,6) THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    COUNT_BIG(*) AS total_orders,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM #base
GROUP BY 
    CASE 
        WHEN order_dow IN (0,6) THEN 'weekend'
        ELSE 'weekday'
    END;

-- Time between orders distribution
SELECT
    days_since_prior_order,
    COUNT_BIG(*) AS frequency
FROM #base
GROUP BY days_since_prior_order
ORDER BY days_since_prior_order;

-- Heatmap base: day of week × hour
SELECT
    order_dow,
    order_hour_of_day,
    COUNT_BIG(*) AS order_volume
FROM #base
GROUP BY order_dow, order_hour_of_day
ORDER BY order_dow, order_hour_of_day;

-- Cleanup
DROP TABLE #base;
