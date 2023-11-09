DELIMITER $$
CREATE FUNCTION `f_product_total` (product_price INT, quantity INT)
	RETURNS INT
	DETERMINISTIC
BEGIN
	RETURN product_price * quantity;
END $$

SELECT order_id, product_price, quantity, f_product_total(product_price, quantity) AS product_total FROM order_detailed

DELIMITER $$
CREATE FUNCTION `f_order_total` (id INT)
	RETURNS DECIMAL(11,2)
	DETERMINISTIC
BEGIN
	DECLARE order_total DECIMAL(11,2);
    SELECT SUM(f_product_total (product_price, quantity)) INTO order_total FROM golden_loot.order_detailed WHERE order_id = id;
	RETURN order_total;
END $$

SELECT f_order_total(1);


