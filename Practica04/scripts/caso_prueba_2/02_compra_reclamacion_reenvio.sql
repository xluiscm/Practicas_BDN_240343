-- Caso 2: seis parcialidades, ultimo pago rechazado, reclamacion y reenvio.
-- Ejecutar como DBA sobre una restauracion de prueba preparada con
-- caso_prueba_1/01_preparar_catalogo.sql.
USE db_test_corregida;

INSERT INTO tbc_payment_methods_types (code,description,status)
VALUES ('CREDIT_CARD_SIM','Tarjeta de credito simulada para Practica 04',b'1')
ON DUPLICATE KEY UPDATE description=VALUES(description),status=b'1';

-- El intento fallido no crea carrito. Priorizar una cuenta de la carga de 10 mil.
SET @buyer_id=COALESCE(
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.nick LIKE 'user_test_%' AND u.status=b'1'
       AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID=u.ID)),
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.status=b'1' AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID=u.ID))
);
SET @seller_id=(SELECT MIN(ID) FROM tb_users WHERE status=b'1' AND ID<>@buyer_id);

-- Extender las ofertas del catalogo global existente con inventario de respaldo.
INSERT INTO tbd_users_offer_products (user_ID,product_ID,available_stock,status,available_date)
SELECT NULL,p.ID,p.current_stock,b'1',NOW()
FROM tb_products p
WHERE p.status=b'1' AND p.current_price>0 AND p.current_stock>=6
  AND NOT EXISTS (
      SELECT 1 FROM tbd_users_offer_products o
      WHERE o.product_ID=p.ID AND o.user_ID IS NULL AND o.status=b'1'
  )
ORDER BY RAND() LIMIT 20;

-- Elegir diez productos distintos y generar cantidades aleatorias de 1 a 5.
DROP TEMPORARY TABLE IF EXISTS pr04_case2_products;
CREATE TEMPORARY TABLE pr04_case2_products AS
SELECT product_offer_ID,product_ID,product_name,unit_price,
       FLOOR(1+RAND()*5) AS quantity
FROM (
    SELECT MIN(o.product_offer_ID) AS product_offer_ID,p.ID AS product_ID,
           p.name AS product_name,p.current_price AS unit_price
    FROM tbd_users_offer_products o
    JOIN tb_products p ON p.ID=o.product_ID
    WHERE o.user_ID IS NULL AND o.status=b'1' AND p.status=b'1'
      AND p.current_price>0 AND o.available_stock>=6 AND p.current_stock>=6
    GROUP BY p.ID,p.name,p.current_price
    ORDER BY RAND() LIMIT 10
) AS candidates;
SET @product_count=(SELECT COUNT(*) FROM pr04_case2_products);
SELECT @buyer_id AS buyer_ID,@product_count AS productos_seleccionados;

INSERT INTO tb_carts (user_ID,status) VALUES (@buyer_id,'Active');
SET @cart_id=LAST_INSERT_ID();
INSERT INTO tbd_cart_items (cart_ID,product_offer_ID,quantity)
SELECT @cart_id,product_offer_ID,quantity FROM pr04_case2_products;

-- Domicilio alternativo: trabajo.
INSERT INTO tb_user_addresses
    (user_ID,address_label,recipient_name,recipient_phone,delivery_instructions,is_default,status)
VALUES (@buyer_id,'Trabajo','Comprador de prueba','5550000002',
        'Entregar en recepcion del trabajo',0,b'1');
SET @address_id=LAST_INSERT_ID();
INSERT INTO tbd_address_components (address_ID,value,component_type)
VALUES (@address_id,'Avenida del Trabajo 200','street'),
       (@address_id,'Parque Industrial','neighborhood'),
       (@address_id,'Ciudad de Mexico','city'),(@address_id,'CDMX','state'),
       (@address_id,'06000','postal_code'),(@address_id,'Mexico','country');

-- Cuenta ficticia de 16 digitos: solo se conserva el token y los ultimos cuatro.
SET @simulated_credit_card='5555555555554444';
SELECT ID INTO @method_type_id FROM tbc_payment_methods_types WHERE code='CREDIT_CARD_SIM';
INSERT INTO tbd_user_payment_methods
    (user_ID,payment_method_type_ID,provider,provider_method_ref,label,last_four,is_default,status)
VALUES (@buyer_id,@method_type_id,'CREDIT_SIMULATOR',CONCAT('credit_tok2_',REPLACE(UUID(),'-','')),
        'Tarjeta de credito simulada',RIGHT(@simulated_credit_card,4),0,b'1');
SET @method_id=LAST_INSERT_ID();

SELECT SUM(quantity*unit_price),SUM(quantity) INTO @order_total,@total_units
FROM pr04_case2_products;
INSERT INTO tb_buyer_orders (`key`,user_ID,total_products,total_cost,status_string)
VALUES (UUID(),@buyer_id,@total_units,@order_total,'Registered');
SET @order_id=LAST_INSERT_ID();
INSERT INTO tb_seller_orders (order_ID,seller_ID,subtotal,shipping_cost)
VALUES (@order_id,@seller_id,@order_total,0);
SET @seller_order_id=LAST_INSERT_ID();
INSERT INTO tbd_order_items (seller_order_ID,product_offer_ID,product_name,quantity,unit_price)
SELECT @seller_order_id,product_offer_ID,product_name,quantity,unit_price
FROM pr04_case2_products;
UPDATE tb_carts SET status='Converted' WHERE ID=@cart_id;

