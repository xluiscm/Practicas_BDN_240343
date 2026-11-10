-- Crear cuentas y permisos para la Practica 04.
-- Ejecutar como DBA en db_test_corregida despues de restaurar el respaldo
-- y ejecutar caso_prueba_1/01_preparar_catalogo.sql.
-- CREATE USER IF NOT EXISTS conserva las contrasenas de cuentas existentes.

USE db_test_corregida;

-- Crear cuentas solo si aun no existen.
CREATE USER IF NOT EXISTS 'luis.cazarez'@'%' IDENTIFIED BY '240343';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'aylin.luna'@'%' IDENTIFIED BY '240853';
CREATE USER IF NOT EXISTS 'saul.barrios'@'%' IDENTIFIED BY '240196';
CREATE USER IF NOT EXISTS 'jonhy.neri'@'%' IDENTIFIED BY '240558';
CREATE USER IF NOT EXISTS 'juan.cruz'@'%' IDENTIFIED BY '240148';
CREATE USER IF NOT EXISTS 'carlos.morales'@'%' IDENTIFIED BY '240221';
CREATE USER IF NOT EXISTS 'app_web'@'%' IDENTIFIED BY 'Web123';
CREATE USER IF NOT EXISTS 'app_movil'@'%' IDENTIFIED BY 'Mobile890';

CREATE ROLE IF NOT EXISTS
    'superadmin', 'admin', 'seller', 'buyer',
    'common_user', 'user_not_registered', 'support';

-- SUPERADMIN y ADMIN
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON db_test_corregida.* TO 'admin';

-- SUPPORT
GRANT SELECT ON db_test_corregida.* TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tb_people TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tbc_categories TO 'support';
GRANT SELECT, UPDATE ON db_test_corregida.tb_products TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tbd_products_categories TO 'support';
GRANT SELECT ON mysql.role_edges TO 'support';
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_soft_delete_user TO 'support';

-- SELLER
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tb_products TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tbc_categories TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tbd_products_categories TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tbd_users_offer_products TO 'seller';
GRANT SELECT, UPDATE ON db_test_corregida.tb_seller_orders TO 'seller';
GRANT SELECT ON db_test_corregida.tbd_order_items TO 'seller';

-- COMMON_USER: compras y lectura del catalogo
GRANT SELECT ON db_test_corregida.tb_users TO 'common_user';
GRANT SELECT ON db_test_corregida.tb_products TO 'common_user';
GRANT SELECT ON db_test_corregida.tbd_users_offer_products TO 'common_user';
GRANT SELECT ON db_test_corregida.tbc_payment_methods_types TO 'common_user';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tb_user_addresses TO 'common_user';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tbd_address_components TO 'common_user';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tbd_user_payment_methods TO 'common_user';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tb_carts TO 'common_user';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test_corregida.tbd_cart_items TO 'common_user';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tb_buyer_orders TO 'common_user';
GRANT SELECT, INSERT, UPDATE ON db_test_corregida.tb_seller_orders TO 'common_user';
GRANT SELECT, INSERT ON db_test_corregida.tbd_order_items TO 'common_user';
GRANT SELECT, INSERT ON db_test_corregida.tb_payments TO 'common_user';
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_authorize_payment TO 'common_user';

-- USER_NOT_REGISTERED: alta mediante el procedimiento de registro
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_register_new_user
    TO 'user_not_registered';

-- BUYER: consulta y ejecucion de rutinas de atencion/entrega
GRANT SELECT ON db_test_corregida.tb_buyer_orders TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_payments TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_payment_transactions TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_seller_orders TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_shipments TO 'buyer';
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_pr04_attend_order TO 'buyer';
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_pr04_deliver_order TO 'buyer';

-- Asignar roles a las cuentas de la practica y a las aplicaciones.
GRANT 'superadmin' TO 'luis.cazarez'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'saul.barrios'@'%';
GRANT 'seller' TO 'aylin.luna'@'%';
GRANT 'seller' TO 'jonhy.neri'@'%';
GRANT 'common_user', 'buyer' TO 'juan.cruz'@'%';
GRANT 'common_user', 'buyer' TO 'carlos.morales'@'%';
GRANT 'user_not_registered', 'common_user', 'buyer' TO 'app_web'@'%';
GRANT 'user_not_registered', 'common_user', 'buyer' TO 'app_movil'@'%';

SET DEFAULT ROLE ALL TO
    'luis.cazarez'@'%', 'marco.ramirez'@'%', 'aylin.luna'@'%',
    'saul.barrios'@'%', 'jonhy.neri'@'%', 'juan.cruz'@'%',
    'carlos.morales'@'%', 'app_web'@'%', 'app_movil'@'%';

FLUSH PRIVILEGES;
SELECT 'Cuentas, roles y permisos de Practica 04 listos' AS resultado;
