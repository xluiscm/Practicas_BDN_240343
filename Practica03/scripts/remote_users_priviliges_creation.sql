-- 0. LIMPIEZA PREVIA (evita errores si ya existen usuarios o roles)
DROP USER IF EXISTS
    'luis.cazarez'@'%',
    'marco.ramirez'@'%',
    'aylin.luna'@'%',
    'saul.barrios'@'%',
    'jonhy.neri'@'%',
    'juan.cruz'@'%',
    'carlos.morales'@'%';

DROP ROLE IF EXISTS
    'superadmin',
    'admin',
    'seller',
    'buyer',
    'common',
    'user_not_registered',
    'support';


-- 1. CREACION DE USUARIOS REMOTOS
CREATE USER 'luis.cazarez'@'%'   IDENTIFIED BY '240343';    -- super admin
CREATE USER 'marco.ramirez'@'%'  IDENTIFIED BY 'qwerty123'; -- profe (admin)
CREATE USER 'aylin.luna'@'%'     IDENTIFIED BY '240853';    -- primer vendedor
CREATE USER 'saul.barrios'@'%'   IDENTIFIED BY '240196';    -- support
CREATE USER 'jonhy.neri'@'%'     IDENTIFIED BY '240558';    -- segundo vendedor
CREATE USER 'juan.cruz'@'%'      IDENTIFIED BY '240148';    -- usuario / comprador
CREATE USER 'carlos.morales'@'%' IDENTIFIED BY '240221';    -- usuario / comprador


-- 2. CREACION DE ROLES PARA ECOMMERCE
CREATE ROLE 'superadmin';
CREATE ROLE 'admin';
CREATE ROLE 'seller';
CREATE ROLE 'buyer';
CREATE ROLE 'common';
CREATE ROLE 'user_not_registered';
CREATE ROLE 'support';


-- 3. ASIGNACION DE PRIVILEGIOS A LOS ROLES

-- ---------------------------------------------------------------------
-- SUPERADMIN
-- ---------------------------------------------------------------------
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;

-- ---------------------------------------------------------------------
-- ADMIN
-- ---------------------------------------------------------------------
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

-- ---------------------------------------------------------------------
-- SUPPORT
-- ---------------------------------------------------------------------
-- Puede visualizar todas las tablas y vistas
GRANT SELECT ON db_test.* TO 'support';

-- Puede insertar y actualizar usuarios
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';

-- Puede insertar y actualizar categorías
GRANT SELECT, INSERT, UPDATE ON db_test.tbc_categories TO 'support';

-- Puede actualizar productos
GRANT SELECT, UPDATE ON db_test.tb_products TO 'support';

-- Puede insertar y actualizar relaciones producto-categoría
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_products_categories TO 'support';

-- Puede consultar los logs para auditoría
GRANT SELECT ON db_test.tb_logs TO 'support';

-- Puede consultar los roles para auditoría (lo usan las vistas de trazabilidad)
GRANT SELECT ON mysql.role_edges TO 'support';

-- Puede ejecutar el borrado lógico de usuarios
GRANT EXECUTE ON PROCEDURE db_test.sp_soft_delete_user TO 'support';

-- ---------------------------------------------------------------------
-- SELLER
-- ---------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test.tbc_categories TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_products_categories TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_users_offer_products TO 'seller';
GRANT SELECT, UPDATE ON db_test.tb_seller_orders TO 'seller';
GRANT SELECT ON db_test.tbd_order_items TO 'seller';

-- ---------------------------------------------------------------------
-- BUYER
-- ---------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON db_test.tb_carts TO 'buyer';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test.tbd_cart_items TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_buyer_orders TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_seller_orders TO 'buyer';
GRANT SELECT, INSERT ON db_test.tbd_order_items TO 'buyer';
GRANT SELECT, INSERT, DELETE ON db_test.tbd_wishlist_products TO 'buyer';
GRANT SELECT, INSERT ON db_test.tb_payments TO 'buyer';
GRANT SELECT, INSERT ON db_test.tb_payment_transactions TO 'buyer';

-- ---------------------------------------------------------------------
-- COMMON (registro + lectura del catálogo)
-- ---------------------------------------------------------------------
GRANT INSERT ON db_test.tb_people  TO 'common';
GRANT INSERT ON db_test.tb_users   TO 'common';

GRANT SELECT ON db_test.tb_products              TO 'common';
GRANT SELECT ON db_test.tbc_categories           TO 'common';
GRANT SELECT ON db_test.tbd_products_categories  TO 'common';
GRANT SELECT ON db_test.tbd_users_offer_products TO 'common';

-- ---------------------------------------------------------------------
-- USER_NOT_REGISTERED: sin privilegios (rol reservado)
-- ---------------------------------------------------------------------


-- 4. ASIGNACION DE ROLES A LOS USUARIOS
GRANT 'superadmin' TO 'luis.cazarez'@'%';
GRANT 'admin'      TO 'marco.ramirez'@'%';
GRANT 'support'    TO 'saul.barrios'@'%';
GRANT 'seller'     TO 'aylin.luna'@'%';
GRANT 'seller'     TO 'jonhy.neri'@'%';
GRANT 'common'     TO 'juan.cruz'@'%';
GRANT 'buyer'      TO 'juan.cruz'@'%';
GRANT 'common'     TO 'carlos.morales'@'%';
GRANT 'buyer'      TO 'carlos.morales'@'%';


-- 5. ACTIVACION AUTOMATICA DE ROLES PARA TODOS LOS USUARIOS
SET DEFAULT ROLE ALL TO
    'luis.cazarez'@'%',
    'marco.ramirez'@'%',
    'aylin.luna'@'%',
    'saul.barrios'@'%',
    'jonhy.neri'@'%',
    'juan.cruz'@'%',
    'carlos.morales'@'%';


-- 6. REFRESCAR PRIVILEGIOS
FLUSH PRIVILEGES;


-- MENSAJE DE CONFIRMACION
SELECT 'Los usuarios y privilegios han sido creados correctamente' AS mensaje;