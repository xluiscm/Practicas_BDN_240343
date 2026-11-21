-- Caso 4: compra de tres productos de un proveedor y recoleccion en punto.
-- Ejecutar como DBA en una restauracion preparada con 01_preparar_catalogo.sql.
USE db_test_corregida;

INSERT INTO tbc_payment_methods_types (code,description,status)
VALUES ('SPEI_ACCOUNT_SIM','Cuenta SPEI simulada para Practica 04',b'1')
ON DUPLICATE KEY UPDATE description=VALUES(description),status=b'1';

SET @buyer_id = COALESCE(
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.nick LIKE 'user_test_%' AND u.status=b'1'
       AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID=u.ID)),
    (SELECT MIN(u.ID) FROM tb_users u
     WHERE u.status=b'1' AND NOT EXISTS (SELECT 1 FROM tb_carts c WHERE c.user_ID=u.ID))
);
SET @seller_id = (SELECT MIN(ID) FROM tb_users WHERE status=b'1' AND ID<>@buyer_id);
DROP TEMPORARY TABLE IF EXISTS pr04_case4_products;
CREATE TEMPORARY TABLE pr04_case4_products AS
SELECT product_offer_ID,product_ID,product_name,unit_price,
       ROW_NUMBER() OVER (ORDER BY product_offer_ID) AS line_no
FROM (
    SELECT o.product_offer_ID,p.ID AS product_ID,p.name AS product_name,p.current_price AS unit_price
    FROM tbd_users_offer_products o JOIN tb_products p ON p.ID=o.product_ID
    WHERE o.status=b'1' AND p.status=b'1' AND p.current_price>0
      AND o.available_stock>=3 AND p.current_stock>=3
      AND COALESCE(o.user_ID,@seller_id)=@seller_id
    ORDER BY o.product_offer_ID LIMIT 3
) available;
SET @selected_count=(SELECT COUNT(*) FROM pr04_case4_products);
SELECT @buyer_id AS buyer_ID,@selected_count AS productos_seleccionados;

INSERT INTO tb_carts (user_ID,status) VALUES (@buyer_id,'Active');
SET @cart_id=LAST_INSERT_ID();
INSERT INTO tbd_cart_items (cart_ID,product_offer_ID,quantity)
SELECT @cart_id,product_offer_ID,line_no FROM pr04_case4_products;

INSERT INTO tb_user_addresses
    (user_ID,address_label,recipient_name,recipient_phone,delivery_instructions,is_default,status)
VALUES (@buyer_id,'Casa','Comprador de prueba','5550000004','Domicilio habitual; no hubo quien recibiera el paquete',1,b'1');
SET @address_id=LAST_INSERT_ID();
INSERT INTO tbd_address_components (address_ID,value,component_type)
VALUES (@address_id,'Calle Principal 40','street'),(@address_id,'Centro','neighborhood'),
       (@address_id,'Ciudad de Mexico','city'),(@address_id,'CDMX','state'),
       (@address_id,'06000','postal_code'),(@address_id,'Mexico','country');

SELECT ID INTO @method_type_id FROM tbc_payment_methods_types WHERE code='SPEI_ACCOUNT_SIM';
SET @simulated_spei_account='1234567890123456'; -- cuenta ficticia, no persistir completa
INSERT INTO tbd_user_payment_methods
    (user_ID,payment_method_type_ID,provider,provider_method_ref,label,last_four,is_default,status)
VALUES (@buyer_id,@method_type_id,'SPEI_SIMULATOR',CONCAT('spei_',REPLACE(UUID(),'-','')),
        'Cuenta SPEI simulada',RIGHT(@simulated_spei_account,4),0,b'1');
SET @method_id=LAST_INSERT_ID();

SELECT SUM(unit_price*line_no),SUM(line_no) INTO @total,@units FROM pr04_case4_products;
INSERT INTO tb_buyer_orders (`key`,user_ID,total_products,total_cost,status_string)
VALUES (UUID(),@buyer_id,@units,@total,'Registered');
SET @order_id=LAST_INSERT_ID();
INSERT INTO tb_seller_orders (order_ID,seller_ID,subtotal,shipping_cost)
VALUES (@order_id,@seller_id,@total,0);
SET @seller_order_id=LAST_INSERT_ID();
INSERT INTO tbd_order_items (seller_order_ID,product_offer_ID,product_name,quantity,unit_price)
SELECT @seller_order_id,product_offer_ID,product_name,line_no,unit_price FROM pr04_case4_products;
UPDATE tb_carts SET status='Converted' WHERE ID=@cart_id;

-- Se registra la cuenta SPEI como metodo dependiente del usuario; el unico
-- pago de la orden se registra en efectivo, como tambien pide el enunciado.
INSERT INTO tb_payments
    (order_ID,user_payment_method_ID,amount,currency,payment_method,provider,provider_reference,idempotency_key,payment_status)
VALUES (@order_id,@method_id,@total,'MXN','Cash','EFECTIVO_SIM_PR04',CONCAT('cash4_',UUID()),
        CONCAT('idem4_',UUID()),'Pending');
SET @payment_id=LAST_INSERT_ID();
CALL sp_authorize_payment(@payment_id);
CALL sp_pr04_attend_order(@order_id);
CALL sp_pr04_deliver_order(@order_id,@address_id);

-- Simular intento fallido en domicilio y retiro posterior por el comprador.
UPDATE tb_shipments SET shipment_status='DeliveryFailed',delivered_date=NULL
WHERE shipment_ID=(SELECT shipment_ID FROM (SELECT s.shipment_ID FROM tb_shipments s WHERE s.seller_order_ID=@seller_order_id) q);
UPDATE tb_shipments
SET carrier='Punto de recoleccion simulado',
    tracking_number=CONCAT('PICKUP4-',@order_id),
    tracking_url='Intento en domicilio fallido; cliente recogio en Punto Centro - Modulo 4',
    shipment_status='Delivered',delivered_date=NOW()
WHERE seller_order_ID=@seller_order_id;

SELECT bo.ID,bo.status_string,bo.total_products,bo.total_cost,p.payment_status,p.payment_method,
       p.provider,m.label AS metodo_registrado,m.last_four,
       s.shipment_status,s.carrier,s.tracking_number,s.tracking_url,s.delivered_date AS fecha_recoleccion
FROM tb_buyer_orders bo JOIN tb_payments p ON p.order_ID=bo.ID
JOIN tbd_user_payment_methods m ON m.ID=p.user_payment_method_ID
JOIN tb_seller_orders so ON so.order_ID=bo.ID JOIN tb_shipments s ON s.seller_order_ID=so.ID
WHERE bo.ID=@order_id;
