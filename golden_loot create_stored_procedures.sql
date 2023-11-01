DELIMITER $$
CREATE PROCEDURE `sp_get_products_ordered` (IN ord VARCHAR(20), IN dir VARCHAR(5))
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

CALL sp_get_products_ordered('product_price','');

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

CALL sp_increase_prices(1, 100);