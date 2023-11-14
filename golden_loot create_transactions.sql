SET AUTOCOMMIT = 0;


START TRANSACTION;
DELETE FROM clients WHERE client_id = 3;
-- ROLLBACK;
COMMIT;

START TRANSACTION; 
INSERT INTO products VALUES 
(NULL, 'Calzado', 2, 6, 'Gundam white', NULL, 13, 230),
(NULL, 'Calzado', 2, 4, 'Why so sad', NULL, 12, 200),
(NULL, 'Calzado', 2, 4, 'Muslin', NULL, 11, 320),
(NULL, 'Calzado', 2, 4, 'Phillies', NULL, 8, 220);
SAVEPOINT sp1;
INSERT INTO products VALUES 
(NULL, 'Calzado', 3, 18, 'Slate grey', NULL, 10, 200),
(NULL, 'Calzado', 3, 21, 'Utility black', NULL, 14, 300),
(NULL, 'Calzado', 3, 21, 'Wave runner', NULL, 5, 320),
(NULL, 'Indumentaria', 6, 26, 'Roses are red', NULL, 23, 110);
SAVEPOINT sp2;
COMMIT;
-- RELEASE SAVEPOINT sp1;