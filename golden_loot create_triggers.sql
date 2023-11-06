-- TABLA DE LOGS Y TRIGGERS PARA TABLA clients
CREATE TABLE clients_log (
	id_log INT PRIMARY KEY NOT NULL AUTO_INCREMENT UNIQUE,
    action_realized ENUM('Insert', 'Update', 'Delete') NOT NULL,
    client_id INT NOT NULL,
    action_dt DATETIME DEFAULT (CURRENT_TIMESTAMP),
    author VARCHAR(100)
);

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

-- ESTE TRIGGER CHEQUEA QUE LA PROVINCIA COINCIDA CON EL CP QUE SE CARGA 
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


-- TABLA DE LOGS Y TRIGGERS PARA TABLA products
CREATE TABLE products_log (
	id_log INT PRIMARY KEY NOT NULL AUTO_INCREMENT UNIQUE,
    action_realized ENUM('Insert', 'Update', 'Delete') NOT NULL,
    product_id INT NOT NULL,
    action_dt DATETIME DEFAULT (CURRENT_TIMESTAMP),
    author VARCHAR(100)
);

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

-- ESTE TRIGGER CHEQUEA QUE NO SE CARGUE UN STRING VACÍO EN product_name
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
