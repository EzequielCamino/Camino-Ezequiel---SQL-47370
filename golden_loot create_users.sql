-- CREA USUARIO user
CREATE USER  user@localhost IDENTIFIED BY 'user';
-- LE CONCEDE ACCESO DE SOLO LECTURA A user
GRANT SELECT ON golden_loot.* TO user@localhost;
-- SHOW GRANTS FOR user@localhost;

-- CREA USUARIO admin
CREATE USER admin@localhost IDENTIFIED BY 'admin';
-- LE CONCEDE ACCESO DE LECTURA, INSERCIÓN Y MODIFICACIÓN DE DATOS A admin
GRANT SELECT ON golden_loot.* TO admin@localhost;
GRANT INSERT ON golden_loot.* TO admin@localhost;
GRANT UPDATE ON golden_loot.* TO admin@localhost;
-- SHOW GRANTS FOR admin@localhost;