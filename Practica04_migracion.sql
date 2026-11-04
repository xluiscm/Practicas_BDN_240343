-- Migracion aditiva para el flujo de compra de Practica 04.
-- Ejecutar UNA sola vez, despues de restaurar 03112026_final.sql en db_test.
-- No carga usuarios/productos ni almacena numeros completos de tarjeta.
-- La autorizacion bancaria es simulada cambiando tb_payments.payment_status.

USE `db_test`;

-- Roles de la aplicacion. Son distintos de los roles/permisos de MySQL
-- asignados a las conexiones AppWeb y AppMobile.
CREATE TABLE `tbc_app_roles` (
  `role_code` varchar(40) NOT NULL,
  `description` varchar(150) NOT NULL,
  PRIMARY KEY (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `tbd_users_app_roles` (
  `user_ID` int unsigned NOT NULL,
  `role_code` varchar(40) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `assigned_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_ID`, `role_code`),
  KEY `idx_app_role_active` (`role_code`, `is_active`),
  CONSTRAINT `fk_user_app_role_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `fk_user_app_role_role` FOREIGN KEY (`role_code`) REFERENCES `tbc_app_roles` (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Relacion administrada por DBA entre cada cuenta MySQL personal y su usuario
-- de la aplicacion. Los procedimientos usan este mapeo, no aceptan user_ID.
CREATE TABLE `tbd_db_account_users` (
  `mysql_account` varchar(32) NOT NULL,
  `user_ID` int unsigned NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`mysql_account`),
  UNIQUE KEY `uk_db_account_user` (`user_ID`),
  CONSTRAINT `fk_db_account_app_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `tbc_app_roles` (`role_code`, `description`) VALUES
  ('user_not_registered', 'Usuario con cuenta sin compras autorizadas'),
  ('buyer', 'Usuario que ya completo un pago autorizado');

-- La orden conserva la referencia al carrito y una copia de los datos de
-- domicilio usados al comprar, aunque el usuario edite su libreta después.
ALTER TABLE `tbb_orders`
  ADD COLUMN `cart_ID` int unsigned NULL,
  ADD COLUMN `shipping_address_ID` bigint unsigned NULL,
  ADD KEY `idx_orders_cart` (`cart_ID`),
  ADD KEY `idx_orders_shipping_address` (`shipping_address_ID`),
  ADD CONSTRAINT `fk_orders_cart` FOREIGN KEY (`cart_ID`) REFERENCES `tb_carts` (`ID`),
  ADD CONSTRAINT `fk_orders_shipping_address` FOREIGN KEY (`shipping_address_ID`) REFERENCES `tb_user_addresses` (`ID`);

-- Vincula el pago con el metodo que el usuario guardo en su tabla dependiente.
-- La columna fue agregada como INT en el respaldo; se ajusta al BIGINT de su PK.
ALTER TABLE `tb_payments`
  MODIFY COLUMN `user_payment_method_ID` bigint unsigned DEFAULT NULL,
  ADD KEY `idx_payment_user_method` (`user_payment_method_ID`),
  ADD CONSTRAINT `fk_payment_user_method` FOREIGN KEY (`user_payment_method_ID`) REFERENCES `tbd_user_payment_methods` (`ID`);

-- Guarda una copia del domicilio para que la orden sea trazable historicamente.
CREATE TABLE `tb_order_shipping_addresses` (
  `order_ID` int unsigned NOT NULL,
  `user_address_ID` bigint unsigned NOT NULL,
  `recipient_name` varchar(150) DEFAULT NULL,
  `recipient_phone` varchar(25) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `delivery_instructions` varchar(500) DEFAULT NULL,
  `snapshot_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_ID`),
  KEY `idx_order_shipping_source` (`user_address_ID`),
  CONSTRAINT `fk_order_shipping_order` FOREIGN KEY (`order_ID`) REFERENCES `tbb_orders` (`ID`),
  CONSTRAINT `fk_order_shipping_source` FOREIGN KEY (`user_address_ID`) REFERENCES `tb_user_addresses` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DELIMITER $$

-- Nuevas cuentas empiezan con rol de usuario sin compras autorizadas.
CREATE TRIGGER `trg_pr04_user_initial_role`
AFTER INSERT ON `tb_users` FOR EACH ROW
BEGIN
  INSERT INTO `tbd_users_app_roles` (`user_ID`, `role_code`, `is_active`)
  VALUES (NEW.ID, 'user_not_registered', 1);
END$$

-- Un pago autorizado o cobrado activa buyer. Los pagos fallidos no lo hacen.
CREATE TRIGGER `trg_pr04_payment_role_and_order`
AFTER UPDATE ON `tb_payments` FOR EACH ROW
BEGIN
  IF OLD.payment_status <> NEW.payment_status
     AND NEW.payment_status IN ('Authorized', 'Paid') THEN
    INSERT INTO `tbd_users_app_roles` (`user_ID`, `role_code`, `is_active`)
    SELECT o.User_ID, 'buyer', 1
    FROM `tbb_orders` o
    WHERE o.ID = NEW.order_ID
    ON DUPLICATE KEY UPDATE `is_active` = 1, `last_update` = CURRENT_TIMESTAMP;

    UPDATE `tbd_users_app_roles` r
    JOIN `tbb_orders` o ON o.User_ID = r.user_ID
    SET r.is_active = 0, r.last_update = CURRENT_TIMESTAMP
    WHERE o.ID = NEW.order_ID AND r.role_code = 'user_not_registered';

    UPDATE `tbb_orders`
    SET `status_string` = 'Attended', `last_update` = CURRENT_TIMESTAMP
    WHERE `ID` = NEW.order_ID AND `status_string` NOT IN ('Canceled', 'Devolved');

    INSERT INTO `tb_payment_transactions`
      (`payment_ID`, `event_type`, `amount`, `event_reference`, `remarks`)
    VALUES
      (NEW.ID,
       IF(NEW.payment_status = 'Authorized', 'Authorized', 'Captured'),
       NEW.amount,
       COALESCE(NEW.transaction_reference, NEW.provider_reference),
       CONCAT('Evento generado por cambio de estado a ', NEW.payment_status));
  ELSEIF OLD.payment_status <> NEW.payment_status
     AND NEW.payment_status = 'Failed' THEN
    INSERT INTO `tb_payment_transactions`
      (`payment_ID`, `event_type`, `amount`, `event_reference`, `remarks`)
    VALUES
      (NEW.ID, 'Failed', NEW.amount,
       COALESCE(NEW.transaction_reference, NEW.provider_reference),
       COALESCE(NEW.failure_reason, 'Pago rechazado en simulacion'));
  END IF;
END$$

-- Al marcar entregado el envio, actualiza las ordenes de vendedor y la orden
-- principal cuando todos sus envios esten entregados.
CREATE TRIGGER `trg_pr04_shipment_delivery`
AFTER UPDATE ON `tb_shipments` FOR EACH ROW
BEGIN
  DECLARE v_order_ID int unsigned;
  IF OLD.shipment_status <> NEW.shipment_status
     AND NEW.shipment_status = 'Delivered' THEN
    SELECT so.order_ID INTO v_order_ID
    FROM `tb_seller_orders` so
    WHERE so.ID = NEW.seller_order_ID;

    UPDATE `tb_seller_orders`
    SET `fulfillment_status` = 'Delivered', `last_update` = CURRENT_TIMESTAMP
    WHERE `ID` = NEW.seller_order_ID;

    IF NOT EXISTS (
      SELECT 1 FROM `tb_seller_orders` so
      WHERE so.order_ID = v_order_ID AND so.fulfillment_status <> 'Delivered'
    ) THEN
      UPDATE `tbb_orders`
      SET `status_string` = 'Delivered', `last_update` = CURRENT_TIMESTAMP
      WHERE `ID` = v_order_ID AND `status_string` NOT IN ('Canceled', 'Devolved');
    END IF;
  END IF;
END$$

DELIMITER ;

-- Rutinas de la compra. Los identificadores de usuario se resuelven desde la
-- cuenta de conexion mediante fn_pr04_current_user_id().
DELIMITER $$

CREATE FUNCTION `fn_pr04_current_user_id`() RETURNS int unsigned
NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
  DECLARE v_user_ID int unsigned DEFAULT NULL;
  SELECT user_ID INTO v_user_ID
  FROM `tbd_db_account_users`
  WHERE mysql_account = SUBSTRING_INDEX(USER(), '@', 1)
  LIMIT 1;
  IF v_user_ID IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta MySQL no esta vinculada a un usuario de la aplicacion';
  END IF;
  RETURN v_user_ID;
END$$

CREATE PROCEDURE `sp_pr04_create_cart`()
BEGIN
  DECLARE v_user_ID int unsigned;
  DECLARE v_cart_ID int unsigned;
  SET v_user_ID = `fn_pr04_current_user_id`();
  SELECT ID INTO v_cart_ID FROM `tb_carts` WHERE user_ID = v_user_ID LIMIT 1;
  IF v_cart_ID IS NULL THEN
    INSERT INTO `tb_carts` (`user_ID`, `status`) VALUES (v_user_ID, b'1');
    SET v_cart_ID = LAST_INSERT_ID();
  ELSE
    UPDATE `tb_carts` SET `status` = b'1', `last_update` = CURRENT_TIMESTAMP WHERE ID = v_cart_ID;
  END IF;
  SELECT v_cart_ID AS cart_ID;
END$$

CREATE PROCEDURE `sp_pr04_add_cart_item`(
  IN p_cart_ID int unsigned,
  IN p_provider_ID int unsigned,
  IN p_product_ID int unsigned,
  IN p_quantity int unsigned
)
BEGIN
  DECLARE v_user_ID int unsigned;
  DECLARE v_owner_ID int unsigned;
  DECLARE v_stock int unsigned;
  DECLARE v_existing_quantity int unsigned DEFAULT 0;
  SET v_user_ID = `fn_pr04_current_user_id`();
  IF p_quantity = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor que cero';
  END IF;
  SELECT user_ID INTO v_owner_ID FROM `tb_carts`
  WHERE ID = p_cart_ID AND status = b'1';
  IF v_owner_ID IS NULL OR v_owner_ID <> v_user_ID THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El carrito no pertenece a la cuenta conectada o esta inactivo';
  END IF;
  SELECT p.current_stock INTO v_stock
  FROM `tb_products` p
  JOIN `tbd_products_users_providers` pr
    ON pr.product_ID = p.ID AND pr.user_ID = p_provider_ID AND pr.status = b'1'
  WHERE p.ID = p_product_ID AND p.status = b'1' AND p.current_price > 0;
  IF v_stock IS NULL OR v_stock < p_quantity THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no disponible o existencias insuficientes';
  END IF;
  SELECT COALESCE(MAX(quantity), 0) INTO v_existing_quantity
  FROM `tbd_carts_items`
  WHERE cart_ID = p_cart_ID AND provider_ID = p_provider_ID AND product_ID = p_product_ID;
  IF v_existing_quantity + p_quantity > v_stock THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad acumulada supera las existencias';
  END IF;
  INSERT INTO `tbd_carts_items` (`cart_ID`, `provider_ID`, `product_ID`, `quantity`)
  VALUES (p_cart_ID, p_provider_ID, p_product_ID, p_quantity)
  ON DUPLICATE KEY UPDATE `quantity` = `quantity` + p_quantity;
END$$

CREATE PROCEDURE `sp_pr04_register_address`(
  IN p_address_label varchar(100), IN p_recipient_name varchar(150),
  IN p_recipient_phone varchar(25), IN p_street varchar(255),
  IN p_city varchar(100), IN p_state varchar(100),
  IN p_postal_code varchar(20), IN p_country varchar(100),
  IN p_delivery_instructions varchar(500)
)
BEGIN
  INSERT INTO `tb_user_addresses`
    (`user_ID`, `address_label`, `recipient_name`, `recipient_phone`,
     `street`, `city`, `state`, `postal_code`, `country`, `delivery_instructions`)
  VALUES
    (`fn_pr04_current_user_id`(), p_address_label, p_recipient_name,
     p_recipient_phone, p_street, p_city, p_state, p_postal_code, p_country,
     p_delivery_instructions);
  SELECT LAST_INSERT_ID() AS address_ID;
END$$

CREATE PROCEDURE `sp_pr04_register_card_method`(
  IN p_payment_type_ID int unsigned,
  IN p_provider varchar(60), IN p_simulated_reference varchar(255),
  IN p_label varchar(100), IN p_last_four char(4)
)
BEGIN
  IF p_simulated_reference IS NULL OR p_simulated_reference = ''
     OR p_simulated_reference REGEXP '^[0-9]{16}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Use una referencia simulada, no el numero completo de tarjeta';
  END IF;
  IF p_last_four IS NOT NULL AND p_last_four NOT REGEXP '^[0-9]{4}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'last_four debe contener exactamente cuatro digitos';
  END IF;
  INSERT INTO `tbd_user_payment_methods`
    (`user_ID`, `payment_method_type_ID`, `provider`, `provider_method_ref`, `label`, `last_four`)
  VALUES
    (`fn_pr04_current_user_id`(), p_payment_type_ID, p_provider,
     p_simulated_reference, p_label, p_last_four);
  SELECT LAST_INSERT_ID() AS user_payment_method_ID;
END$$

-- Convierte carrito en orden y copia el domicilio seleccionado.
CREATE PROCEDURE `sp_pr04_create_order_from_cart`(
  IN p_cart_ID int unsigned,
  IN p_address_ID bigint unsigned
)
BEGIN
  DECLARE v_user_ID int unsigned;
  DECLARE v_order_ID int unsigned;
  DECLARE v_item_count int DEFAULT 0;
  DECLARE v_invalid_count int DEFAULT 0;
  DECLARE v_total_products int DEFAULT 0;
  DECLARE v_total_cost decimal(12,2) DEFAULT 0.00;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SET v_user_ID = `fn_pr04_current_user_id`();

  IF NOT EXISTS (
    SELECT 1 FROM `tb_carts`
    WHERE ID = p_cart_ID AND user_ID = v_user_ID AND status = b'1'
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carrito inexistente, inactivo o no pertenece al usuario';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM `tb_user_addresses`
    WHERE ID = p_address_ID AND user_ID = v_user_ID AND status = b'1'
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Domicilio inexistente, inactivo o no pertenece al usuario';
  END IF;

  SELECT COUNT(*) INTO v_item_count
  FROM `tbd_carts_items` WHERE cart_ID = p_cart_ID;
  IF v_item_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede ordenar un carrito vacio';
  END IF;

  SELECT COUNT(*) INTO v_invalid_count
  FROM `tbd_carts_items` ci
  JOIN `tb_products` p ON p.ID = ci.product_ID
  JOIN `tbd_products_users_providers` pr
    ON pr.user_ID = ci.provider_ID AND pr.product_ID = ci.product_ID
  WHERE ci.cart_ID = p_cart_ID
    AND (p.status <> b'1' OR p.current_price <= 0
         OR p.current_stock < ci.quantity OR pr.status <> b'1');
  IF v_invalid_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay productos inactivos o sin stock/precio suficiente';
  END IF;

  SELECT SUM(ci.quantity), SUM(ci.quantity * p.current_price)
  INTO v_total_products, v_total_cost
  FROM `tbd_carts_items` ci
  JOIN `tb_products` p ON p.ID = ci.product_ID
  WHERE ci.cart_ID = p_cart_ID;

  INSERT INTO `tbb_orders`
    (`key`, `User_ID`, `total_products`, `total_cost`, `status_string`, `creation_date`, `cart_ID`)
  VALUES
    (LEFT(REPLACE(UUID(), '-', ''), 40), v_user_ID, v_total_products,
     v_total_cost, 'Registered', CURRENT_TIMESTAMP, p_cart_ID);
  SET v_order_ID = LAST_INSERT_ID();

  INSERT INTO `tb_order_shipping_addresses`
    (`order_ID`, `user_address_ID`, `recipient_name`, `recipient_phone`,
     `street`, `city`, `state`, `postal_code`, `country`, `delivery_instructions`)
  SELECT v_order_ID, a.ID, a.recipient_name, a.recipient_phone,
         a.street, a.city, a.state, a.postal_code, a.country, a.delivery_instructions
  FROM `tb_user_addresses` a WHERE a.ID = p_address_ID;

  INSERT INTO `tb_seller_orders`
    (`order_ID`, `seller_ID`, `subtotal`, `shipping_cost`, `fulfillment_status`)
  SELECT v_order_ID, ci.provider_ID, SUM(ci.quantity * p.current_price), 0.00, 'Pending'
  FROM `tbd_carts_items` ci
  JOIN `tb_products` p ON p.ID = ci.product_ID
  WHERE ci.cart_ID = p_cart_ID
  GROUP BY ci.provider_ID;

  INSERT INTO `tbd_order_items`
    (`seller_order_ID`, `product_ID`, `provider_ID`, `product_name`, `quantity`, `unit_price`)
  SELECT so.ID, ci.product_ID, ci.provider_ID, p.name, ci.quantity, p.current_price
  FROM `tbd_carts_items` ci
  JOIN `tb_products` p ON p.ID = ci.product_ID
  JOIN `tb_seller_orders` so
    ON so.order_ID = v_order_ID AND so.seller_ID = ci.provider_ID
  WHERE ci.cart_ID = p_cart_ID;

  UPDATE `tb_products` p
  JOIN `tbd_carts_items` ci ON ci.product_ID = p.ID
  SET p.current_stock = p.current_stock - ci.quantity
  WHERE ci.cart_ID = p_cart_ID;

  UPDATE `tb_carts` SET status = b'0', last_update = CURRENT_TIMESTAMP
  WHERE ID = p_cart_ID;
  DELETE FROM `tbd_carts_items` WHERE cart_ID = p_cart_ID;

  COMMIT;
  SELECT v_order_ID AS order_ID;
END$$

-- Simula la respuesta bancaria. El trigger registra transaccion y activa el
-- rol de aplicacion buyer solo cuando el estado pasa a Authorized.
CREATE PROCEDURE `sp_pr04_process_payment`(
  IN p_order_ID int unsigned,
  IN p_user_payment_method_ID bigint unsigned,
  IN p_authorized tinyint
)
BEGIN
  DECLARE v_user_ID int unsigned;
  DECLARE v_order_user_ID int unsigned;
  DECLARE v_amount decimal(12,2);
  DECLARE v_payment_ID int unsigned;
  DECLARE v_reference varchar(100);
  SET v_user_ID = `fn_pr04_current_user_id`();

  SELECT User_ID, total_cost INTO v_order_user_ID, v_amount
  FROM `tbb_orders` WHERE ID = p_order_ID AND status_string = 'Registered';
  IF v_order_user_ID IS NULL OR v_order_user_ID <> v_user_ID THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden no existe, no esta pendiente o no pertenece a la cuenta conectada';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM `tbd_user_payment_methods`
    WHERE ID = p_user_payment_method_ID AND user_ID = v_user_ID AND status = b'1'
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Metodo de pago inexistente, inactivo o de otra cuenta';
  END IF;
  IF p_authorized NOT IN (0, 1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El resultado simulado debe ser 0 o 1';
  END IF;
  SET v_reference = LEFT(REPLACE(UUID(), '-', ''), 100);
  INSERT INTO `tb_payments`
    (`order_ID`, `amount`, `currency`, `payment_method`, `provider`,
     `provider_reference`, `payment_status`, `user_payment_method_ID`, `transaction_reference`, `failure_reason`)
  VALUES
    (p_order_ID, v_amount, 'MXN', 'Card', 'Practica04-Simulador',
     v_reference, 'Pending', p_user_payment_method_ID, v_reference,
     IF(p_authorized = 1, NULL, 'Rechazo simulado'));
  SET v_payment_ID = LAST_INSERT_ID();
  UPDATE `tb_payments`
  SET `payment_status` = IF(p_authorized = 1, 'Authorized', 'Failed'),
      `paid_date` = IF(p_authorized = 1, CURRENT_TIMESTAMP, NULL)
  WHERE ID = v_payment_ID;
  SELECT v_payment_ID AS payment_ID, v_reference AS transaction_reference,
         IF(p_authorized = 1, 'Authorized', 'Failed') AS payment_status;
END$$

DELIMITER ;

-- Consultas de trabajo para el caso de prueba.
CREATE OR REPLACE VIEW `vw_pr04_catalogo_disponible` AS
SELECT p.ID AS product_ID, p.SKU, p.name, p.description, p.current_price,
       p.current_stock, c.ID AS category_ID, c.name AS category_name
FROM `tb_products` p
LEFT JOIN `tbd_products_categories` pc ON pc.product_ID = p.ID
LEFT JOIN `tbc_categories` c ON c.ID = pc.category_ID AND c.status = b'1'
WHERE p.status = b'1' AND p.current_stock > 0 AND p.current_price > 0;

CREATE OR REPLACE VIEW `vw_pr04_order_status` AS
SELECT o.ID AS order_ID, o.`key` AS order_key, o.User_ID AS buyer_user_ID,
       o.cart_ID, o.total_products, o.total_cost, o.status_string,
       a.user_address_ID, a.recipient_name, a.recipient_phone,
       a.street, a.city, a.state, a.postal_code, a.country,
       p.ID AS payment_ID, p.payment_method, p.payment_status, p.amount,
       so.ID AS seller_order_ID, so.seller_ID, so.fulfillment_status,
       s.ID AS shipment_ID, s.shipment_status, s.tracking_number,
       s.shipped_at, s.estimated_delivery, s.delivered_at
FROM `tbb_orders` o
JOIN `tbd_db_account_users` m
  ON m.user_ID = o.User_ID
 AND m.mysql_account = SUBSTRING_INDEX(USER(), '@', 1)
LEFT JOIN `tb_order_shipping_addresses` a ON a.order_ID = o.ID
LEFT JOIN `tb_payments` p ON p.order_ID = o.ID
LEFT JOIN `tb_seller_orders` so ON so.order_ID = o.ID
LEFT JOIN `tb_shipments` s ON s.seller_order_ID = so.ID;

CREATE OR REPLACE VIEW `vw_pr04_user_roles` AS
SELECT ur.user_ID, u.email, u.nick, ur.role_code, ur.is_active, ur.assigned_at
FROM `tbd_users_app_roles` ur
JOIN `tb_users` u ON u.ID = ur.user_ID;

CREATE OR REPLACE VIEW `vw_pr04_my_cart` AS
SELECT c.ID AS cart_ID, ci.provider_ID, ci.product_ID, p.SKU, p.name,
       ci.quantity, p.current_price, (ci.quantity * p.current_price) AS line_total
FROM `tb_carts` c
JOIN `tbd_db_account_users` m
  ON m.user_ID = c.user_ID AND m.mysql_account = SUBSTRING_INDEX(USER(), '@', 1)
JOIN `tbd_carts_items` ci ON ci.cart_ID = c.ID
JOIN `tb_products` p ON p.ID = ci.product_ID;

CREATE OR REPLACE VIEW `vw_pr04_my_addresses` AS
SELECT a.ID AS address_ID, a.address_label, a.recipient_name, a.recipient_phone,
       a.street, a.city, a.state, a.postal_code, a.country, a.delivery_instructions,
       a.is_default
FROM `tb_user_addresses` a
JOIN `tbd_db_account_users` m
  ON m.user_ID = a.user_ID AND m.mysql_account = SUBSTRING_INDEX(USER(), '@', 1)
WHERE a.status = b'1';

CREATE OR REPLACE VIEW `vw_pr04_my_payment_methods` AS
SELECT pm.ID AS user_payment_method_ID, pm.payment_method_type_ID,
       pm.provider, pm.label, pm.last_four, pm.is_default
FROM `tbd_user_payment_methods` pm
JOIN `tbd_db_account_users` m
  ON m.user_ID = pm.user_ID AND m.mysql_account = SUBSTRING_INDEX(USER(), '@', 1)
WHERE pm.status = b'1';

