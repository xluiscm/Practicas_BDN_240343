# `tb_payment_transactions`

**Base declarada en el dump:** `db_test_corregida`. **Columnas:** 7.

Fuente estructural: `backups/historicos/db_test_corregida_final.sql`. [HECHO] El dump no define el significado funcional de cada campo; las interpretaciones se marcan como inferencia.

## `ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_payment_transactions | [HECHO] |
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
| Descripción funcional | Campo ID perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Significado semántico | Campo ID perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | int unsigned NOT NULL AUTO_INCREMENT | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `payment_ID`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_payment_transactions | [HECHO] |
| Columna | payment_ID | [HECHO] |
| Tipo SQL completo | int unsigned NOT NULL | [HECHO] |
| Longitud/precisión | int unsigned | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | Sí | [HECHO] |
| Tabla/columna referenciada | tb_payments.ID | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | FK fk_payment_transaction_payment; idx_payment_transactions_payment | [HECHO] |
| Restricciones | int unsigned NOT NULL | [HECHO] |
| Descripción funcional | Campo payment_ID perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Significado semántico | Campo payment_ID perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | tb_payments.ID | [HECHO] |
| Reglas de validación | int unsigned NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `event_type`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_payment_transactions | [HECHO] |
| Columna | event_type | [HECHO] |
| Tipo SQL completo | enum('Created','Authorized','Captured','Failed','Refunded','PartiallyRefunded','Voided') NOT NULL | [HECHO] |
| Longitud/precisión | enum('Created','Authorized','Captured','Failed','Refunded','PartiallyRefunded','Voided') | [HECHO] |
| Permite NULL | No | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | enum('Created','Authorized','Captured','Failed','Refunded','PartiallyRefunded','Voided') NOT NULL | [HECHO] |
| Descripción funcional | Campo event_type perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Significado semántico | Campo event_type perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | enum('Created','Authorized','Captured','Failed','Refunded','PartiallyRefunded','Voided') NOT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `amount`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_payment_transactions | [HECHO] |
| Columna | amount | [HECHO] |
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
| Descripción funcional | Campo amount perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Significado semántico | Campo amount perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Naturaleza del dato | Numérica/booleana | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | decimal(12,2) NOT NULL DEFAULT '0.00' | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `event_reference`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_payment_transactions | [HECHO] |
| Columna | event_reference | [HECHO] |
| Tipo SQL completo | varchar(150) DEFAULT NULL | [HECHO] |
| Longitud/precisión | varchar(150) | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | NULL | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices | uk_payment_event_reference | [HECHO] |
| Restricciones | varchar(150) DEFAULT NULL | [HECHO] |
| Descripción funcional | Campo event_reference perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Significado semántico | Campo event_reference perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | varchar(150) DEFAULT NULL | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `remarks`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_payment_transactions | [HECHO] |
| Columna | remarks | [HECHO] |
| Tipo SQL completo | text | [HECHO] |
| Longitud/precisión | text | [HECHO] |
| Permite NULL | Sí | [HECHO] |
| Es PK | No | [HECHO] |
| Es FK | No | [HECHO] |
| Tabla/columna referenciada | No aplica | [HECHO] |
| DEFAULT | — | [HECHO] |
| Auto Increment | No | [HECHO] |
| Índices |  | [HECHO] |
| Restricciones | text | [HECHO] |
| Descripción funcional | Campo remarks perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Significado semántico | Campo remarks perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Naturaleza del dato | Texto/categórica | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | text | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |

## `creation_date`

| Atributo | Valor | Clasificación |
|---|---|---|
| Base de datos | db_test_corregida | [HECHO] |
| Tabla | tb_payment_transactions | [HECHO] |
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
| Descripción funcional | Campo creation_date perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Significado semántico | Campo creation_date perteneciente a tb_payment_transactions. | [INFERENCIA] |
| Naturaleza del dato | Temporal | [INFERENCIA del tipo] |
| Uso en negocio | Uso de aplicación no especificado en el dump. | [HIPÓTESIS] |
| Dependencias | No aplica | [HECHO] |
| Reglas de validación | datetime NOT NULL DEFAULT CURRENT_TIMESTAMP | [HECHO] |
| Ejemplo representativo | Omitido en esta ficha; no se atribuyen valores de ejemplo. | [NO INFERIDO] |
| Riesgos de integridad | Las reglas de negocio adicionales requieren validar la aplicación. | [INFERENCIA] |
| Origen | DDL para estructura; inferencia para semántica. | [HECHO/INFERENCIA] |
