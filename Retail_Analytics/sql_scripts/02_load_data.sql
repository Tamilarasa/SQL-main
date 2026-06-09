
-- 02_load_data.sql
-- Load CSVs into MySQL (adjust LOCAL and absolute paths as needed)
USE retail_analytics;

-- Tip: Ensure MySQL has 'local_infile=ON' and you have FILE privileges if using LOCAL.

LOAD DATA LOCAL INFILE 'data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, name, region, age, @join_date, loyalty_points, email)
SET join_date = STR_TO_DATE(@join_date, '%Y-%m-%d');

LOAD DATA LOCAL INFILE 'data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, category, brand, cost, price);

LOAD DATA LOCAL INFILE 'data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, @order_date, customer_id, payment_method, discount_percent)
SET order_date = STR_TO_DATE(@order_date, '%Y-%m-%d %H:%i:%s');

LOAD DATA LOCAL INFILE 'data/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, product_id, quantity, price_each, total_price);
