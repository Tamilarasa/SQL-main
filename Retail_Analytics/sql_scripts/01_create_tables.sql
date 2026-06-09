
-- 01_create_tables.sql
-- MySQL 8+ compatible DDL
CREATE DATABASE IF NOT EXISTS retail_analytics;
USE retail_analytics;

DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  region VARCHAR(50),
  age INT,
  join_date DATE,
  loyalty_points INT DEFAULT 0,
  email VARCHAR(120)
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(150) NOT NULL,
  category VARCHAR(80),
  brand VARCHAR(80),
  cost DECIMAL(10,2) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  CHECK (price >= cost)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  order_date DATETIME NOT NULL,
  customer_id INT NOT NULL,
  payment_method VARCHAR(50),
  discount_percent INT DEFAULT 0,
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_details (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  price_each DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id),
  CONSTRAINT fk_od_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_od_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Helpful indexes
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_customers_region ON customers(region);
CREATE INDEX idx_products_category ON products(category);
