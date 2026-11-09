# Respaldos de Práctica 03

## Respaldo de referencia

`respaldo_10.sql` es el respaldo principal para generar el diccionario interactivo. El generador lo selecciona automáticamente mientras sea el `.sql` más reciente de esta carpeta. También puedes indicar una ruta de forma explícita al ejecutar el generador.

## Historial

Los respaldos anteriores se organizaron en `historicos/` y se conservan sin eliminarse. Incluyen `db_test_corregida_final.sql`, `07112026.sql`, `081126.sql` y las versiones `respaldo_08.sql` y `respaldo_09.sql`, además de exportaciones previas.

El selector dentro del diccionario puede abrir respaldos de ambas carpetas. Al elegir un archivo, el encabezado calcula las tablas, campos, relaciones, vistas, triggers, procedimientos y filas exportadas; también muestra las filas de `tb_users` y `tb_products`. Los conteos se derivan del contenido SQL elegido y no representan necesariamente el estado vivo de MySQL.
