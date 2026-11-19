-- Caso 3: compra, cancelacion de una linea, reembolso parcial y entrega.
-- Ejecutar como DBA en una restauracion preparada con 01_preparar_catalogo.sql.
USE db_test_corregida;

INSERT INTO tbc_payment_methods_types (code,description,status)
VALUES ('SPIN_CARD_SIM','Tarjeta digital Spin simulada para Practica 04',b'1')
ON DUPLICATE KEY UPDATE description=VALUES(description),status=b'1';

-- Completar una ejecucion anterior interrumpida despues de borrar la linea cancelada.
SET @recovery_order_id=(
    SELECT MIN(bo.ID) FROM tb_buyer_orders bo
    JOIN tb_order_cancellations c ON c.order_ID=bo.ID
    WHERE bo.status_string='Attended'
      AND c.cancellation_reason='Cancelacion parcial solicitada por el comprador'
      AND NOT EXISTS (SELECT 1 FROM tb_refunds r WHERE r.cancellation_ID=c.cancellation_ID)
);
SET @recovery_cancellation_id=(
    SELECT MIN(c.cancellation_ID) FROM tb_order_cancellations c
    WHERE c.order_ID=@recovery_order_id
      AND c.cancellation_reason='Cancelacion parcial solicitada por el comprador'
      AND NOT EXISTS (SELECT 1 FROM tb_refunds r WHERE r.cancellation_ID=c.cancellation_ID)
);
SET @recovery_payment_id=(SELECT ID FROM tb_payments WHERE order_ID=@recovery_order_id LIMIT 1);
SET @recovery_address_id=(SELECT ID FROM tb_user_addresses
    WHERE user_ID=(SELECT user_ID FROM tb_buyer_orders WHERE ID=@recovery_order_id)
      AND address_label='Casa Papas' ORDER BY ID DESC LIMIT 1);
UPDATE tb_buyer_orders bo
SET bo.total_products=(SELECT COALESCE(SUM(oi.quantity),0) FROM tbd_order_items oi JOIN tb_seller_orders so ON so.ID=oi.seller_order_ID WHERE so.order_ID=bo.ID),
    bo.total_cost=(SELECT COALESCE(SUM(oi.subtotal),0) FROM tbd_order_items oi JOIN tb_seller_orders so ON so.ID=oi.seller_order_ID WHERE so.order_ID=bo.ID)
WHERE bo.ID=@recovery_order_id;
UPDATE tb_seller_orders SET subtotal=(SELECT total_cost FROM tb_buyer_orders WHERE ID=@recovery_order_id)
WHERE order_ID=@recovery_order_id;
SET @recovery_refund_amount=(
    SELECT COALESCE(SUM(ci.quantity*p.current_price),0)
    FROM tb_order_cancellations c
    JOIN tbd_cancellation_items ci ON ci.cancellation_id=c.cancellation_ID
    JOIN tbd_users_offer_products o ON o.product_offer_ID=c.product_offer_ID
    JOIN tb_products p ON p.ID=o.product_ID
    WHERE c.cancellation_ID=@recovery_cancellation_id
);
INSERT INTO tb_refunds (payment_ID,cancellation_ID,amount,currency,refund_reason,refund_status,provider_reference,completed_date)
SELECT @recovery_payment_id,@recovery_cancellation_id,@recovery_refund_amount,'MXN',
       'Reembolso parcial recuperado del Caso 3','Completed',CONCAT('refund3_recovery_',UUID()),NOW()
WHERE @recovery_cancellation_id IS NOT NULL AND @recovery_refund_amount>0;
UPDATE tb_payments SET payment_status='PartiallyRefunded' WHERE ID=@recovery_payment_id;
INSERT INTO tb_payment_transactions (payment_ID,event_type,amount,event_reference,remarks)
SELECT @recovery_payment_id,'PartiallyRefunded',@recovery_refund_amount,
       CONCAT('partial_refund3_recovery_',UUID()),'Reembolso parcial recuperado del Caso 3'
WHERE @recovery_payment_id IS NOT NULL AND @recovery_refund_amount>0
  AND NOT EXISTS (SELECT 1 FROM tb_payment_transactions t
                  WHERE t.payment_ID=@recovery_payment_id AND t.event_type='PartiallyRefunded');
SET @recovery_call=IF(@recovery_order_id IS NULL,'SELECT 1',
    CONCAT('CALL sp_pr04_deliver_order(',@recovery_order_id,',',@recovery_address_id,')'));
PREPARE recovery_stmt FROM @recovery_call;
EXECUTE recovery_stmt;
DEALLOCATE PREPARE recovery_stmt;

SET @buyer_id = COALESCE(
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.nick LIKE 'user_test_%' AND u.status = b'1'
       AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID = u.ID)),
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.status=b'1' AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID=u.ID))
);
SET @seller_id = (SELECT MIN(ID) FROM tb_users WHERE status = b'1' AND ID <> @buyer_id);

