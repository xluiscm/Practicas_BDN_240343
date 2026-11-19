-- Caso 5: agotamiento al atender la orden, cancelacion y liberacion del cupon.
-- Ejecutar como DBA en una restauracion preparada con 01_preparar_catalogo.sql.
USE db_test_corregida;

INSERT INTO tbc_payment_methods_types (code,description,status)
VALUES ('GIFT_COUPON_SIM','Cupon de regalo simulado para Practica 04',b'1')
ON DUPLICATE KEY UPDATE description=VALUES(description),status=b'1';

-- Recuperar intentos interrumpidos de este caso (por ejemplo, si faltaba una rutina).
UPDATE tbd_users_offer_products o
JOIN tb_products p ON p.ID=o.product_ID
JOIN tbd_order_items oi ON oi.product_offer_ID=o.product_offer_ID
JOIN tb_seller_orders so ON so.ID=oi.seller_order_ID
JOIN tb_payments pay ON pay.order_ID=so.order_ID
SET o.available_stock=p.current_stock
WHERE pay.provider='CUPON_SIMULATOR' AND pay.payment_status='Paid'
  AND pay.provider_reference LIKE 'coupon_pay5_%';
UPDATE tbd_user_payment_methods m
JOIN tb_payments pay ON pay.user_payment_method_ID=m.ID
SET m.status=b'1'
WHERE pay.provider='CUPON_SIMULATOR' AND pay.payment_status='Paid'
  AND pay.provider_reference LIKE 'coupon_pay5_%';
UPDATE tb_buyer_orders bo
JOIN tb_payments pay ON pay.order_ID=bo.ID
SET bo.status_string='Canceled'
WHERE pay.provider='CUPON_SIMULATOR' AND pay.payment_status='Paid'
  AND pay.provider_reference LIKE 'coupon_pay5_%' AND bo.status_string='Payed';
UPDATE tb_seller_orders so
JOIN tb_buyer_orders bo ON bo.ID=so.order_ID
SET so.fulfillment_status='Canceled'
WHERE bo.status_string='Canceled' AND EXISTS (
    SELECT 1 FROM tb_payments pay WHERE pay.order_ID=bo.ID
      AND pay.provider='CUPON_SIMULATOR' AND pay.provider_reference LIKE 'coupon_pay5_%'
);
UPDATE tb_payments SET payment_status='Failed'
WHERE provider='CUPON_SIMULATOR' AND payment_status='Paid'
  AND provider_reference LIKE 'coupon_pay5_%'
  AND order_ID IN (SELECT ID FROM tb_buyer_orders WHERE status_string='Canceled');

SET @buyer_id=COALESCE(
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.nick LIKE 'user_test_%' AND u.status=b'1'
       AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID=u.ID)),
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.status=b'1'
       AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID=u.ID))
);
SET @seller_id=(SELECT MIN(ID) FROM tb_users WHERE status=b'1' AND ID<>@buyer_id);
SET @offer_id=(SELECT o.product_offer_ID FROM tbd_users_offer_products o
               JOIN tb_products p ON p.ID=o.product_ID
               WHERE o.status=b'1' AND p.status=b'1' AND p.current_price>0
                 AND o.available_stock>0 AND p.current_stock>0
               ORDER BY o.product_offer_ID LIMIT 1);
SET @product_id=(SELECT product_ID FROM tbd_users_offer_products WHERE product_offer_ID=@offer_id);
SET @product_name=(SELECT name FROM tb_products WHERE ID=@product_id);
SET @unit_price=(SELECT current_price FROM tb_products WHERE ID=@product_id);
SET @saved_offer_stock=(SELECT available_stock FROM tbd_users_offer_products WHERE product_offer_ID=@offer_id);
SELECT @buyer_id AS buyer_ID,@offer_id AS oferta,@saved_offer_stock AS stock_inicial;

INSERT INTO tb_carts (user_ID,status) VALUES (@buyer_id,'Active');
SET @cart_id=LAST_INSERT_ID();
INSERT INTO tbd_cart_items (cart_ID,product_offer_ID,quantity) VALUES (@cart_id,@offer_id,1);
INSERT INTO tb_user_addresses
    (user_ID,address_label,recipient_name,recipient_phone,delivery_instructions,is_default,status)
VALUES (@buyer_id,'Casa','Comprador de prueba','5550000005','Domicilio habitual Caso 5',1,b'1');
SET @address_id=LAST_INSERT_ID();
INSERT INTO tbd_address_components (address_ID,value,component_type)
VALUES (@address_id,'Calle Principal 50','street'),(@address_id,'Centro','neighborhood'),
       (@address_id,'Ciudad de Mexico','city'),(@address_id,'CDMX','state'),
       (@address_id,'06000','postal_code'),(@address_id,'Mexico','country');

SELECT ID INTO @method_type_id FROM tbc_payment_methods_types WHERE code='GIFT_COUPON_SIM';
INSERT INTO tbd_user_payment_methods
    (user_ID,payment_method_type_ID,provider,provider_method_ref,label,last_four,is_default,status)
