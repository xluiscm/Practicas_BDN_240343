-- Complemento posterior a Practica04_migracion.sql.
-- Ejecutar una sola vez con una cuenta administradora sobre db_test.
-- Flujo de vinculacion:
--   1) Tras sp_register_person, la conexion AppWeb/AppMobile llama
--      sp_pr04_issue_link_token(user_id) y entrega el token al usuario.
--   2) El usuario crea/recibe su cuenta MySQL personal y llama
--      sp_pr04_link_current_account(user_id, token) desde esa conexion.
-- El token es aleatorio, de un solo uso y expira en 15 minutos.

USE `db_test`;

CREATE TABLE `tbd_account_link_tokens` (
  `user_ID` int unsigned NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_ID`),
  CONSTRAINT `fk_account_link_token_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DELIMITER $$

CREATE PROCEDURE `sp_pr04_issue_link_token`(IN p_user_ID int unsigned)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_token char(64);
  IF LOWER(SUBSTRING_INDEX(USER(), '@', 1)) NOT IN ('app_web', 'app_movil') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo la conexion de registro puede emitir tokens de vinculacion';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM `tb_users` WHERE ID = p_user_ID AND status = b'1') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario inexistente o inactivo';
  END IF;
  SET v_token = HEX(RANDOM_BYTES(32));
  INSERT INTO `tbd_account_link_tokens` (`user_ID`, `token_hash`, `expires_at`, `used_at`)
  VALUES (p_user_ID, SHA2(v_token, 256), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 15 MINUTE), NULL)
  ON DUPLICATE KEY UPDATE
    `token_hash` = VALUES(`token_hash`),
    `expires_at` = VALUES(`expires_at`),
    `used_at` = NULL,
    `creation_date` = CURRENT_TIMESTAMP;
  SELECT v_token AS one_time_link_token, 'Token valido durante 15 minutos' AS message;
END$$

