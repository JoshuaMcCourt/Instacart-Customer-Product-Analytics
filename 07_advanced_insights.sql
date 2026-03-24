-- 07_advanced_insights.sql
-- ADVANCED ANALYTICS & BUSINESS INSIGHTS

USE [InstacartAnalyticsWarehouse];
GO

SET NOCOUNT ON;

-- Materialize relevant columns from fact_orders

IF OBJECT_ID('tempdb..#orders') IS NOT NULL DROP TABLE #orders;

SELECT
    user_id,
    order_id,
    order_number,
    product_id,
    days_since_prior_order,
    reordered
INTO #orders
FROM dbo.fact_orders;
GO

-- Product switching behaviour (user variety segmentation)

;WITH user_product_counts AS (
    SELECT
        user_id,
        COUNT(DISTINCT product_id) AS unique_products
    FROM #orders
    GROUP BY user_id
)
SELECT
    CASE 
        WHEN unique_products < 10 THEN 'low variety'
        WHEN unique_products < 30 THEN 'medium variety'
        ELSE 'high variety'
    END AS behaviour,
    COUNT_BIG(*) AS num_users,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_users
FROM user_product_counts
GROUP BY 
    CASE 
        WHEN unique_products < 10 THEN 'low variety'
        WHEN unique_products < 30 THEN 'medium variety'
        ELSE 'high variety'
    END
ORDER BY num_users DESC;
GO

-- Predictable users

;WITH user_orders AS (
    SELECT 
        user_id,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) AS total_reorders
    FROM dbo.fact_orders
    GROUP BY user_id
)
SELECT TOP 20
    user_id,
    total_orders,
    CAST(1.0 * total_reorders / total_orders * 100 AS DECIMAL(5,2)) AS reorder_rate_pct
FROM user_orders
WHERE total_orders > 1  -- only users with at least 2 orders
ORDER BY reorder_rate_pct DESC, total_orders DESC;
GO

-- Product dependency (average purchase position)

;WITH high_signal_products AS (
    SELECT
        product_id,
        COUNT_BIG(*) AS total_purchases,
        AVG(CAST(order_number AS FLOAT)) AS avg_purchase_position
    FROM #orders
    GROUP BY product_id
    HAVING COUNT_BIG(*) > 50  -- ignore low-signal products
)
SELECT *
FROM high_signal_products
ORDER BY avg_purchase_position;
GO

-- Cross-product affinity (co-occurrence)

;WITH top_products AS (
    SELECT TOP 500 product_id
    FROM #orders
    GROUP BY product_id
    ORDER BY COUNT_BIG(*) DESC
)
SELECT TOP 50
    a.product_id AS product_a,
    b.product_id AS product_b,
    COUNT_BIG(*) AS co_occurrence
FROM #orders a
JOIN #orders b
    ON a.order_id = b.order_id
    AND a.product_id < b.product_id
WHERE a.product_id IN (SELECT product_id FROM top_products)
  AND b.product_id IN (SELECT product_id FROM top_products)
GROUP BY a.product_id, b.product_id
HAVING COUNT_BIG(*) > 100
ORDER BY co_occurrence DESC;
GO

-- Pareto analysis (cumulative product contribution)

;WITH product_sales AS (
    SELECT
        product_id,
        COUNT_BIG(*) AS total_orders
    FROM #orders
    GROUP BY product_id
),
ranked AS (
    SELECT
        product_id,
        total_orders,
        SUM(total_orders) OVER (ORDER BY total_orders DESC ROWS UNBOUNDED PRECEDING) AS cumulative_orders,
        SUM(total_orders) OVER () AS total_all_orders
    FROM product_sales
)
SELECT
    product_id,
    total_orders,
    CAST(100.0 * cumulative_orders / total_all_orders AS DECIMAL(5,2)) AS cumulative_pct
FROM ranked
ORDER BY total_orders DESC;
GO

-- Cleanup temporary table

DROP TABLE #orders;
GO
