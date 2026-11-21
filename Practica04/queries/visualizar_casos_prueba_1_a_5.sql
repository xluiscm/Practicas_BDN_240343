-- Consultas de lectura para visualizar los cinco casos en MySQL Workbench.
-- Ejecutar despues de restaurar el respaldo que contiene las pruebas.
-- Las consultas buscan los casos por sus datos; no dependen de IDs fijos.
USE db_test_corregida;

-- Caso 1: compra base pagada con tarjeta y entregada sin cambios.
SELECT bo.ID AS orden, bo.user_ID, bo.status_string AS estado_orden,
       bo.total_products AS unidades, bo.total_cost AS total,
       COUNT(DISTINCT oi.ID) AS productos_distintos,
       p.payment_method, p.payment_status, p.provider,
       m.label AS metodo_guardado, m.last_four,
       so.fulfillment_status AS estado_surtido,
       s.shipment_status AS estado_envio, s.carrier, s.tracking_number
FROM tb_buyer_orders bo
JOIN tb_payments p ON p.order_ID=bo.ID
LEFT JOIN tbd_user_payment_methods m ON m.ID=p.user_payment_method_ID
LEFT JOIN tb_seller_orders so ON so.order_ID=bo.ID
LEFT JOIN tbd_order_items oi ON oi.seller_order_ID=so.ID
LEFT JOIN tb_shipments s ON s.seller_order_ID=so.ID
WHERE p.provider='SIMULADOR_PR04'
  AND bo.status_string='Delivered' AND p.payment_status='Paid'
GROUP BY bo.ID,bo.user_ID,bo.status_string,bo.total_products,bo.total_cost,
         p.payment_method,p.payment_status,p.provider,m.label,m.last_four,
         so.fulfillment_status,s.shipment_status,s.carrier,s.tracking_number
ORDER BY bo.ID;

-- Caso 2: candidato con 10 productos, 6 pagos, 5 autorizaciones y 1 rechazo.
-- Si no devuelve filas, este respaldo no contiene evidencia completa de ese caso.
SELECT x.*
FROM (
    SELECT bo.ID AS orden,bo.user_ID,bo.status_string AS estado_orden,
           bo.total_cost AS total,
           (SELECT COUNT(DISTINCT oi.product_offer_ID)
            FROM tb_seller_orders so JOIN tbd_order_items oi ON oi.seller_order_ID=so.ID
            WHERE so.order_ID=bo.ID) AS productos,
           (SELECT COUNT(*) FROM tb_payments p WHERE p.order_ID=bo.ID) AS pagos,
           (SELECT COUNT(*) FROM tb_payments p
            JOIN tb_payment_transactions t ON t.payment_ID=p.ID
            WHERE p.order_ID=bo.ID AND t.event_type='Authorized') AS autorizaciones,
           (SELECT COUNT(*) FROM tb_payments p
            JOIN tb_payment_transactions t ON t.payment_ID=p.ID
            WHERE p.order_ID=bo.ID AND t.event_type='Failed') AS rechazos,
           (SELECT COUNT(*) FROM tb_returns r WHERE r.order_ID=bo.ID) AS reclamaciones,
           (SELECT COUNT(*) FROM tb_seller_orders so
            JOIN tb_shipments s ON s.seller_order_ID=so.ID
            WHERE so.order_ID=bo.ID) AS envios
    FROM tb_buyer_orders bo
) AS x
WHERE x.productos=10 AND x.pagos=6 AND x.autorizaciones=5 AND x.rechazos=1
  AND x.reclamaciones>=1 AND x.envios>=2;

-- Detalle de pagos y reclamaciones para revisar el Caso 2.
SELECT p.order_ID,p.ID AS pago,p.payment_method,p.amount,p.payment_status,
       t.event_type,t.amount AS monto_evento,t.remarks AS detalle_evento,
       r.return_ID,r.return_reason,r.return_status,r.inspection_notes
FROM tb_payments p
LEFT JOIN tb_payment_transactions t ON t.payment_ID=p.ID
LEFT JOIN tb_returns r ON r.order_ID=p.order_ID
WHERE p.order_ID IN (
    SELECT x.orden
    FROM (
        SELECT bo.ID AS orden,
               (SELECT COUNT(DISTINCT oi.product_offer_ID)
                FROM tb_seller_orders so JOIN tbd_order_items oi ON oi.seller_order_ID=so.ID
                WHERE so.order_ID=bo.ID) AS productos,
               (SELECT COUNT(*) FROM tb_payments px WHERE px.order_ID=bo.ID) AS pagos,
               (SELECT COUNT(*) FROM tb_payments px
                JOIN tb_payment_transactions tx ON tx.payment_ID=px.ID
                WHERE px.order_ID=bo.ID AND tx.event_type='Authorized') AS autorizaciones,
               (SELECT COUNT(*) FROM tb_payments px
                JOIN tb_payment_transactions tx ON tx.payment_ID=px.ID
                WHERE px.order_ID=bo.ID AND tx.event_type='Failed') AS rechazos,
               (SELECT COUNT(*) FROM tb_returns rx WHERE rx.order_ID=bo.ID) AS reclamaciones,
               (SELECT COUNT(*) FROM tb_seller_orders sx
                JOIN tb_shipments sh ON sh.seller_order_ID=sx.ID
                WHERE sx.order_ID=bo.ID) AS envios
        FROM tb_buyer_orders bo
    ) x
    WHERE x.productos=10 AND x.pagos=6 AND x.autorizaciones=5 AND x.rechazos=1
      AND x.reclamaciones>=1 AND x.envios>=2
)
ORDER BY p.order_ID,p.ID,t.ID,r.return_ID;