-- Cinco mensualidades autorizadas; la sexta falla por limite de credito.
SET @installment=ROUND(@order_total/6,2);
SET @last_installment=@order_total-(@installment*5);
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,
     provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@installment,'MXN','Card','CREDIT_SIMULATOR',
        CONCAT('case2_pay1_',UUID()),CONCAT('case2_idem1_',UUID()),'Pending');
SET @payment1=LAST_INSERT_ID(); CALL sp_authorize_payment(@payment1);
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,
     provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@installment,'MXN','Card','CREDIT_SIMULATOR',
        CONCAT('case2_pay2_',UUID()),CONCAT('case2_idem2_',UUID()),'Pending');
SET @payment2=LAST_INSERT_ID(); CALL sp_authorize_payment(@payment2);
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,
     provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@installment,'MXN','Card','CREDIT_SIMULATOR',
        CONCAT('case2_pay3_',UUID()),CONCAT('case2_idem3_',UUID()),'Pending');
SET @payment3=LAST_INSERT_ID(); CALL sp_authorize_payment(@payment3);
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,
     provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@installment,'MXN','Card','CREDIT_SIMULATOR',
        CONCAT('case2_pay4_',UUID()),CONCAT('case2_idem4_',UUID()),'Pending');
SET @payment4=LAST_INSERT_ID(); CALL sp_authorize_payment(@payment4);
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,
     provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@installment,'MXN','Card','CREDIT_SIMULATOR',
        CONCAT('case2_pay5_',UUID()),CONCAT('case2_idem5_',UUID()),'Pending');
SET @payment5=LAST_INSERT_ID(); CALL sp_authorize_payment(@payment5);

INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,
     provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@last_installment,'MXN','Card','CREDIT_SIMULATOR',
        CONCAT('case2_pay6_',UUID()),CONCAT('case2_idem6_',UUID()),'Failed');
SET @payment6=LAST_INSERT_ID();
INSERT INTO tb_payment_transactions (payment_ID,event_type,amount,event_reference,remarks)
VALUES (@payment6,'Failed',@last_installment,CONCAT('case2_declined_',UUID()),
        'Limite excedido de credito');

-- Atender y entregar la orden; el pago mensual rechazado queda en el historial.
CALL sp_pr04_attend_order(@order_id);
CALL sp_pr04_deliver_order(@order_id,@address_id);

-- Registrar una reclamacion por un articulo dañado.
SELECT ID,product_offer_ID INTO @returned_item_id,@returned_offer_id
FROM tbd_order_items WHERE seller_order_ID=@seller_order_id ORDER BY ID LIMIT 1;
SET @returned_quantity=1;
INSERT INTO tb_returns
    (order_ID,product_offer_ID,requested_by,quantity,return_reason,return_status,
     inspection_notes,received_date,completed_date)
VALUES (@order_id,@returned_offer_id,@buyer_id,@returned_quantity,'Damaged','Completed',
        'Producto recibido dañado; se envia una unidad de reposicion',NOW(),NOW());
SET @return_id=LAST_INSERT_ID();
INSERT INTO tbd_return_items (return_id,order_item_id,quantity,condition_notes)
VALUES (@return_id,@returned_item_id,@returned_quantity,'Dañado al recibir; reposicion enviada');

-- Descontar una unidad de reposicion del inventario y registrar el segundo envio.
UPDATE tbd_users_offer_products
SET available_stock=available_stock-1
WHERE product_offer_ID=@returned_offer_id AND available_stock>=1;
UPDATE tb_products p JOIN tbd_users_offer_products o ON o.product_ID=p.ID
SET p.current_stock=p.current_stock-1
WHERE o.product_offer_ID=@returned_offer_id AND p.current_stock>=1;
INSERT INTO tb_shipments
    (seller_order_ID,delivery_address_ID,carrier,tracking_number,tracking_url,
     shipment_status,shipped_date,estimated_delivery_date,delivered_date)
VALUES (@seller_order_id,@address_id,'REENVIO_SIMULADO',CONCAT('RESEND2-',@order_id),
        'Reenvio de reposicion por reclamacion de producto dañado','Delivered',
        NOW(),NOW(),NOW());

-- Resumen de cierre del Caso 2.
SELECT @order_id AS order_ID,@buyer_id AS user_ID,@address_id AS address_ID,
       @order_total AS total_orden,@product_count AS productos_distintos,@return_id AS return_ID;
SELECT p.ID AS payment_ID,p.amount,p.payment_status,t.event_type,t.remarks
FROM tb_payments p
LEFT JOIN tb_payment_transactions t ON t.payment_ID=p.ID
WHERE p.order_ID=@order_id
ORDER BY p.ID,t.ID;
SELECT bo.ID AS order_ID,bo.status_string,bo.total_products,bo.total_cost,
       r.return_reason,r.return_status,r.inspection_notes,
       s.shipment_status,s.carrier,s.tracking_number,s.tracking_url
FROM tb_buyer_orders bo
JOIN tb_returns r ON r.order_ID=bo.ID
JOIN tb_seller_orders so ON so.order_ID=bo.ID
JOIN tb_shipments s ON s.seller_order_ID=so.ID
WHERE bo.ID=@order_id
ORDER BY s.shipment_ID;