-- Clasificar las ofertas de demostracion juntas en el catalogo existente.
INSERT INTO tbc_categories (name,description,status,last_update)
VALUES ('Practica04-Categoria-Casos','Clasificacion de prueba para los casos 3 a 5',b'1',NOW())
ON DUPLICATE KEY UPDATE description=VALUES(description),status=b'1',last_update=NOW();
INSERT IGNORE INTO tbd_products_categories (category_ID,product_ID,status,last_update)
SELECT c.ID,o.product_ID,b'1',NOW()
FROM tbc_categories c
JOIN tbd_users_offer_products o ON o.user_ID IS NULL AND o.status=b'1'
JOIN tb_products p ON p.ID=o.product_ID AND p.status=b'1'
WHERE c.name='Practica04-Categoria-Casos'
  AND p.current_price>0 AND p.current_stock>=3 AND o.available_stock>=3
ORDER BY o.product_offer_ID LIMIT 5;

-- Tres ofertas de una misma categoria, con inventario suficiente para qty 1,2,3.
DROP TEMPORARY TABLE IF EXISTS pr04_case3_products;
CREATE TEMPORARY TABLE pr04_case3_products AS
SELECT product_offer_ID, product_ID, category_ID, product_name, unit_price,
       ROW_NUMBER() OVER (ORDER BY product_offer_ID) AS line_no
FROM (
    SELECT o.product_offer_ID, p.ID AS product_ID, pc.category_ID,
           p.name AS product_name, p.current_price AS unit_price
    FROM tbd_users_offer_products o
    JOIN tb_products p ON p.ID = o.product_ID
    JOIN tbd_products_categories pc ON pc.product_ID = p.ID AND pc.status = b'1'
    WHERE o.status = b'1' AND p.status = b'1' AND p.current_price > 0
      AND o.available_stock >= 3 AND p.current_stock >= 3
    GROUP BY o.product_offer_ID, p.ID, pc.category_ID, p.name, p.current_price
) candidates
WHERE category_ID = (
    SELECT pc.category_ID
    FROM tbd_users_offer_products o
    JOIN tb_products p ON p.ID = o.product_ID
    JOIN tbd_products_categories pc ON pc.product_ID = p.ID AND pc.status = b'1'
    WHERE o.status = b'1' AND p.status = b'1' AND p.current_price > 0
      AND o.available_stock >= 3 AND p.current_stock >= 3
    GROUP BY pc.category_ID HAVING COUNT(DISTINCT o.product_offer_ID) >= 3
    ORDER BY pc.category_ID LIMIT 1
)
ORDER BY product_offer_ID LIMIT 3;

SET @selected_count = (SELECT COUNT(*) FROM pr04_case3_products);
SELECT @buyer_id AS buyer_ID, @selected_count AS productos_seleccionados;

INSERT INTO tb_carts (user_ID, status) VALUES (@buyer_id, 'Active');
SET @cart_id = LAST_INSERT_ID();
INSERT INTO tbd_cart_items (cart_ID, product_offer_ID, quantity)
SELECT @cart_id, product_offer_ID, line_no FROM pr04_case3_products;

INSERT INTO tb_user_addresses
    (user_ID, address_label, recipient_name, recipient_phone, delivery_instructions, is_default, status)
VALUES (@buyer_id, 'Casa Papas', 'Familiar del comprador', '5550000003',
        'Domicilio alternativo para el caso de prueba 3', 0, b'1');
SET @address_id = LAST_INSERT_ID();
INSERT INTO tbd_address_components (address_ID, value, component_type)
VALUES (@address_id,'Calle Alternativa 30','street'),(@address_id,'Centro','neighborhood'),
       (@address_id,'Ciudad de Mexico','city'),(@address_id,'CDMX','state'),
       (@address_id,'06000','postal_code'),(@address_id,'Mexico','country');

SELECT ID INTO @method_type_id FROM tbc_payment_methods_types WHERE code='SPIN_CARD_SIM';
SET @simulated_spin_number='4242424242424242'; -- solo para la demostracion; no se persiste completo
INSERT INTO tbd_user_payment_methods
    (user_ID,payment_method_type_ID,provider,provider_method_ref,label,last_four,is_default,status)
VALUES (@buyer_id,@method_type_id,'SPIN_SIMULATOR',CONCAT('spin_tok_',REPLACE(UUID(),'-','')),
        'Tarjeta digital Spin simulada',RIGHT(@simulated_spin_number,4),0,b'1');
SET @method_id = LAST_INSERT_ID();

