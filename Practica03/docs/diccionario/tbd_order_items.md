# `tbd_order_items`

**Base declarada en el dump:** `db_test_corregida`. **Columnas:** 8.

Fuente estructural: `backups/historicos/db_test_corregida_final.sql`. [HECHO] El dump no define el significado funcional de cada campo; las interpretaciones se marcan como inferencia.

## `ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
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
| Descripción funcional | Campo ID perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo ID perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | int unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `seller_order_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
| Columna | seller_order_ID | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_seller_orders.ID | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_order_item_seller_order; idx_order_items_seller_order | [HECHO] |
| Restricciones | int unsigned NOT NULL | [HECHO] |
| Descripción funcional | Campo seller_order_ID perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo seller_order_ID perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_seller_orders.ID | [HECHO] |
| Reglas de validación | int unsigned NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `product_offer_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
| Columna | product_offer_ID | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tbd_users_offer_products.product_offer_ID | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_order_item_offer; idx_order_items_offer | [HECHO] |
| Restricciones | int unsigned NOT NULL | [HECHO] |
| Descripción funcional | Campo product_offer_ID perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo product_offer_ID perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tbd_users_offer_products.product_offer_ID | [HECHO] |
| Reglas de validación | int unsigned NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `product_name`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
| Columna | product_name | [HECHO] |
| Tipo SQL completo | varchar(250) NOT NULL | [HECHO] |
| Longitud/precisión | varchar(250) | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | varchar(250) NOT NULL | [HECHO] |
| Descripción funcional | Campo product_name perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo product_name perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | varchar(250) NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `quantity`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
| Columna | quantity | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | int unsigned NOT NULL | [HECHO] |
| Descripción funcional | Campo quantity perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo quantity perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | int unsigned NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `unit_price`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
| Columna | unit_price | [HECHO] |
| Tipo SQL completo | decimal(12,2) NOT NULL | [HECHO] |
| Longitud/precisión | decimal(12,2) | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | decimal(12,2) NOT NULL | [HECHO] |
| Descripción funcional | Campo unit_price perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo unit_price perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | decimal(12,2) NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `subtotal`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
| Columna | subtotal | [HECHO] |
| Tipo SQL completo | decimal(14,2) GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED | [HECHO] |
| Longitud/precisión | decimal(14,2) | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | decimal(14,2) GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED | [HECHO] |
| Descripción funcional | Campo subtotal perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo subtotal perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | decimal(14,2) GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `creation_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tbd_order_items | [HECHO] |
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
| Descripción funcional | Campo creation_date perteneciente a tbd_order_items. | [INFERENCIA] |
| Significado semántico | Campo creation_date perteneciente a tbd_order_items. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime NOT NULL DEFAULT CURRENT_TIMESTAMP | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |
