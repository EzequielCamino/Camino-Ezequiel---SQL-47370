-- CREATE SCHEMA
CREATE SCHEMA golden_loot;
USE golden_loot;



-- CREATE TABLES

CREATE TABLE sizes(
	size_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    size_value VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE models(
	model_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    model_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE brands(
	brand_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    brand_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE provinces(
	province_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    province_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE cities(
	city_postal_code INT NOT NULL UNIQUE PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL,
    province_id INT NOT NULL,
    FOREIGN KEY (province_id) REFERENCES provinces(province_id)
);

CREATE TABLE products(
	product_id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    product_category ENUM('Calzado', 'Indumentaria', 'Accesorios') NOT NULL,
    product_brand INT NOT NULL,
    product_model INT NOT NULL,
    product_name VARCHAR(50) NOT NULL UNIQUE,
    product_description VARCHAR(200),
    product_size INT NOT NULL,
    product_price DECIMAL(11,2) NOT NULL,
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

-- LOG TABLES
CREATE TABLE clients_log (
	id_log INT PRIMARY KEY NOT NULL AUTO_INCREMENT UNIQUE,
    action_realized ENUM('Insert', 'Update', 'Delete') NOT NULL,
    client_id INT NOT NULL,
    action_dt DATETIME DEFAULT (CURRENT_TIMESTAMP),
    author VARCHAR(100)
);

CREATE TABLE products_log (
	id_log INT PRIMARY KEY NOT NULL AUTO_INCREMENT UNIQUE,
    action_realized ENUM('Insert', 'Update', 'Delete') NOT NULL,
    product_id INT NOT NULL,
    action_dt DATETIME DEFAULT (CURRENT_TIMESTAMP),
    author VARCHAR(100)
);



-- CREATE VIEWS

CREATE OR REPLACE VIEW product_detail AS 
(SELECT product_category, brand_name, model_name, product_name, product_description, size_value, product_price
	FROM products p 
    JOIN models m 
    ON 	p.product_model = m.model_id
    JOIN brands b 
    ON p.product_brand = b.brand_id
    JOIN sizes s
    ON p.product_size = s.size_id);
    
CREATE OR REPLACE VIEW Price_below_200 AS 
(SELECT product_category, product_brand, product_model, product_name, product_description, product_size, product_price
	FROM products p 
    where product_price <= 200);
    
CREATE OR REPLACE VIEW product_sneakers AS 
(SELECT product_category, product_brand, product_model, product_name, product_description, product_size, product_price
	FROM products p 
    where product_category = 'calzado');
    
CREATE OR REPLACE VIEW product_specific_size AS 
(SELECT product_category, product_brand, product_model, product_name, product_description, size_value, product_price
	FROM products p 
    JOIN sizes s 
    ON p.product_size = s.size_id
    where size_value = '8.5US');
    
CREATE OR REPLACE VIEW brand_nike AS 
(SELECT product_category, brand_name, product_model, product_name, product_description, product_size, product_price
	FROM products p 
    JOIN brands b 
    ON p.product_brand = b.brand_id
    where brand_name LIKE 'nike%');
    
CREATE OR REPLACE VIEW order_detailed AS
(SELECT order_id, product_price, quantity
	FROM order_detail od
	JOIN products p
    ON od.product_id = p.product_id);



-- CREATE FUNCTIONS

-- CALCULA EL TOTAL COMPRADO DE UN PRODUCTO
DELIMITER $$
CREATE FUNCTION `f_product_total` (product_price INT, quantity INT)
	RETURNS INT
	DETERMINISTIC
BEGIN
	RETURN product_price * quantity;
END $$

-- CALCULA EL TOTAL DE LA ORDEN
DELIMITER $$
CREATE FUNCTION `f_order_total` (id INT)
	RETURNS DECIMAL(11,2)
	DETERMINISTIC
BEGIN
	DECLARE order_total DECIMAL(11,2);
    SELECT SUM(product_total) INTO order_total FROM golden_loot.order_detailed WHERE order_id = id;
	RETURN order_total;
END $$



-- CREATE STORED PROCEDURES

DELIMITER $$
CREATE PROCEDURE `sp_get_products_ordered` (IN ord VARCHAR(20), IN dir VARCHAR(5))
-- PRIMER PARÁMETRO: PALABRA PARA EL ORDENAMIENTO
-- SEGUNDO PARÁMETRO: ÓRDEN ASCENDENTE(ASC) O DESCENDENTE(DESC)
BEGIN
	IF ord <> '' THEN
		SET @product_order = concat('ORDER BY ', ord);
	ELSE
		SET @product_order = '';
	END IF;
    
    IF dir = 'DESC' THEN
		SET @order_direction = ' DESC';
	ELSE
		SET @order_direction = '';
	END IF;
    
    SET @clause = concat('SELECT * FROM products ', @product_order, @order_direction);
    PREPARE runSQL FROM @clause;
    EXECUTE runSQL;
    DEALLOCATE PREPARE runSQL;
END
$$

DELIMITER $$
CREATE PROCEDURE `sp_increase_prices` (IN id INT,IN percent INT)
-- PASAMOS COMO PRIMER PARÁMETRO EL ID DEL PRODUCTO A ACTUALIZAR EL PRECIO
-- PASAMOS COMO SEGUNDO PARÁMETRO EL PORCENTAJE DE AUMENTO QUE QUEREMOS APLICAR AL MISMO
BEGIN
	UPDATE products
    SET product_price=product_price*(percent/100+1)
    WHERE product_id=id;
END
$$



-- CREATE TRIGGERS

-- ESTE TRIGGER CHEQUEA QUE LA PROVINCIA COINCIDA CON EL postal_code QUE SE CARGA EN clients
DELIMITER $$
CREATE TRIGGER tr_check_cp_before_insert
BEFORE INSERT ON clients
FOR EACH ROW
BEGIN
	-- CREO LA VARIABLE province
	DECLARE province INT;
    -- BUSCO LA PROVINCIA EN MI TABLA cities EN BASE AL NEW.postal_code CARGADO Y LO CARGO EN LA VARIABLE province
	SELECT (province_id) INTO province FROM cities WHERE city_postal_code = NEW.postal_code;
    -- CHEQUEO SI LA NEW.province CARGADA COINCIDE CON EL NEW.postal_code
	IF NEW.province <> province THEN
    -- EN CASO QUE NO COINCIDA, SUSTITUYO EL VALOR DE NEW.province POR EL DE MI VARIABLE province PARA CARGAR AL CLIENTE CORRECTAMENTE
		SET NEW.province = province;
	END IF;
END
$$

-- ESTE TRIGGER CHEQUEA QUE NO SE CARGUE UN STRING VACÍO EN product_name EN products
DELIMITER $$
CREATE TRIGGER tr_check_values_before_insert_product
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	IF NEW.product_name = '' THEN
    -- SI product_name ES UN STRING VACÍO LO SETEO COMO NULL PARA FORZAR ERROR 1048 Y PREVENIR LA CARGA DE LOS DATOS
		SET NEW.product_name = NULL;
	END IF;
END
$$

-- TRIGGERS AFTER EN clients
CREATE TRIGGER `tr_insert_client`
AFTER INSERT ON `clients`
FOR EACH ROW
INSERT INTO `clients_log` (action_realized, client_id, author)
VALUES ('Insert', NEW.client_id, USER());

CREATE TRIGGER `tr_update_client`
AFTER UPDATE ON `clients`
FOR EACH ROW
INSERT INTO `clients_log` (action_realized, client_id, author)
VALUES ('Update', NEW.client_id, USER());

CREATE TRIGGER `tr_delete_client`
AFTER DELETE ON `clients`
FOR EACH ROW
INSERT INTO `clients_log` (action_realized, client_id, author)
VALUES ('Delete', OLD.client_id, USER());

-- TRIGGERS AFTER EN products
CREATE TRIGGER `tr_insert_product`
AFTER INSERT ON `products`
FOR EACH ROW
INSERT INTO `products_log` (action_realized, product_id, author)
VALUES ('Insert', NEW.product_id, USER());

CREATE TRIGGER `tr_update_product`
AFTER UPDATE ON `products`
FOR EACH ROW
INSERT INTO `products_log` (action_realized, product_id, author)
VALUES ('Update', NEW.product_id, USER());

CREATE TRIGGER `tr_delete_product`
AFTER DELETE ON `products`
FOR EACH ROW
INSERT INTO `products_log` (action_realized, product_id, author)
VALUES ('Delete', OLD.product_id, USER());



-- INSERTS

INSERT INTO sizes VALUES
(NULL, '4US'),
(NULL, '4.5US'),
(NULL, '5US'),
(NULL, '5.5US'),
(NULL, '6US'),
(NULL, '6.5US'),
(NULL, '7US'),
(NULL, '7.5US'),
(NULL, '8US'),
(NULL, '8.5US'),
(NULL, '9US'),
(NULL, '9.5US'),
(NULL, '10US'),
(NULL, '10.5US'),
(NULL, '11US'),
(NULL, '11.5US'),
(NULL, '12US'),
(NULL, '12.5US'),
(NULL, '13US'),
(NULL, 'XS'),
(NULL, 'S'),
(NULL, 'M'),
(NULL, 'L'),
(NULL, 'XL');

INSERT INTO provinces VALUES
(NULL, 'Buenos Aires'),
(NULL, 'CABA'),
(NULL, 'Córdoba'),
(NULL, 'Jujuy'),
(NULL, 'Tierra del Fuego'),
(NULL, 'Río Negro'),
(NULL, 'Chubut'),
(NULL, 'La Pampa'),
(NULL, 'Neuquén'),
(NULL, 'Mendoza'),
(NULL, 'San Luis'),
(NULL, 'San Juan'),
(NULL, 'Santa Fe'),
(NULL, 'Tucumán'),
(NULL, 'Corrientes'),
(NULL, 'Formosa'),
(NULL, 'Chaco'),
(NULL, 'Salta'),
(NULL, 'Misiones'),
(NULL, 'Santa Cruz'),
(NULL, 'Entre Ríos'),
(NULL, 'Santiago del Estero'),
(NULL, 'Catamarca'),
(NULL, 'La Rioja');

INSERT INTO brands VALUES
(NULL, 'Nike'),
(NULL, 'Nike SB'),
(NULL, 'Adidas'),
(NULL, 'New Balance'),
(NULL, 'Reebok'),
(NULL, 'Anti Social Social Club'),
(NULL, 'Supreme'),
(NULL, 'BAPE'),
(NULL, 'Vlone'),
(NULL, 'OVO'),
(NULL, 'Tommy Hilfiger');

INSERT INTO models VALUES
(NULL, 'Dunk Low'),
(NULL, 'Dunk Mid'),
(NULL, 'Dunk High'),
(NULL, 'Dunk SB Low'),
(NULL, 'Dunk SB Mid'),
(NULL, 'Dunk SB High'),
(NULL, 'Air Jordan 1 Low'),
(NULL, 'Air Jordan 1 Mid'),
(NULL, 'Air Jordan 1 High'),
(NULL, 'Air Jordan 2'),
(NULL, 'Air Jordan 3'),
(NULL, 'Air Jordan 4'),
(NULL, 'Air Jordan 6'),
(NULL, 'Air Max 1'),
(NULL, 'Air Max 97'),
(NULL, 'Air Max 1/97'),
(NULL, 'Yeezy 350'),
(NULL, 'Yeezy 350 V2'),
(NULL, 'Yeezy 380'),
(NULL, 'Yeezy 550'),
(NULL, 'Yeezy 700'),
(NULL, 'Yeezy 700 V2'),
(NULL, 'Yeezy 700 V3'),
(NULL, 'Yeezy 700 MNVN'),
(NULL, 'Yeezy Slides'),
(NULL, 'Tee-Shirt'),
(NULL, 'Long Sleeves Tee-Shirt');

INSERT INTO cities VALUES
(1900, 'La Plata', 1),
(1902, 'La Plata', 1),
(1904, 'La Plata', 1),
(1906, 'La Plata', 1),
(1912, 'La Plata', 1),
(1914, 'La Plata', 1),
(1926, 'La Plata', 1),
(1228, 'CABA', 2),
(1406, 'CABA', 2),
(1428, 'CABA', 2),
(1832, 'Lomas de Zamora', 1),
(5000, 'Córdoba', 3),
(4600, 'San Salvador de Jujuy', 4),
(9410, 'Ushuaia', 5),
(8500, 'Viedma', 6),
(9103, 'Rawson', 7),
(6300, 'Santa Rosa', 8),
(8300, 'Neuquén', 9),
(5500, 'Mendoza', 10),
(5700, 'San Luis', 11),
(5400, 'San Juan', 12),
(1689, 'Rosario', 13),
(4000, 'San Miguel de Tucumán', 14),
(3197, 'Corrientes', 15),
(3600, 'Formosa', 16),
(3500, 'Resistencia', 17),
(4400, 'Salta', 18),
(3300, 'Posadas', 19),
(9400, 'Río Gallegos', 20),
(3100, 'Paraná', 21),
(4200, 'Santiago del Estero', 22),
(4700, 'San Fernando del Valle de Catamarca', 23),
(5300, 'La Rioja', 24);

INSERT INTO clients VALUES
(NULL, 'Ezequiel Camino', 'DNI', 40251162, 'Puerto Madryn 1648', 1, 1832),
(NULL, 'Brandon Maidana', 'DNI', 11111111, 'La Plata 123', 1, 1902),
(NULL, 'Cosme Fulanito', 'DNI', 12345678, 'Calle Falsa 123', 13, 1689);

INSERT INTO products VALUES
(NULL, 'Calzado', 2, 4, 'ACG Terra', NULL, 10, 250),
(NULL, 'Calzado', 1, 14, 'Travis Scott Saturn Gold', NULL, 12, 300),
(NULL, 'Indumentaria', 7, 26, 'Undercover Face Black', NULL, 23, 100);

INSERT INTO orders(order_id, client_id, total) VALUES
(NULL, 1, 350),
(NULL, 2, 300);

INSERT INTO order_detail VALUES
(1, 1, 1),
(1, 3, 2),
(2, 2, 1);