SELECT COALESCE(SUM(p.unit_price * p.line_no),0), COALESCE(SUM(p.line_no),0)
INTO @total,@units FROM pr04_case3_products p;
SELECT @selected_count AS productos_en_categoria_comun,@total AS total_compra;
INSERT INTO tb_buyer_orders (`key`,user_ID,total_products,total_cost,status_string)
VALUES (UUID(),@buyer_id,@units,@total,'Registered');
SET @order_id = LAST_INSERT_ID();
INSERT INTO tb_seller_orders (order_ID,seller_ID,subtotal,shipping_cost)
VALUES (@order_id,@seller_id,@total,0);
SET @seller_order_id = LAST_INSERT_ID();
INSERT INTO tbd_order_items (seller_order_ID,product_offer_ID,product_name,quantity,unit_price)
SELECT @seller_order_id,product_offer_ID,product_name,line_no,unit_price FROM pr04_case3_products;
UPDATE tb_carts SET status='Converted' WHERE ID=@cart_id;

-- Se conserva la Spin en el perfil; este escenario registra el pago acordado como efectivo.
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@total,'MXN','Cash','EFECTIVO_SIM_PR04',CONCAT('cash3_',UUID()),
        CONCAT('idem3_',UUID()),'Pending');
SET @payment_id = LAST_INSERT_ID();
CALL sp_authorize_payment(@payment_id);
CALL sp_pr04_attend_order(@order_id);

-- Cancelar totalmente la primera linea y ajustar inventario, orden y reembolso.
SELECT oi.ID,oi.product_offer_ID,oi.quantity,oi.unit_price
INTO @cancel_item_id,@cancel_offer_id,@cancel_qty,@cancel_price
FROM tbd_order_items oi WHERE oi.seller_order_ID=@seller_order_id ORDER BY oi.ID LIMIT 1;
SET @refund_amount = ROUND(@cancel_qty * @cancel_price,2);
INSERT INTO tb_order_cancellations
    (order_ID,seller_order_ID,product_offer_ID,requested_by,cancellation_reason,cancellation_status,resolved_date)
VALUES (@order_id,@seller_order_id,@cancel_offer_id,@buyer_id,'Cancelacion parcial solicitada por el comprador','Completed',NOW());
SET @cancellation_id = LAST_INSERT_ID();
INSERT INTO tbd_cancellation_items (cancellation_id,order_item_id,quantity,reason)
VALUES (@cancellation_id,@cancel_item_id,@cancel_qty,'Producto cancelado antes del envio');
DELETE FROM tbd_order_items WHERE ID=@cancel_item_id;
UPDATE tbd_users_offer_products SET available_stock=available_stock+@cancel_qty WHERE product_offer_ID=@cancel_offer_id;
UPDATE tb_products p JOIN tbd_users_offer_products o ON o.product_ID=p.ID
SET p.current_stock=p.current_stock+@cancel_qty WHERE o.product_offer_ID=@cancel_offer_id;
UPDATE tb_buyer_orders bo
SET bo.total_products=(SELECT COALESCE(SUM(quantity),0) FROM tbd_order_items oi JOIN tb_seller_orders so ON so.ID=oi.seller_order_ID WHERE so.order_ID=@order_id),
    bo.total_cost=(SELECT COALESCE(SUM(oi.subtotal),0) FROM tbd_order_items oi JOIN tb_seller_orders so ON so.ID=oi.seller_order_ID WHERE so.order_ID=@order_id)
WHERE bo.ID=@order_id;
UPDATE tb_seller_orders SET subtotal=(SELECT total_cost FROM tb_buyer_orders WHERE ID=@order_id) WHERE ID=@seller_order_id;
INSERT INTO tb_refunds (payment_ID,cancellation_ID,amount,currency,refund_reason,refund_status,provider_reference,completed_date)
VALUES (@payment_id,@cancellation_id,@refund_amount,'MXN','Reembolso de producto cancelado','Completed',CONCAT('refund3_',UUID()),NOW());
UPDATE tb_payments SET payment_status='PartiallyRefunded' WHERE ID=@payment_id;
INSERT INTO tb_payment_transactions (payment_ID,event_type,amount,event_reference,remarks)
VALUES (@payment_id,'PartiallyRefunded',@refund_amount,CONCAT('partial_refund3_',UUID()),'Reembolso parcial del Caso 3');
CALL sp_pr04_deliver_order(@order_id,@address_id);

SELECT bo.ID,bo.status_string,bo.total_products,bo.total_cost,p.payment_status,p.payment_method,
       r.amount AS reembolso,s.shipment_status,s.delivery_address_ID
FROM tb_buyer_orders bo JOIN tb_payments p ON p.order_ID=bo.ID
JOIN tb_refunds r ON r.payment_ID=p.ID JOIN tb_seller_orders so ON so.order_ID=bo.ID
JOIN tb_shipments s ON s.seller_order_ID=so.ID WHERE bo.ID=@order_id;
