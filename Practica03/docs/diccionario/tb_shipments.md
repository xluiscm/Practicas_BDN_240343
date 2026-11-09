# `tb_shipments`

**Base declarada en el dump:** `db_test_corregida`. **Columnas:** 11.

Fuente estructural: `backups/historicos/db_test_corregida_final.sql`. [HECHO] El dump no define el significado funcional de cada campo; las interpretaciones se marcan como inferencia.

## `shipment_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | shipment_ID | [HECHO] |
| Tipo SQL completo | bigint unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Longitud/precisión | bigint unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | Sí | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | Sí | [HECHO] |
| Índices | PRIMARY KEY | [HECHO] |
| Restricciones | bigint unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Descripción funcional | Campo shipment_ID perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo shipment_ID perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | bigint unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `seller_order_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | seller_order_ID | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_seller_orders.ID | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_shipments_seller_order; idx_shipment_order | [HECHO] |
| Restricciones | int unsigned NOT NULL | [HECHO] |
| Descripción funcional | Campo seller_order_ID perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo seller_order_ID perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_seller_orders.ID | [HECHO] |
| Reglas de validación | int unsigned NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `carrier`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | carrier | [HECHO] |
| Tipo SQL completo | varchar(100) DEFAULT NULL | [HECHO] |
| Longitud/precisión | varchar(100) | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | varchar(100) DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo carrier perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo carrier perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | varchar(100) DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `tracking_number`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | tracking_number | [HECHO] |
| Tipo SQL completo | varchar(150) DEFAULT NULL | [HECHO] |
| Longitud/precisión | varchar(150) | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | idx_shipment_tracking | [HECHO] |
| Restricciones | varchar(150) DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo tracking_number perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo tracking_number perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | varchar(150) DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `tracking_url`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | tracking_url | [HECHO] |
| Tipo SQL completo | varchar(500) DEFAULT NULL | [HECHO] |
| Longitud/precisión | varchar(500) | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | varchar(500) DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo tracking_url perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo tracking_url perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | varchar(500) DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `shipment_status`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | shipment_status | [HECHO] |
| Tipo SQL completo | enum('Pending','Preparing','Shipped','InTransit','OutForDelivery','Delivered','DeliveryFailed','Lost','Returned') NOT NULL DEFAULT 'Pending' | [HECHO] |
| Longitud/precisión | enum('Pending','Preparing','Shipped','InTransit','OutForDelivery','Delivered','DeliveryFailed','Lost','Returned') | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | 'Pending' | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | enum('Pending','Preparing','Shipped','InTransit','OutForDelivery','Delivered','DeliveryFailed','Lost','Returned') NOT NULL DEFAULT 'Pending' | [HECHO] |
| Descripción funcional | Campo shipment_status perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo shipment_status perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | enum('Pending','Preparing','Shipped','InTransit','OutForDelivery','Delivered','DeliveryFailed','Lost','Returned') NOT NULL DEFAULT 'Pending' | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `shipped_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | shipped_date | [HECHO] |
| Tipo SQL completo | datetime DEFAULT NULL | [HECHO] |
| Longitud/precisión | datetime | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | datetime DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo shipped_date perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo shipped_date perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `estimated_delivery_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | estimated_delivery_date | [HECHO] |
| Tipo SQL completo | datetime DEFAULT NULL | [HECHO] |
| Longitud/precisión | datetime | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | datetime DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo estimated_delivery_date perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo estimated_delivery_date perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `delivered_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | delivered_date | [HECHO] |
| Tipo SQL completo | datetime DEFAULT NULL | [HECHO] |
| Longitud/precisión | datetime | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | datetime DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo delivered_date perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo delivered_date perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `creation_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | creation_date | [HECHO] |
| Tipo SQL completo | datetime NOT NULL DEFAULT CURRENT_TIMESTAMP | [HECHO] |
| Longitud/precisión | datetime | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | CURRENT_TIMESTAMP | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | datetime NOT NULL DEFAULT CURRENT_TIMESTAMP | [HECHO] |
| Descripción funcional | Campo creation_date perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo creation_date perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime NOT NULL DEFAULT CURRENT_TIMESTAMP | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `last_update`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_shipments | [HECHO] |
| Columna | last_update | [HECHO] |
| Tipo SQL completo | datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP | [HECHO] |
| Longitud/precisión | datetime | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP | [HECHO] |
| Descripción funcional | Campo last_update perteneciente a tb_shipments. | [INFERENCIA] |
| Significado semántico | Campo last_update perteneciente a tb_shipments. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |
