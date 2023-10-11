CREATE SCHEMA golden_loot;

USE golden_loot;

CREATE TABLE sizes(
	size_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    size_value VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE models(
	model_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    model_name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE brands(
	brand_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    brand_name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE categories(
	category_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    category_name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE cities(
	city_postal_code INT NOT NULL UNIQUE PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL
);

CREATE TABLE provinces(
	province_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    province_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products(
	product_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    product_category INT NOT NULL,
    product_brand INT NOT NULL,
    product_model INT NOT NULL,
    product_name VARCHAR(50) NOT NULL UNIQUE,
    product_description VARCHAR(200),
    product_size INT NOT NULL,
    product_price DECIMAL(11,2) NOT NULL,
    FOREIGN KEY (product_category) REFERENCES categories(category_id),
    FOREIGN KEY (product_brand) REFERENCES brands(brand_id),
    FOREIGN KEY (product_model) REFERENCES models(model_id),
    FOREIGN KEY (product_size) REFERENCES sizes(size_id)
);

CREATE TABLE clients(
	client_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    client_name VARCHAR(50) NOT NULL,
    document_type VARCHAR(20) NOT NULL,
    document_number INT NOT NULL UNIQUE,
    client_address VARCHAR(50),
    province INT,
    postal_code INT,
    FOREIGN KEY (province) REFERENCES provinces(province_id),
    FOREIGN KEY (postal_code) REFERENCES cities(city_postal_code)
);


CREATE TABLE orders(
	order_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    client_id INT NOT NULL,
    order_date DATE DEFAULT (CURRENT_DATE),
    total DECIMAL(11,2) DEFAULT 0,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE order_detail(
	order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);