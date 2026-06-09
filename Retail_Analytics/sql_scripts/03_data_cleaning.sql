
-- 03_data_cleaning.sql
USE retail_analytics;

-- Remove obvious duplicates (if any)
-- Example pattern, safe because our PKs prevent duplicates
-- But included to demonstrate technique:
DELETE od1 FROM order_details od1
JOIN order_details od2
  ON od1.order_id = od2.order_id
 AND od1.product_id = od2.product_id
 AND od1.ROWID > od2.ROWID; -- Works in some DBs; in MySQL use PK to avoid duplicates

-- Handle NULLs with COALESCE (demo via SELECT; not altering source)
-- Example: standardize region and payment method to 'Unknown' for NULLs when reporting
-- SELECT COALESCE(region, 'Unknown') AS region_norm FROM customers;

-- Standardize strings
UPDATE customers SET region = TRIM(region);
UPDATE products SET category = TRIM(category), brand = TRIM(brand);

-- Derived fields via views (profit, margin)
CREATE OR REPLACE VIEW v_order_lines AS
SELECT
  od.order_id,
  o.order_date,
  o.customer_id,
  od.product_id,
  p.category,
  p.brand,
  od.quantity,
  od.price_each,
  od.total_price,
  (p.cost * od.quantity) AS total_cost,
  (od.total_price - (p.cost * od.quantity)) AS line_profit
FROM order_details od
JOIN orders o   ON o.order_id = od.order_id
JOIN products p ON p.product_id = od.product_id;

CREATE OR REPLACE VIEW v_orders_enriched AS
SELECT
  o.order_id,
  o.order_date,
  c.region,
  c.customer_id,
  o.payment_method,
  o.discount_percent,
  SUM(od.total_price) AS order_gross,
  SUM(p.cost * od.quantity) AS order_cost,
  (SUM(od.total_price) - SUM(p.cost * od.quantity)) AS order_profit
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_details od ON od.order_id = o.order_id
JOIN products p ON p.product_id = od.product_id
GROUP BY 1,2,3,4,5,6;
