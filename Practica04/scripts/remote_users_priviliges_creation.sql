-- =====================================================================
-- SCRIPT DE CREACION DE USUARIOS Y ASIGNACION DE ROLES / PRIVILEGIOS
-- Base de Datos: db_test
-- =====================================================================

-- 0. LIMPIEZA PREVIA (evita errores si ya existen usuarios o roles)
DROP USER IF EXISTS
    'luis.cazarez'@'%',
    'marco.ramirez'@'%',
    'aylin.luna'@'%',
    'saul.barrios'@'%',
    'jonhy.neri'@'%',
    'juan.cruz'@'%',
    'carlos.morales'@'%',
    'app_web'@'%',
    'app_movil'@'%';

DROP ROLE IF EXISTS
    'superadmin',
    'admin',
    'seller',
    'buyer',
    'common',
    'common_user',
    'user_not_registered',
    'support';


-- 1. CREACION DE USUARIOS REMOTOS
CREATE USER 'luis.cazarez'@'%'   IDENTIFIED BY '240343';    -- Super admin
CREATE USER 'marco.ramirez'@'%'  IDENTIFIED BY 'qwerty123'; -- Admin / Profe
CREATE USER 'aylin.luna'@'%'     IDENTIFIED BY '240853';    -- Vendedor 1
CREATE USER 'saul.barrios'@'%'   IDENTIFIED BY '240196';    -- Support
CREATE USER 'jonhy.neri'@'%'     IDENTIFIED BY '240558';    -- Vendedor 2
CREATE USER 'juan.cruz'@'%'      IDENTIFIED BY '240148';    -- Usuario / Comprador
CREATE USER 'carlos.morales'@'%' IDENTIFIED BY '240221';    -- Usuario / Comprador
CREATE USER 'app_web'@'%'        IDENTIFIED BY 'Web123';    -- Aplicación web
CREATE USER 'app_movil'@'%'      IDENTIFIED BY 'Mobile890'; -- Aplicación móvil


-- 2. CREACION DE ROLES PARA ECOMMERCE
CREATE ROLE 'superadmin';
CREATE ROLE 'admin';
CREATE ROLE 'seller';
CREATE ROLE 'buyer';
CREATE ROLE 'common_user';
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
GRANT SELECT ON db_test.* TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_people TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbc_categories TO 'support';
GRANT SELECT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tbd_products_categories TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';
GRANT SELECT ON mysql.role_edges TO 'support';
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
-- COMMON_USER (Registro de datos de usuario + lectura del catálogo)
-- ---------------------------------------------------------------------
GRANT INSERT, SELECT ON db_test.tb_people TO 'common_user';
GRANT INSERT, SELECT ON db_test.tb_users  TO 'common_user';

GRANT SELECT ON db_test.tb_products              TO 'common_user';
GRANT SELECT ON db_test.tbc_categories           TO 'common_user';
GRANT SELECT ON db_test.tbd_products_categories  TO 'common_user';
GRANT SELECT ON db_test.tbd_users_offer_products TO 'common_user';

-- ---------------------------------------------------------------------
-- USER_NOT_REGISTERED (Creación inicial del perfil de usuario no registrado)
-- ---------------------------------------------------------------------
GRANT INSERT, SELECT ON db_test.tb_people TO 'user_not_registered';
GRANT INSERT, SELECT ON db_test.tb_users  TO 'user_not_registered';


-- 4. ASIGNACION DE ROLES A LOS USUARIOS
GRANT 'superadmin'          TO 'luis.cazarez'@'%';
GRANT 'admin'               TO 'marco.ramirez'@'%';
GRANT 'support'             TO 'saul.barrios'@'%';
GRANT 'seller'              TO 'aylin.luna'@'%';
GRANT 'seller'              TO 'jonhy.neri'@'%';
GRANT 'common_user'         TO 'juan.cruz'@'%';
GRANT 'buyer'               TO 'juan.cruz'@'%';
GRANT 'common_user'         TO 'carlos.morales'@'%';
GRANT 'buyer'               TO 'carlos.morales'@'%';
GRANT 'user_not_registered' TO 'app_web'@'%';
GRANT 'user_not_registered' TO 'app_movil'@'%';


-- 5. ACTIVACION AUTOMATICA DE ROLES PARA TODOS LOS USUARIOS
SET DEFAULT ROLE ALL TO
    'luis.cazarez'@'%',
    'marco.ramirez'@'%',
    'aylin.luna'@'%',
    'saul.barrios'@'%',
    'jonhy.neri'@'%',
    'juan.cruz'@'%',
    'carlos.morales'@'%',
    'app_web'@'%',
    'app_movil'@'%';


-- 6. REFRESCAR PRIVILEGIOS
FLUSH PRIVILEGES;

-- MENSAJE DE CONFIRMACION
SELECT 'Los usuarios, roles y privilegios actualizados se aplicaron correctamente' AS mensaje;