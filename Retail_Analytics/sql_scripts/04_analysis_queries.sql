
-- 04_analysis_queries.sql
USE retail_analytics;

-- 1) Monthly sales trend (gross & profit)
WITH monthly AS (
  SELECT DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
         SUM(order_gross) AS gross,
         SUM(order_profit) AS profit
  FROM v_orders_enriched
  GROUP BY 1
)
SELECT month_start,
       gross,
       profit,
       LAG(gross) OVER (ORDER BY month_start) AS prev_gross,
       ROUND((gross - LAG(gross) OVER (ORDER BY month_start)) / NULLIF(LAG(gross) OVER (ORDER BY month_start),0) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY month_start;

-- 2) Top 10 products by revenue
SELECT p.product_id, p.product_name, p.category, SUM(od.total_price) AS revenue
FROM order_details od
JOIN products p ON p.product_id = od.product_id
GROUP BY 1,2,3
ORDER BY revenue DESC
LIMIT 10;

-- 3) Top 5 customers per region by spend (window function)
WITH spend AS (
  SELECT c.region, c.customer_id, SUM(od.total_price) AS total_spend
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  JOIN order_details od ON od.order_id = o.order_id
  GROUP BY 1,2
)
SELECT region, customer_id, total_spend
FROM (
  SELECT region, customer_id, total_spend,
         DENSE_RANK() OVER (PARTITION BY region ORDER BY total_spend DESC) AS rnk
  FROM spend
) t
WHERE rnk <= 5
ORDER BY region, total_spend DESC;

-- 4) RFM analysis
WITH base AS (
  SELECT
    o.customer_id,
    MAX(o.order_date) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS frequency,
    SUM(od.total_price) AS monetary
  FROM orders o
  JOIN order_details od ON od.order_id = o.order_id
  GROUP BY 1
),
scores AS (
  SELECT
    customer_id,
    DATEDIFF((SELECT MAX(order_date) FROM orders), last_order_date) AS recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY DATEDIFF((SELECT MAX(order_date) FROM orders), last_order_date)) AS r_score,
    NTILE(5) OVER (ORDER BY frequency) AS f_score,
    NTILE(5) OVER (ORDER BY monetary) AS m_score
  FROM base
)
SELECT *, CONCAT(r_score,f_score,m_score) AS rfm_segment
FROM scores
ORDER BY r_score DESC, f_score DESC, m_score DESC;

-- 5) Churn detection: customers inactive for > 180 days
SELECT c.customer_id, c.name, MAX(o.order_date) AS last_order_date,
       DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(o.order_date)) AS days_inactive
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING days_inactive > 180
ORDER BY days_inactive DESC;

-- 6) ABC analysis (Pareto by revenue)
WITH prod_rev AS (
  SELECT p.product_id, p.product_name, SUM(od.total_price) AS revenue
  FROM order_details od
  JOIN products p ON p.product_id = od.product_id
  GROUP BY 1,2
),
ordered AS (
  SELECT *,
         RANK() OVER (ORDER BY revenue DESC) AS rnk,
         SUM(revenue) OVER () AS total_rev,
         SUM(revenue) OVER (ORDER BY revenue DESC) AS cum_rev
  FROM prod_rev
)
SELECT product_id, product_name, revenue,
       ROUND(cum_rev/total_rev*100,2) AS cum_rev_pct,
       CASE
         WHEN cum_rev/total_rev <= 0.8 THEN 'A'
         WHEN cum_rev/total_rev <= 0.95 THEN 'B'
         ELSE 'C'
       END AS abc_class
FROM ordered
ORDER BY revenue DESC;

-- 7) Profitability by category & month
WITH cat_month AS (
  SELECT DATE_FORMAT(o.order_date, '%Y-%m-01') AS month_start,
         p.category,
         SUM(od.total_price) AS revenue,
         SUM(p.cost * od.quantity) AS cost,
         SUM(od.total_price) - SUM(p.cost * od.quantity) AS profit
  FROM orders o
  JOIN order_details od ON od.order_id = o.order_id
  JOIN products p ON p.product_id = od.product_id
  GROUP BY 1,2
)
SELECT *,
       ROUND(profit / NULLIF(revenue,0) * 100,2) AS margin_pct
FROM cat_month
ORDER BY month_start, category;
