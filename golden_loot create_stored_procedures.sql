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

CALL sp_get_products_ordered('product_price','desc');