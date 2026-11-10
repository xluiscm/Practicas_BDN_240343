-- Ejecutar como DBA sobre una RESTAURACION de db_test_corregida.
-- Agrega un tipo de tarjeta ficticio y hasta cinco ofertas de productos con stock.
USE db_test_corregida;

-- Vincular el pago con el metodo guardado y el envio con el domicilio.
-- Ejecutar una sola vez por restauracion limpia.
ALTER TABLE tb_payments
    ADD COLUMN user_payment_method_ID BIGINT UNSIGNED NULL AFTER order_ID,
    ADD KEY idx_payments_user_method (user_payment_method_ID),
    ADD CONSTRAINT fk_payments_user_method
        FOREIGN KEY (user_payment_method_ID) REFERENCES tbd_user_payment_methods (ID);

ALTER TABLE tb_shipments
    ADD COLUMN delivery_address_ID BIGINT UNSIGNED NULL AFTER seller_order_ID,
    ADD KEY idx_shipments_delivery_address (delivery_address_ID),
    ADD CONSTRAINT fk_shipments_delivery_address
        FOREIGN KEY (delivery_address_ID) REFERENCES tb_user_addresses (ID);

INSERT INTO tbc_payment_methods_types (code, description, status)
VALUES ('DEBIT_CARD_SIM', 'Tarjeta de debito simulada para Practica 04', b'1')
ON DUPLICATE KEY UPDATE description = VALUES(description), status = b'1';

-- Las ofertas son necesarias porque el carrito y los pedidos apuntan a ellas.
-- user_ID NULL identifica el catalogo de productos preparado para esta demo.
INSERT INTO tbd_users_offer_products
    (user_ID, product_ID, available_stock, status, available_date)
SELECT NULL, p.ID, p.current_stock, b'1', NOW()
FROM tb_products p
WHERE p.status = b'1'
  AND p.current_stock >= 5
  AND p.current_price > 0
  AND NOT EXISTS (
      SELECT 1 FROM tbd_users_offer_products o
      WHERE o.product_ID = p.ID AND o.user_ID IS NULL AND o.status = b'1'
  )
ORDER BY p.ID
LIMIT 5;

-- Rutina de atencion con validacion y descuento atomico en ambos inventarios.
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_pr04_attend_order$$
CREATE PROCEDURE sp_pr04_attend_order(IN p_order_id INT UNSIGNED)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_status VARCHAR(30);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT status_string INTO v_status
    FROM tb_buyer_orders WHERE ID = p_order_id FOR UPDATE;
    IF v_status IS NULL OR v_status <> 'Payed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden no esta pagada';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tb_seller_orders WHERE order_ID = p_order_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden no tiene pedidos de vendedor';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tbd_order_items oi
        JOIN tb_seller_orders so ON so.ID = oi.seller_order_ID
        JOIN tbd_users_offer_products o ON o.product_offer_ID = oi.product_offer_ID
        JOIN tb_products p ON p.ID = o.product_ID
        WHERE so.order_ID = p_order_id
        GROUP BY o.product_offer_ID, o.available_stock, p.current_stock
        HAVING o.available_stock < SUM(oi.quantity)
            OR p.current_stock < SUM(oi.quantity)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventario insuficiente';
    END IF;

    UPDATE tbd_users_offer_products o
    JOIN (
        SELECT oi.product_offer_ID, SUM(oi.quantity) AS quantity_sold
        FROM tbd_order_items oi
        JOIN tb_seller_orders so ON so.ID = oi.seller_order_ID
        WHERE so.order_ID = p_order_id
        GROUP BY oi.product_offer_ID
    ) sold ON sold.product_offer_ID = o.product_offer_ID
    SET o.available_stock = o.available_stock - sold.quantity_sold;

    UPDATE tb_products p
    JOIN tbd_users_offer_products o ON o.product_ID = p.ID
    JOIN (
        SELECT oi.product_offer_ID, SUM(oi.quantity) AS quantity_sold
        FROM tbd_order_items oi
        JOIN tb_seller_orders so ON so.ID = oi.seller_order_ID
        WHERE so.order_ID = p_order_id
        GROUP BY oi.product_offer_ID
    ) sold ON sold.product_offer_ID = o.product_offer_ID
    SET p.current_stock = p.current_stock - sold.quantity_sold;

    UPDATE tb_seller_orders SET fulfillment_status = 'Preparing' WHERE order_ID = p_order_id;
    UPDATE tb_buyer_orders SET status_string = 'Attended' WHERE ID = p_order_id;
    COMMIT;
END$$

DROP PROCEDURE IF EXISTS sp_pr04_deliver_order$$
CREATE PROCEDURE sp_pr04_deliver_order(
    IN p_order_id INT UNSIGNED,
    IN p_address_id BIGINT UNSIGNED
)
SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM tb_buyer_orders bo
        JOIN tb_user_addresses a ON a.user_ID = bo.user_ID
        WHERE bo.ID = p_order_id AND a.ID = p_address_id AND a.status = b'1'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El domicilio no pertenece al comprador';
    END IF;
    CALL sp_deliver_order(p_order_id);
    UPDATE tb_shipments s
    JOIN tb_seller_orders so ON so.ID = s.seller_order_ID
    SET s.delivery_address_ID = p_address_id
    WHERE so.order_ID = p_order_id;
END$$
DELIMITER ;

-- Confirmar que quedaron cinco productos de prueba disponibles.
SELECT o.product_offer_ID, p.ID AS product_ID, p.SKU, p.name,
       p.current_price, p.current_stock, o.available_stock
FROM tbd_users_offer_products o
JOIN tb_products p ON p.ID = o.product_ID
WHERE o.user_ID IS NULL AND o.status = b'1'
ORDER BY o.product_offer_ID
LIMIT 5;
