# Práctica 03 — Base de datos de comercio electrónico

Esta carpeta reúne los respaldos SQL, documentación del esquema, diccionarios, consultas de verificación y archivos de carga de la práctica. El esquema principal documentado corresponde a **`db_test_corregida`**.

## Respaldo principal

El respaldo recomendado para consultar o restaurar es [`backups/db_test_corregida_final.sql`](backups/db_test_corregida_final.sql). El dump contiene 27 tablas, 223 columnas y 33,346 filas en sentencias `INSERT`. El diccionario registra 31 relaciones de clave foránea. Los conteos de filas describen el contenido del archivo SQL, no necesariamente el estado actual de una instancia MySQL.

El dump selecciona `db_test_corregida` y contiene operaciones de eliminación y creación de objetos. Antes de restaurarlo, confirma el servidor y la base de destino. [`backups/07112026.sql`](backups/07112026.sql) conserva una exportación fechada; [`backups/historicos/`](backups/historicos/) contiene respaldos anteriores. Consulta también [`backups/README.md`](backups/README.md) para las notas sobre esos archivos.

## Diccionario y documentación

- **[Diccionario interactivo](diccionario/diccionario.html):** vista del diagrama ER, tablas, campos, definiciones SQL, claves, índices y relaciones. Permite buscar tablas y campos y muestra los conteos incluidos en el respaldo.
- **[Índice CSV de campos](diccionario/campos.csv):** listado tabular extraído del esquema.
- **[Documentación técnica](docs/DOCUMENTACION_DB_TEST.md):** inventario y análisis del esquema con fichas individuales para las 27 tablas en [`docs/diccionario/`](docs/diccionario/).
- **[Prompt del diccionario](prompt/diccionario.txt):** requisitos utilizados para orientar la documentación.

El [mapa general de Archify](../.archify/db-test-corregida-resumen-20261108/diccionario-esquema.html), si está disponible en el checkout, resume el esquema por áreas. Complementa al diccionario; no reemplaza la consulta de columnas por tabla.

## Módulos del esquema

La clasificación usada en el diccionario agrupa las tablas en estas áreas:

- **Usuarios y direcciones:** usuarios, perfiles, direcciones, componentes de dirección y listas asociadas.
- **Catálogo:** productos, categorías, ofertas y su relación.
- **Compras:** carritos, pedidos, partidas y envíos.
- **Pagos:** tipos de método de pago, métodos asociados a usuarios, pagos y transacciones.
- **Devoluciones:** cancelaciones, devoluciones, partidas y reembolsos.
- **Auditoría:** bitácora en `tb_logs`.

Son agrupaciones de lectura del diccionario; no constituyen esquemas separados en MySQL.

## Consultas

[`queries/consultas_de_verificacion.sql`](queries/consultas_de_verificacion.sql) reúne consultas para inspeccionar tablas, triggers, bitácora, productos, categorías, vistas y procedimientos. Varias consultas usan la base `db_test` y vistas con nombres específicos (`vw_trazabilidad_*`, `vw_total_products_by_category`). Verifica que la base y esos objetos existan antes de ejecutar el archivo; no asumas que corresponden al dump `db_test_corregida_final.sql`.

## Scripts

### Generar el diccionario interactivo

Desde la raíz del proyecto:

```powershell
node Practica03/scripts/generar_diccionario_interactivo.js
```

El generador lee `backups/db_test_corregida_final.sql` y `diccionario/campos.csv`, y escribe `diccionario/diccionario.html`.

### Contar filas de un dump

```powershell
node Practica03/scripts/contar_registros_dump.js Practica03/backups/db_test_corregida_final.sql
```

El resultado muestra el total de filas `INSERT` por tabla en ese archivo.

### Preparar o validar CSV de usuarios y productos

El script [`scripts/preparar_csv_productos_usuarios.py`](scripts/preparar_csv_productos_usuarios.py) crea las plantillas `usuarios.csv` y `productos.csv` en Descargas; no sobrescribe archivos que ya existan. Para indicar otra carpeta:

```powershell
python Practica03/scripts/preparar_csv_productos_usuarios.py --directorio "C:/ruta/a/los/csv"
```

Después de completarlas con 10,000 filas de datos cada una, valida encabezados, campos obligatorios, duplicados y valores:

```powershell
python Practica03/scripts/preparar_csv_productos_usuarios.py --validar --directorio "C:/ruta/a/los/csv"
```

Las plantillas esperan estos encabezados:

- `usuarios.csv`: `email,nick,password,status`
- `productos.csv`: `SKU,name,description,current_price,current_stock,status`

La contraseña de usuarios debe estar en el formato hash esperado por la aplicación. El validador no comprueba que ese formato sea correcto.

### Scripts SQL de importación y permisos

- [`scripts/configurar_importacion_usuarios_csv.sql`](scripts/configurar_importacion_usuarios_csv.sql): define `sp_import_users_csv`; valida 10,000 filas, campos, duplicados y conflictos existentes antes de insertar en `tb_users` y `tb_people`.
- [`scripts/cargar_usuarios_csv.sql`](scripts/cargar_usuarios_csv.sql): carga `usuarios.csv` desde `C:/Users/xidon/Downloads/usuarios.csv` a una tabla temporal y llama al procedimiento.
- [`scripts/autorizar_carga_csv_segundo_vendedor.sql`](scripts/autorizar_carga_csv_segundo_vendedor.sql): concede permisos para ejecutar el procedimiento.
- [`scripts/remote_users_priviliges_creation.sql`](scripts/remote_users_priviliges_creation.sql): define cuentas y roles remotos con privilegios para la práctica.

**Compatibilidad:** esos scripts SQL usan `db_test`, mientras que el respaldo recomendado usa `db_test_corregida`. Además, el cargador de usuarios espera la ruta indicada en el propio archivo. Revisa y ajusta base, ruta, cuenta y permisos al entorno antes de ejecutarlos. El script de usuarios remotos elimina y vuelve a crear cuentas y roles con los nombres que enumera.

## Archivos CSV de `seeds/`

La carpeta conserva únicamente las dos plantillas de trabajo actuales, ambas con encabezados y sin filas de datos:

- `usuarios.csv`: plantilla para el procedimiento de importación de usuarios.
- `productos.csv`: plantilla para preparar productos.

Los juegos de datos anteriores fueron retirados. Para una carga, completa estas plantillas con 10,000 filas y valídalas; los encabezados de cada archivo deben coincidir con el proceso de importación elegido.

## Estructura

```text
Practica03/
├── backups/       Respaldos SQL y archivo de notas
├── diccionario/   HTML interactivo, CSV de campos y recibos de Archify anteriores
├── docs/          Documento técnico y fichas detalladas por tabla
├── prompt/        Instrucciones de generación del diccionario
├── queries/       Consultas SQL de verificación
├── scripts/       Generadores, preparación de CSV e importación
└── seeds/         Plantillas actuales de usuarios y productos
```

## Alcance de los conteos

Los conteos del diccionario se calcularon a partir del DDL y de las filas `INSERT` incluidas en `db_test_corregida_final.sql`. Una tabla puede mostrar cero registros en el respaldo aunque tenga datos en otro servidor o en otro archivo histórico. Para conocer el estado real de una instancia, restaura o consulta esa instancia y ejecuta conteos SQL directamente.
