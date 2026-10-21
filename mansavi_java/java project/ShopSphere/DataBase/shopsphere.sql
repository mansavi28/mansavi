-- =====================================================
-- ShopSphere Database Script
-- Run this whole file in MySQL Workbench or the MySQL
-- Command Line Client. It can be re-run safely: it
-- drops and recreates the tables each time.
-- =====================================================

CREATE DATABASE IF NOT EXISTS shopsphere
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE shopsphere;

-- Drop old tables (children first, so foreign keys don't complain)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS coupon_usage;
DROP TABLE IF EXISTS coupons;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS wishlist;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;


-- =====================================================
-- PART A: Tables you need for the minimum working version
-- =====================================================

CREATE TABLE users (
    user_id     INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,          -- store a HASH, never plain text
    mobile      VARCHAR(15),
    role        ENUM('CUSTOMER', 'ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    status      TINYINT(1) NOT NULL DEFAULT 1,  -- 1 = active, 0 = blocked
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    address_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    address_line  VARCHAR(255) NOT NULL,
    city          VARCHAR(100) NOT NULL,
    state         VARCHAR(100) NOT NULL,
    pincode       VARCHAR(10)  NOT NULL,
    address_type  ENUM('HOME', 'WORK', 'OTHER') NOT NULL DEFAULT 'HOME',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE categories (
    category_id  INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    description  VARCHAR(255),
    status       TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_id  INT NOT NULL,
    name         VARCHAR(150) NOT NULL,
    brand        VARCHAR(100),
    description  TEXT,
    price        DECIMAL(10,2) NOT NULL,
    discount     DECIMAL(5,2) NOT NULL DEFAULT 0,  -- percent, e.g. 10 = 10% off
    stock        INT NOT NULL DEFAULT 0,
    image_url    VARCHAR(255),
    status       TINYINT(1) NOT NULL DEFAULT 1,    -- 1 = visible, 0 = hidden
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE cart (
    cart_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL,
    product_id  INT NOT NULL,
    quantity    INT NOT NULL DEFAULT 1,
    UNIQUE (user_id, product_id),                  -- same product can't appear twice
    FOREIGN KEY (user_id)    REFERENCES users(user_id)       ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    address_id      INT NOT NULL,
    total_amount    DECIMAL(10,2) NOT NULL,
    discount        DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_method  ENUM('COD', 'UPI', 'CARD') NOT NULL DEFAULT 'COD',
    payment_status  ENUM('PENDING', 'PAID', 'FAILED') NOT NULL DEFAULT 'PENDING',
    order_status    ENUM('PLACED', 'PACKED', 'SHIPPED', 'DELIVERED', 'CANCELLED')
                    NOT NULL DEFAULT 'PLACED',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES users(user_id),
    FOREIGN KEY (address_id) REFERENCES addresses(address_id)
);

CREATE TABLE order_items (
    order_item_id  INT AUTO_INCREMENT PRIMARY KEY,
    order_id       INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL,
    price          DECIMAL(10,2) NOT NULL,         -- price at the time of purchase
    FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id             INT AUTO_INCREMENT PRIMARY KEY,
    order_id               INT NOT NULL,
    payment_method         ENUM('COD', 'UPI', 'CARD') NOT NULL,
    transaction_reference  VARCHAR(100),
    amount                 DECIMAL(10,2) NOT NULL,
    payment_status         ENUM('PENDING', 'PAID', 'FAILED') NOT NULL DEFAULT 'PENDING',
    created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);


-- =====================================================
-- PART B: Tables for later (wishlist, reviews, coupons)
-- Created now so your ER diagram matches the project
-- guide, but you don't need them until Group B.
-- =====================================================

CREATE TABLE wishlist (
    wishlist_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    product_id   INT NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)       ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE reviews (
    review_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    product_id   INT NOT NULL,
    rating       TINYINT NOT NULL,                 -- 1 to 5
    review_text  VARCHAR(500),
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)       ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE coupons (
    coupon_id         INT AUTO_INCREMENT PRIMARY KEY,
    code              VARCHAR(30) NOT NULL UNIQUE,
    discount_type     ENUM('PERCENT', 'FLAT') NOT NULL,
    discount_value    DECIMAL(10,2) NOT NULL,
    minimum_order     DECIMAL(10,2) NOT NULL DEFAULT 0,
    maximum_discount  DECIMAL(10,2),
    expiry_date       DATE,
    status            TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE coupon_usage (
    usage_id   INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id  INT NOT NULL,
    user_id    INT NOT NULL,
    order_id   INT NOT NULL,
    used_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id),
    FOREIGN KEY (user_id)   REFERENCES users(user_id),
    FOREIGN KEY (order_id)  REFERENCES orders(order_id) ON DELETE CASCADE
);


-- =====================================================
-- SAMPLE DATA
-- (No users yet: register through the app so that the
-- password gets hashed properly. See the guide for how
-- to make one user an ADMIN.)
-- =====================================================

INSERT INTO categories (name, description) VALUES
    ('Mobiles',     'Smartphones and accessories'),
    ('Laptops',     'Laptops and notebooks'),
    ('Books',       'Textbooks and novels'),
    ('Fashion',     'Clothing and footwear');

INSERT INTO products (category_id, name, brand, description, price, discount, stock, image_url) VALUES
    (1, 'Nova X5 Smartphone',   'Nova',     '6.5 inch display, 128 GB storage, 5000 mAh battery', 14999.00, 10, 25, 'images/mobile1.jpg'),
    (1, 'Pixel Lite 5G',        'PixelCo',  '5G phone with a 50 MP camera',                       19999.00,  5, 18, 'images/mobile2.jpg'),
    (1, 'Fast Charger 33W',     'VoltPlus', 'Quick charger with Type-C cable',                      799.00,  0, 100, 'images/charger.jpg'),
    (2, 'ProBook 14 Laptop',    'Zenith',   '14 inch, 8 GB RAM, 512 GB SSD',                      45999.00,  8, 10, 'images/laptop1.jpg'),
    (2, 'StudentBook 15',       'Zenith',   '15.6 inch, 8 GB RAM, 256 GB SSD',                    32999.00, 12, 14, 'images/laptop2.jpg'),
    (2, 'Wireless Mouse',       'ClickPro', '2.4 GHz wireless optical mouse',                       499.00,  0, 60, 'images/mouse.jpg'),
    (3, 'Core Java Handbook',   'TechPress','Complete guide to Java fundamentals',                  650.00, 15, 40, 'images/book1.jpg'),
    (3, 'Advanced Java Notes',  'TechPress','Servlets, JSP, JDBC and RMI explained simply',         550.00, 10, 35, 'images/book2.jpg'),
    (3, 'SQL Made Easy',        'LearnHub', 'Beginner friendly database book',                      399.00,  5, 50, 'images/book3.jpg'),
    (4, 'Cotton T-Shirt',       'UrbanWear','100% cotton, regular fit',                             599.00, 20, 80, 'images/tshirt.jpg'),
    (4, 'Running Shoes',        'StrideX',  'Lightweight everyday running shoes',                  1999.00, 15, 30, 'images/shoes.jpg'),
    (4, 'Denim Jacket',         'UrbanWear','Classic blue denim jacket',                           2499.00, 10, 20, 'images/jacket.jpg');

INSERT INTO coupons (code, discount_type, discount_value, minimum_order, maximum_discount, expiry_date) VALUES
    ('WELCOME10', 'PERCENT', 10.00,  500.00, 200.00, '2027-12-31'),
    ('FLAT100',   'FLAT',   100.00, 1000.00,   NULL, '2027-12-31');


-- =====================================================
-- QUICK CHECKS (run these after the script)
-- =====================================================
-- SHOW TABLES;
-- SELECT COUNT(*) FROM products;           -- should be 12
-- SELECT name, price FROM products WHERE category_id = 3;
