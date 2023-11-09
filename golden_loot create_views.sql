SELECT * FROM golden_loot.products;

CREATE OR REPLACE VIEW product_detail AS 
(SELECT product_category, brand_name, model_name, product_name, product_description, size_value, product_price
	FROM products p 
    JOIN models m 
    ON 	p.product_model = m.model_id
    JOIN brands b 
    ON p.product_brand = b.brand_id
    JOIN sizes s
    ON p.product_size = s.size_id);
    
CREATE OR REPLACE VIEW price_below_200 AS 
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