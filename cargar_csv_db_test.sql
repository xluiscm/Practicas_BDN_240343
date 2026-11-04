-- Cargas CSV para db_test.
-- Edita cada ruta LOCAL INFILE para que apunte al archivo CSV en el equipo cliente.
-- Los CSV deben tener encabezado, delimitador coma y campos de texto entre comillas dobles.
-- En Windows se usa CRLF. Si el archivo CSV usa LF solamente, cambia '\r\n' por '\n'.
-- No incluye comandos para crear usuarios ni conceder permisos.

USE `db_test`;
SET NAMES utf8mb4;

-- CSV encabezado: category_ID,product_ID,status
LOAD DATA LOCAL INFILE 'C:/Users/ti_la/Downloads/categorizacion_de_productos.csv'
INTO TABLE `db_test`.`tbd_products_categories`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(`category_ID`, `product_ID`, `status`)
SET
  `creation_date` = CURRENT_TIMESTAMP,
  `last_update` = CURRENT_TIMESTAMP;

-- CSV encabezado: SKU,name,description,current_price,current_stock,status
LOAD DATA LOCAL INFILE 'C:/Users/ti_la/Downloads/productos.csv'
INTO TABLE `db_test`.`tb_products`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@SKU, @name, @description, @price, @stock, @status)
SET
  `SKU` = @SKU,
  `name` = @name,
  `description` = NULLIF(@description, ''),
  `current_price` = @price,
  `current_stock` = @stock,
  `status` = IF(@status = '1', b'1', b'0'),
  `creation_date` = CURRENT_TIMESTAMP,
  `last_update` = CURRENT_TIMESTAMP;

-- CSV encabezado: email,nick,password,status
-- password debe estar en el formato hash que espera la aplicación.
LOAD DATA LOCAL INFILE 'C:/Users/ti_la/Downloads/usuarios.csv'
INTO TABLE `db_test`.`tb_users`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@email, @nick, @password, @status)
SET
  `email` = @email,
  `nick` = @nick,
  `password` = @password,
  `status` = IF(@status = '1', b'1', b'0'),
  `creation_date` = CURRENT_TIMESTAMP,
  `last_update` = NULL,
  `last_login` = NULL;
