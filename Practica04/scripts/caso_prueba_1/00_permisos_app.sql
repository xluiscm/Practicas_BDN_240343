-- Ejecutar como DBA despues de restaurar la base y crear las cuentas app_web
-- y app_movil (si aun no existen). No crea ni cambia contrasenas de cuentas.
USE db_test_corregida;

CREATE ROLE IF NOT EXISTS 'user_not_registered', 'common_user', 'buyer';

-- Antes del registro, la aplicacion solo puede invocar el procedimiento seguro.
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_register_new_user
    TO 'user_not_registered';

-- Operaciones permitidas durante el flujo de compra.
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

-- El rol buyer permite atender y entregar ordenes; las rutinas actualizan
-- inventario y estados con privilegios de su definidor.
GRANT SELECT ON db_test_corregida.tb_buyer_orders TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_payments TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_payment_transactions TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_seller_orders TO 'buyer';
GRANT SELECT ON db_test_corregida.tb_shipments TO 'buyer';
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_pr04_attend_order TO 'buyer';
GRANT EXECUTE ON PROCEDURE db_test_corregida.sp_pr04_deliver_order TO 'buyer';

-- app_web/app_movil cambian entre estos roles desde el servidor de aplicacion.
GRANT 'user_not_registered', 'common_user', 'buyer' TO 'app_web'@'%';
GRANT 'user_not_registered', 'common_user', 'buyer' TO 'app_movil'@'%';

SELECT 'Roles asignados a app_web y app_movil para db_test_corregida' AS resultado;