-- Caso 3: cancelacion parcial, total ajustado, reembolso y entrega del resto.
SELECT bo.ID AS orden,bo.user_ID,bo.status_string AS estado_orden,
       bo.total_products AS unidades_restantes,bo.total_cost AS total_ajustado,
       p.payment_status AS estado_pago,p.payment_method,
       c.cancellation_ID,c.cancellation_status,c.cancellation_reason,
       r.amount AS monto_reembolsado,r.refund_status,
       s.shipment_status AS estado_envio,s.delivery_address_ID
FROM tb_order_cancellations c
JOIN tb_buyer_orders bo ON bo.ID=c.order_ID
LEFT JOIN tb_payments p ON p.order_ID=bo.ID
LEFT JOIN tb_refunds r ON r.cancellation_ID=c.cancellation_ID
LEFT JOIN tb_seller_orders so ON so.order_ID=bo.ID
LEFT JOIN tb_shipments s ON s.seller_order_ID=so.ID
WHERE c.cancellation_reason LIKE 'Cancelacion parcial solicitada%'
ORDER BY bo.ID,c.cancellation_ID;

-- Producto y cantidad cancelados en el Caso 3.
SELECT c.order_ID,c.cancellation_ID,pr.name AS producto,
       ci.quantity AS cantidad_cancelada,c.cancellation_status
FROM tb_order_cancellations c
JOIN tbd_cancellation_items ci ON ci.cancellation_id=c.cancellation_ID
JOIN tbd_users_offer_products o ON o.product_offer_ID=c.product_offer_ID
JOIN tb_products pr ON pr.ID=o.product_ID
WHERE c.cancellation_reason LIKE 'Cancelacion parcial solicitada%'
ORDER BY c.order_ID;

-- Caso 4: método SPEI registrado, pago único en efectivo y retiro en punto.
SELECT bo.ID AS orden,bo.status_string AS estado_orden,
       bo.total_products AS unidades,bo.total_cost AS total,
       p.payment_method,p.provider,p.payment_status,
       m.label AS metodo_registrado,m.last_four,
       s.shipment_status AS estado_envio,s.carrier,
       s.tracking_number,s.tracking_url AS detalle_recoleccion,
       s.delivered_date AS fecha_recoleccion
FROM tb_shipments s
JOIN tb_seller_orders so ON so.ID=s.seller_order_ID
JOIN tb_buyer_orders bo ON bo.ID=so.order_ID
JOIN tb_payments p ON p.order_ID=bo.ID
LEFT JOIN tbd_user_payment_methods m ON m.ID=p.user_payment_method_ID
WHERE s.tracking_number LIKE 'PICKUP4-%'
ORDER BY bo.ID;

-- Caso 5: cancelación por inventario, pago anulado y cupón reactivado.
-- El rechazo exacto de sp_pr04_attend_order aparece en el resultado del script.
SELECT bo.ID AS orden,bo.status_string AS estado_orden,
       bo.total_products AS unidades_solicitadas,bo.total_cost AS total,
       p.payment_status AS estado_pago,p.payment_method,
       t.remarks AS motivo_anulacion,
       m.label AS metodo,IF(m.status=b'1','Activo / reasignado','Inactivo') AS estado_cupon,
       s.shipment_ID AS envio_creado
FROM tb_payments p
JOIN tb_buyer_orders bo ON bo.ID=p.order_ID
LEFT JOIN tbd_user_payment_methods m ON m.ID=p.user_payment_method_ID
LEFT JOIN tb_payment_transactions t ON t.payment_ID=p.ID AND t.event_type='Voided'
LEFT JOIN tb_seller_orders so ON so.order_ID=bo.ID
LEFT JOIN tb_shipments s ON s.seller_order_ID=so.ID
WHERE p.provider='CUPON_SIMULATOR'
ORDER BY bo.ID;

-- Transacciones bancarias y anulaciones de los casos 1 a 5.
SELECT p.order_ID,p.ID AS pago,p.provider,t.event_type,t.amount,
       t.event_reference,t.remarks,t.creation_date
FROM tb_payments p
JOIN tb_payment_transactions t ON t.payment_ID=p.ID
ORDER BY p.order_ID,p.ID,t.ID;
