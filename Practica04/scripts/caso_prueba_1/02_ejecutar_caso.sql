-- Ejecutar despues de 01_preparar_catalogo.sql en una conexion con permisos
-- de escritura. Es una simulacion: no procesa dinero ni envios reales.
-- Inicia conectado como app_web o app_movil. El servidor de la aplicacion
-- debe activar cada rol; el usuario de tb_users no es una cuenta MySQL.
SET ROLE user_not_registered;
USE db_test_corregida;

SET @email = CONCAT('pr04.', REPLACE(UUID(), '-', ''), '@example.test');
SET @nick = CONCAT('pr04_', LEFT(REPLACE(UUID(), '-', ''), 24));
SET @new_user_id = NULL;
SET @person_id = NULL;
SET @simulated_card = '4242424242424242';

-- Registro del comprador de prueba (el procedimiento aplica MD5 a password).
CALL sp_register_new_user(
    @email, @nick, 'Practica04-Demo-2026!',
    'Sr.', 'Usuario', 'Simulado', '1998-05-12', NULL, 'MX', '5550000000',
    @new_user_id, @person_id
);

-- La aplicacion autentica al nuevo usuario y cambia el rol de esta conexion.
SET ROLE common_user;

-- Crear la direccion y componentes ficticios.
INSERT INTO tb_user_addresses
    (user_ID, address_label, recipient_name, recipient_phone, delivery_instructions, is_default, status)
VALUES
    (@new_user_id, 'Domicilio de prueba', 'Usuario Simulado', '5550000000',
     'Entrega de simulacion Practica 04', 1, b'1');
SET @address_id = LAST_INSERT_ID();
INSERT INTO tbd_address_components (address_ID, value, component_type)
VALUES
    (@address_id, 'Calle Ficticia 123', 'street'),
    (@address_id, 'Centro', 'neighborhood'),
    (@address_id, 'Ciudad de Mexico', 'city'),
    (@address_id, 'CDMX', 'state'),
    (@address_id, '06000', 'postal_code'),
    (@address_id, 'Mexico', 'country');

-- Guardar solo token de prueba y los ultimos cuatro digitos; nunca persistir PAN.
SELECT ID INTO @card_type_id
FROM tbc_payment_methods_types
WHERE code = 'DEBIT_CARD_SIM' AND status = b'1'
LIMIT 1;
INSERT INTO tbd_user_payment_methods
    (user_ID, payment_method_type_ID, provider, provider_method_ref,
     label, last_four, is_default, status)
VALUES
    (@new_user_id, @card_type_id, 'SIMULADOR_PR04',
     CONCAT('tok_pr04_', REPLACE(UUID(), '-', '')),
     'Tarjeta de debito ficticia', RIGHT(@simulated_card, 4), 1, b'1');
SET @payment_method_id = LAST_INSERT_ID();

-- Crear el carrito con cinco productos distintos y cantidades 1 a 5.
INSERT INTO tb_carts (user_ID, status) VALUES (@new_user_id, 'Active');
SET @cart_id = LAST_INSERT_ID();
INSERT INTO tbd_cart_items (cart_ID, product_offer_ID, quantity)
SELECT @cart_id, selected.product_offer_ID, selected.quantity
FROM (
    SELECT o.product_offer_ID,
           ROW_NUMBER() OVER (ORDER BY o.product_offer_ID) AS quantity
    FROM tbd_users_offer_products o
    JOIN tb_products p ON p.ID = o.product_ID
    WHERE o.user_ID IS NULL AND o.status = b'1'
      AND p.status = b'1' AND p.current_stock >= 5
      AND o.available_stock >= 5 AND p.current_price > 0
    ORDER BY o.product_offer_ID
    LIMIT 5
) AS selected;

-- Validar exactamente cinco renglones antes de convertir a orden.
SELECT COUNT(*) INTO @cart_line_count
FROM tbd_cart_items WHERE cart_ID = @cart_id;
SELECT IF(@cart_line_count = 5, 'Carrito listo: 5 productos',
          'ERROR: no hay cinco ofertas disponibles') AS validacion;

-- Orden de compra y detalle asociado a un vendedor de catalogo (NULL).
SELECT COALESCE(SUM(ci.quantity), 0),
       COALESCE(SUM(ci.quantity * p.current_price), 0)
INTO @total_units, @order_total
FROM tbd_cart_items ci
JOIN tbd_users_offer_products o ON o.product_offer_ID = ci.product_offer_ID
JOIN tb_products p ON p.ID = o.product_ID
WHERE ci.cart_ID = @cart_id;

INSERT INTO tb_buyer_orders (`key`, user_ID, total_products, total_cost, status_string)
VALUES (UUID(), @new_user_id, @total_units, @order_total, 'Registered');
SET @order_id = LAST_INSERT_ID();
INSERT INTO tb_seller_orders (order_ID, seller_ID, subtotal, shipping_cost)
VALUES (@order_id, (SELECT ID FROM tb_users ORDER BY ID LIMIT 1), @order_total, 0);
SET @seller_order_id = LAST_INSERT_ID();
INSERT INTO tbd_order_items (seller_order_ID, product_offer_ID, product_name, quantity, unit_price)
SELECT @seller_order_id, o.product_offer_ID, p.name, ci.quantity, p.current_price
FROM tbd_cart_items ci
JOIN tbd_users_offer_products o ON o.product_offer_ID = ci.product_offer_ID
JOIN tb_products p ON p.ID = o.product_ID
WHERE ci.cart_ID = @cart_id;
UPDATE tb_carts SET status = 'Converted' WHERE ID = @cart_id;

-- Crear un pago pendiente enlazado al metodo de pago del comprador y autorizarlo
-- con el procedimiento que registra Authorized y Captured en la tabla de eventos.
INSERT INTO tb_payments
    (order_ID, user_payment_method_ID, amount, currency, payment_method, provider,
     provider_reference, idempotency_key, payment_status)
VALUES
    (@order_id, @payment_method_id, @order_total, 'MXN', 'Card', 'SIMULADOR_PR04',
     CONCAT('pay_pr04_', REPLACE(UUID(), '-', '')),
     CONCAT('idem_pr04_', REPLACE(UUID(), '-', '')), 'Pending');
SET @payment_id = LAST_INSERT_ID();
CALL sp_authorize_payment(@payment_id);

-- Tras el pago, la aplicacion cambia el rol y el procedimiento descuenta stock.
SET ROLE buyer;
CALL sp_pr04_attend_order(@order_id);

-- Entrega simulada inmediata; el procedimiento crea el envio Delivered.
CALL sp_pr04_deliver_order(@order_id, @address_id);

-- Evidencia de cierre de la prueba.
SELECT @email AS usuario, @new_user_id AS user_ID, @order_id AS order_ID,
       @payment_id AS payment_ID, @address_id AS address_ID;
SELECT bo.ID AS order_ID, bo.status_string, bo.total_products, bo.total_cost,
       p.payment_status, p.provider, p.provider_reference,
       t.event_type, t.amount, t.event_reference,
       s.shipment_status, s.carrier, s.tracking_number
FROM tb_buyer_orders bo
JOIN tb_payments p ON p.order_ID = bo.ID
JOIN tb_payment_transactions t ON t.payment_ID = p.ID
JOIN tb_seller_orders so ON so.order_ID = bo.ID
JOIN tb_shipments s ON s.seller_order_ID = so.ID
WHERE bo.ID = @order_id
ORDER BY t.ID;