VALUES (@buyer_id,@method_type_id,'CUPON_SIMULATOR',CONCAT('coupon_ref_',UUID()),
        'Cupon de regalo simulado','0005',0,b'1');
SET @method_id=LAST_INSERT_ID();

INSERT INTO tb_buyer_orders (`key`,user_ID,total_products,total_cost,status_string)
VALUES (UUID(),@buyer_id,1,@unit_price,'Registered');
SET @order_id=LAST_INSERT_ID();
INSERT INTO tb_seller_orders (order_ID,seller_ID,subtotal,shipping_cost)
VALUES (@order_id,@seller_id,@unit_price,0);
SET @seller_order_id=LAST_INSERT_ID();
INSERT INTO tbd_order_items (seller_order_ID,product_offer_ID,product_name,quantity,unit_price)
VALUES (@seller_order_id,@offer_id,@product_name,1,@unit_price);
UPDATE tb_carts SET status='Converted' WHERE ID=@cart_id;

-- Reservar el cupon desactivando temporalmente el metodo dependiente.
UPDATE tbd_user_payment_methods SET status=b'0' WHERE ID=@method_id;
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@unit_price,'MXN','Other','CUPON_SIMULATOR',CONCAT('coupon_pay5_',UUID()),
        CONCAT('idem5_',UUID()),'Pending');
SET @payment_id=LAST_INSERT_ID();
CALL sp_authorize_payment(@payment_id);

-- Simular que otro comprador agota la oferta luego de crear la orden y antes de atenderla.
UPDATE tbd_users_offer_products SET available_stock=0 WHERE product_offer_ID=@offer_id;
-- Ejecutar el procedimiento real de atencion y capturar su error sin detener
-- todo el script. El helper se elimina al terminar; no crea tablas.
DROP PROCEDURE IF EXISTS sp_pr04_case5_try_attend;
DELIMITER $$
CREATE PROCEDURE sp_pr04_case5_try_attend(IN p_order_id INT UNSIGNED)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @case5_sqlstate = RETURNED_SQLSTATE,
            @case5_error = MESSAGE_TEXT;
        IF @case5_sqlstate <> '45000' OR @case5_error <> 'Inventario insuficiente' THEN
            RESIGNAL;
        END IF;
    END;

    CALL sp_pr04_attend_order(p_order_id);
    SET @case5_attended=1;
END$$
DELIMITER ;

SET @case5_attended=0;
SET @case5_sqlstate=NULL;
SET @case5_error=NULL;
CALL sp_pr04_case5_try_attend(@order_id);
DROP PROCEDURE sp_pr04_case5_try_attend;

SELECT @case5_attended AS orden_atendida,@case5_sqlstate AS estado_sql,
       @case5_error AS motivo_rechazo_atencion;

-- Solo cancelar y liberar el cupon si el procedimiento rechazó por inventario.
-- La orden se cancela y el método dependiente se reactiva.
UPDATE tb_buyer_orders bo
SET bo.status_string='Canceled'
WHERE bo.ID=@order_id AND @case5_attended=0
  AND @case5_sqlstate='45000' AND @case5_error='Inventario insuficiente';
UPDATE tb_seller_orders SET fulfillment_status='Canceled' WHERE order_ID=@order_id
  AND (SELECT status_string FROM tb_buyer_orders WHERE ID=@order_id)='Canceled';
UPDATE tb_payments SET payment_status='Failed' WHERE ID=@payment_id
  AND (SELECT status_string FROM tb_buyer_orders WHERE ID=@order_id)='Canceled';
UPDATE tbd_user_payment_methods SET status=b'1' WHERE ID=@method_id
  AND (SELECT status_string FROM tb_buyer_orders WHERE ID=@order_id)='Canceled';
UPDATE tbd_users_offer_products SET available_stock=@saved_offer_stock WHERE product_offer_ID=@offer_id;
INSERT INTO tb_payment_transactions (payment_ID,event_type,amount,event_reference,remarks)
VALUES (@payment_id,'Voided',@unit_price,CONCAT('coupon_void5_',UUID()),
        'Orden no atendida: sp_pr04_attend_order rechazo por Inventario insuficiente; cupon liberado');

SELECT bo.ID,bo.status_string,bo.total_products,bo.total_cost,p.payment_status,p.payment_method,
       @case5_sqlstate AS sqlstate_atencion,@case5_error AS motivo_rechazo_atencion,
       CONCAT('Cupon PR04 reasignado; metodo activo=',m.status) AS estado_cupon,o.available_stock
FROM tb_buyer_orders bo JOIN tb_payments p ON p.order_ID=bo.ID
JOIN tbd_user_payment_methods m ON m.ID=@method_id
JOIN tbd_users_offer_products o ON o.product_offer_ID=@offer_id
WHERE bo.ID=@order_id;
