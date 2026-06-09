
-- 05_views_procedures.sql
USE retail_analytics;

-- View: customer lifetime value (simple version)
CREATE OR REPLACE VIEW v_clv AS
SELECT
  c.customer_id,
  c.name,
  c.region,
  SUM(od.total_price) AS lifetime_revenue,
  COUNT(DISTINCT o.order_id) AS orders_count,
  MIN(o.order_date) AS first_purchase,
  MAX(o.order_date) AS last_purchase
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_details od ON od.order_id = o.order_id
GROUP BY 1,2,3;

-- Stored Procedure: Top N products by profit within date range
DROP PROCEDURE IF EXISTS sp_top_products_profit;
DELIMITER //
CREATE PROCEDURE sp_top_products_profit(IN p_start DATE, IN p_end DATE, IN p_limit INT)
BEGIN
  SELECT p.product_id, p.product_name,
         SUM(od.total_price - (p.cost * od.quantity)) AS profit
  FROM orders o
  JOIN order_details od ON od.order_id = o.order_id
  JOIN products p ON p.product_id = od.product_id
  WHERE o.order_date >= p_start AND o.order_date < DATE_ADD(p_end, INTERVAL 1 DAY)
  GROUP BY 1,2
  ORDER BY profit DESC
  LIMIT p_limit;
END //
DELIMITER ;

-- Trigger: ensure total_price = quantity * price_each on insert/update
DROP TRIGGER IF EXISTS trg_od_calc_total;
DELIMITER //
CREATE TRIGGER trg_od_calc_total BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
  SET NEW.total_price = NEW.quantity * NEW.price_each;
END //
DELIMITER ;