CREATE PROCEDURE `sp_pr04_link_current_account`(
  IN p_user_ID int unsigned,
  IN p_one_time_token char(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_token_valid int DEFAULT 0;
  DECLARE v_saved_hash char(64) DEFAULT NULL;
  DECLARE v_mysql_account varchar(32);
  SET v_mysql_account = SUBSTRING_INDEX(USER(), '@', 1);

  IF v_mysql_account IS NULL OR v_mysql_account = ''
     OR v_mysql_account IN ('root', 'app_web', 'app_movil') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La vinculacion requiere una cuenta MySQL personal';
  END IF;

  START TRANSACTION;
  SELECT token_hash INTO v_saved_hash
  FROM `tbd_account_link_tokens`
  WHERE user_ID = p_user_ID
    AND expires_at > CURRENT_TIMESTAMP AND used_at IS NULL
  FOR UPDATE;
  SET v_token_valid = (v_saved_hash IS NOT NULL AND v_saved_hash = SHA2(p_one_time_token, 256));

  IF v_token_valid <> 1 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Token incorrecto, expirado o ya utilizado';
  END IF;

  IF EXISTS (SELECT 1 FROM `tbd_db_account_users` WHERE user_ID = p_user_ID)
     OR EXISTS (SELECT 1 FROM `tbd_db_account_users` WHERE mysql_account = v_mysql_account) THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario o la cuenta MySQL ya estan vinculados';
  END IF;

  INSERT INTO `tbd_db_account_users` (`mysql_account`, `user_ID`)
  VALUES (v_mysql_account, p_user_ID);
  UPDATE `tbd_account_link_tokens`
  SET used_at = CURRENT_TIMESTAMP
  WHERE user_ID = p_user_ID;
  COMMIT;

  SELECT v_mysql_account AS mysql_account, p_user_ID AS user_ID,
         'Cuenta vinculada correctamente' AS message;
END$$

-- El vendedor solo puede generar envios de sus propias ordenes.
CREATE PROCEDURE `sp_pr04_create_shipment`(
  IN p_seller_order_ID int unsigned,
  IN p_carrier varchar(100),
  IN p_tracking_number varchar(150),
  IN p_estimated_delivery datetime
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_user_ID int unsigned;
  DECLARE v_seller_ID int unsigned;
  DECLARE v_status varchar(20);
  SET v_user_ID = `fn_pr04_current_user_id`();

  SELECT seller_ID, fulfillment_status INTO v_seller_ID, v_status
  FROM `tb_seller_orders` WHERE ID = p_seller_order_ID;
  IF v_seller_ID IS NULL OR v_seller_ID <> v_user_ID THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden de vendedor no pertenece a la cuenta conectada';
  END IF;
  IF v_status NOT IN ('Accepted', 'Preparing', 'Sent') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden debe estar aceptada o en preparacion antes del envio';
  END IF;
  IF EXISTS (SELECT 1 FROM `tb_shipments` WHERE seller_order_ID = p_seller_order_ID) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden ya tiene un envio';
  END IF;

  INSERT INTO `tb_shipments`
    (`seller_order_ID`, `carrier`, `tracking_number`, `shipment_status`, `estimated_delivery`)
  VALUES
    (p_seller_order_ID, p_carrier, p_tracking_number, 'LabelCreated', p_estimated_delivery);
  SELECT LAST_INSERT_ID() AS shipment_ID;
END$$

-- Aceptar y preparar la orden del vendedor antes de generar el envio.
CREATE PROCEDURE `sp_pr04_set_seller_order_status`(
  IN p_seller_order_ID int unsigned,
  IN p_new_status varchar(20)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_user_ID int unsigned;
  DECLARE v_seller_ID int unsigned;
  DECLARE v_old_status varchar(20);
  SET v_user_ID = `fn_pr04_current_user_id`();

  SELECT seller_ID, fulfillment_status INTO v_seller_ID, v_old_status
  FROM `tb_seller_orders` WHERE ID = p_seller_order_ID;
  IF v_seller_ID IS NULL OR v_seller_ID <> v_user_ID THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden no pertenece al vendedor conectado';
  END IF;
  IF (v_old_status = 'Pending' AND p_new_status <> 'Accepted')
     OR (v_old_status = 'Accepted' AND p_new_status <> 'Preparing')
     OR v_old_status NOT IN ('Pending', 'Accepted') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de orden de vendedor no valida';
  END IF;
  UPDATE `tb_seller_orders`
  SET fulfillment_status = p_new_status, last_update = CURRENT_TIMESTAMP
  WHERE ID = p_seller_order_ID;
  SELECT p_seller_order_ID AS seller_order_ID, p_new_status AS fulfillment_status;
END$$

CREATE PROCEDURE `sp_pr04_update_shipment`(
  IN p_shipment_ID int unsigned,
  IN p_new_status varchar(20),
  IN p_shipping_notes varchar(500)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_user_ID int unsigned;
  DECLARE v_seller_ID int unsigned;
  DECLARE v_seller_order_ID int unsigned;
  DECLARE v_old_status varchar(20);
  SET v_user_ID = `fn_pr04_current_user_id`();

  SELECT s.seller_order_ID, so.seller_ID, s.shipment_status
  INTO v_seller_order_ID, v_seller_ID, v_old_status
  FROM `tb_shipments` s
  JOIN `tb_seller_orders` so ON so.ID = s.seller_order_ID
  WHERE s.ID = p_shipment_ID;
  IF v_seller_ID IS NULL OR v_seller_ID <> v_user_ID THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El envio no pertenece al vendedor conectado';
  END IF;
  IF p_new_status NOT IN ('Shipped', 'InTransit', 'Delivered', 'Failed', 'Returned') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de envio no permitido';
  END IF;
  IF (v_old_status = 'LabelCreated' AND p_new_status NOT IN ('Shipped', 'Failed'))
     OR (v_old_status = 'Shipped' AND p_new_status NOT IN ('InTransit', 'Delivered', 'Failed', 'Returned'))
     OR (v_old_status = 'InTransit' AND p_new_status NOT IN ('Delivered', 'Failed', 'Returned'))
     OR (v_old_status IN ('Delivered', 'Failed', 'Returned')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de estado de envio no valida';
  END IF;

  UPDATE `tb_shipments`
  SET `shipment_status` = p_new_status,
      `shipped_at` = IF(p_new_status = 'Shipped' AND shipped_at IS NULL, CURRENT_TIMESTAMP, shipped_at),
      `delivered_at` = IF(p_new_status = 'Delivered', CURRENT_TIMESTAMP, delivered_at),
      `shipping_notes` = p_shipping_notes,
      `last_update` = CURRENT_TIMESTAMP
  WHERE ID = p_shipment_ID;

  SELECT p_shipment_ID AS shipment_ID, p_new_status AS shipment_status,
         v_seller_order_ID AS seller_order_ID;
END$$

DELIMITER ;

-- Privilegios del proceso de vinculacion, registro y compra.
GRANT EXECUTE ON PROCEDURE db_test.sp_pr04_issue_link_token TO 'user_not_registered';
GRANT EXECUTE ON PROCEDURE db_test.sp_pr04_link_current_account TO 'user_not_registered';
GRANT EXECUTE ON PROCEDURE db_test.sp_pr04_create_shipment TO 'seller';
GRANT EXECUTE ON PROCEDURE db_test.sp_pr04_set_seller_order_status TO 'seller';
GRANT EXECUTE ON PROCEDURE db_test.sp_pr04_update_shipment TO 'seller';

