# `tb_seller_orders`

**Base declarada en el dump:** `db_test_corregida`. **Columnas:** 8.

Fuente estructural: `backups/historicos/db_test_corregida_final.sql`. [HECHO] El dump no define el significado funcional de cada campo; las interpretaciones se marcan como inferencia.

## `ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_seller_orders | [HECHO] |
| Columna | ID | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | Sí | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | Sí | [HECHO] |
| Índices | PRIMARY KEY | [HECHO] |
| Restricciones | int unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Descripción funcional | Campo ID perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo ID perteneciente a tb_seller_orders. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | int unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `order_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_seller_orders | [HECHO] |
| Columna | order_ID | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_buyer_orders.ID | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_seller_order_order; uk_order_seller | [HECHO] |
| Restricciones | int unsigned NOT NULL | [HECHO] |
| Descripción funcional | Campo order_ID perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo order_ID perteneciente a tb_seller_orders. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_buyer_orders.ID | [HECHO] |
| Reglas de validación | int unsigned NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `seller_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_seller_orders | [HECHO] |
| Columna | seller_ID | [HECHO] |
| Tipo SQL completo | int NOT NULL | [HECHO] |
| Longitud/precisión | int | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_users.ID | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_seller_order_seller; idx_seller_orders_seller | [HECHO] |
| Restricciones | int NOT NULL | [HECHO] |
| Descripción funcional | Campo seller_ID perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo seller_ID perteneciente a tb_seller_orders. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_users.ID | [HECHO] |
| Reglas de validación | int NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `subtotal`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_seller_orders | [HECHO] |
| Columna | subtotal | [HECHO] |
| Tipo SQL completo | decimal(12,2) NOT NULL DEFAULT '0.00' | [HECHO] |
| Longitud/precisión | decimal(12,2) | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | '0.00' | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | decimal(12,2) NOT NULL DEFAULT '0.00' | [HECHO] |
| Descripción funcional | Campo subtotal perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo subtotal perteneciente a tb_seller_orders. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | decimal(12,2) NOT NULL DEFAULT '0.00' | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `shipping_cost`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_seller_orders | [HECHO] |
| Columna | shipping_cost | [HECHO] |
| Tipo SQL completo | decimal(12,2) NOT NULL DEFAULT '0.00' | [HECHO] |
| Longitud/precisión | decimal(12,2) | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | '0.00' | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | decimal(12,2) NOT NULL DEFAULT '0.00' | [HECHO] |
| Descripción funcional | Campo shipping_cost perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo shipping_cost perteneciente a tb_seller_orders. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | decimal(12,2) NOT NULL DEFAULT '0.00' | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `fulfillment_status`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_seller_orders | [HECHO] |
| Columna | fulfillment_status | [HECHO] |
| Tipo SQL completo | enum('Pending','Accepted','Preparing','Sent','Delivered','Canceled','Returned') NOT NULL DEFAULT 'Pending' | [HECHO] |
| Longitud/precisión | enum('Pending','Accepted','Preparing','Sent','Delivered','Canceled','Returned') | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | 'Pending' | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | enum('Pending','Accepted','Preparing','Sent','Delivered','Canceled','Returned') NOT NULL DEFAULT 'Pending' | [HECHO] |
| Descripción funcional | Campo fulfillment_status perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo fulfillment_status perteneciente a tb_seller_orders. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | enum('Pending','Accepted','Preparing','Sent','Delivered','Canceled','Returned') NOT NULL DEFAULT 'Pending' | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `creation_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_seller_orders | [HECHO] |
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
| Descripción funcional | Campo creation_date perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo creation_date perteneciente a tb_seller_orders. | [INFERENCIA] |
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
| Tabla | tb_seller_orders | [HECHO] |
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
| Descripción funcional | Campo last_update perteneciente a tb_seller_orders. | [INFERENCIA] |
| Significado semántico | Campo last_update perteneciente a tb_seller_orders. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |
