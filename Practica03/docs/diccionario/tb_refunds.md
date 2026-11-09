# `tb_refunds`

**Base declarada en el dump:** `db_test_corregida`. **Columnas:** 13.

Fuente estructural: `backups/historicos/db_test_corregida_final.sql`. [HECHO] El dump no define el significado funcional de cada campo; las interpretaciones se marcan como inferencia.

## `refund_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | refund_ID | [HECHO] |
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
| Descripción funcional | Campo refund_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo refund_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | bigint unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `payment_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | payment_ID | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_payments.ID | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_refund_payment; idx_refund_payment | [HECHO] |
| Restricciones | int unsigned NOT NULL | [HECHO] |
| Descripción funcional | Campo payment_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo payment_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_payments.ID | [HECHO] |
| Reglas de validación | int unsigned NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `cancellation_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | cancellation_ID | [HECHO] |
| Tipo SQL completo | bigint unsigned DEFAULT NULL | [HECHO] |
| Longitud/precisión | bigint unsigned | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_order_cancellations.cancellation_ID | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_refund_cancellation; fk_refund_cancellation | [HECHO] |
| Restricciones | bigint unsigned DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo cancellation_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo cancellation_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_order_cancellations.cancellation_ID | [HECHO] |
| Reglas de validación | bigint unsigned DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `return_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | return_ID | [HECHO] |
| Tipo SQL completo | bigint unsigned DEFAULT NULL | [HECHO] |
| Longitud/precisión | bigint unsigned | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_returns.return_ID | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_refund_return; fk_refund_return | [HECHO] |
| Restricciones | bigint unsigned DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo return_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo return_ID perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_returns.return_ID | [HECHO] |
| Reglas de validación | bigint unsigned DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `amount`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | amount | [HECHO] |
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
| Descripción funcional | Campo amount perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo amount perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | decimal(12,2) NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `currency`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | currency | [HECHO] |
| Tipo SQL completo | char(3) NOT NULL DEFAULT 'MXN' | [HECHO] |
| Longitud/precisión | char(3) | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | 'MXN' | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | char(3) NOT NULL DEFAULT 'MXN' | [HECHO] |
| Descripción funcional | Campo currency perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo currency perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | char(3) NOT NULL DEFAULT 'MXN' | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `refund_reason`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | refund_reason | [HECHO] |
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
| Descripción funcional | Campo refund_reason perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo refund_reason perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | varchar(500) DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `refund_status`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | refund_status | [HECHO] |
| Tipo SQL completo | enum('Requested','Approved','Processing','Completed','Failed','Rejected') NOT NULL DEFAULT 'Requested' | [HECHO] |
| Longitud/precisión | enum('Requested','Approved','Processing','Completed','Failed','Rejected') | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | 'Requested' | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | idx_refund_status | [HECHO] |
| Restricciones | enum('Requested','Approved','Processing','Completed','Failed','Rejected') NOT NULL DEFAULT 'Requested' | [HECHO] |
| Descripción funcional | Campo refund_status perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo refund_status perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | enum('Requested','Approved','Processing','Completed','Failed','Rejected') NOT NULL DEFAULT 'Requested' | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `provider_reference`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | provider_reference | [HECHO] |
| Tipo SQL completo | varchar(150) DEFAULT NULL | [HECHO] |
| Longitud/precisión | varchar(150) | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | uk_refund_provider_reference | [HECHO] |
| Restricciones | varchar(150) DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo provider_reference perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo provider_reference perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | varchar(150) DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `requested_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | requested_date | [HECHO] |
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
| Descripción funcional | Campo requested_date perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo requested_date perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime NOT NULL DEFAULT CURRENT_TIMESTAMP | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `completed_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_refunds | [HECHO] |
| Columna | completed_date | [HECHO] |
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
| Descripción funcional | Campo completed_date perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo completed_date perteneciente a tb_refunds. | [INFERENCIA] |
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
| Tabla | tb_refunds | [HECHO] |
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
| Descripción funcional | Campo creation_date perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo creation_date perteneciente a tb_refunds. | [INFERENCIA] |
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
| Tabla | tb_refunds | [HECHO] |
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
| Descripción funcional | Campo last_update perteneciente a tb_refunds. | [INFERENCIA] |
| Significado semántico | Campo last_update perteneciente a tb_refunds. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |
