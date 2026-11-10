# Práctica 03: base de datos de comercio electrónico

Esta práctica documenta y explora la base MySQL `db_test_corregida`. Incluye respaldos SQL, un diccionario interactivo generado desde un respaldo, documentación de tablas, consultas de revisión y archivos de apoyo para importar usuarios y productos.

## Diccionario interactivo

[Abrir el diccionario interactivo](diccionario/diccionario.html). Incluye:

- Diagrama entidad-relación con tablas agrupadas por módulo y relaciones FK.
- Búsqueda y filtros por módulo, tabla y campo.
- Detalle de columnas, tipos SQL, claves, índices, valores por defecto y relaciones.
- Selector para cargar cualquier respaldo `.sql` localmente; al elegirlo, actualiza sus conteos, diagrama y detalles. El archivo permanece en el navegador y no se envía a un servidor.

### Regenerar el diccionario

Desde la raíz del repositorio, elige automáticamente el respaldo `.sql` modificado más recientemente dentro de `Practica03/backups/`:

```powershell
node Practica03/scripts/generar_diccionario_interactivo.js
```

Para generar a partir de un respaldo concreto:

```powershell
node Practica03/scripts/generar_diccionario_interactivo.js Practica03/backups/respaldo_10.sql
```

El generador lee el DDL y las sentencias `INSERT` de ese archivo. Actualiza `diccionario/campos.csv` y `diccionario/diccionario.html`; `diccionario/backup-picker.js` implementa la lectura local de respaldos elegidos desde el navegador y debe permanecer junto al HTML. No se necesita instalar dependencias externas.

El conteo de registros representa las filas `INSERT` incluidas en el dump, no un conteo en vivo del servidor.

## Contenido

- [`backups/`](backups/): exportaciones SQL. [`backups/README.md`](backups/README.md) describe algunos respaldos; los archivos antiguos se conservan en `backups/historicos/`.
- [`diccionario/`](diccionario/): HTML interactivo, su lector de respaldos y el CSV de campos generado.
- [`docs/DOCUMENTACION_DB_TEST.md`](docs/DOCUMENTACION_DB_TEST.md): inventario y análisis del esquema, con fichas en [`docs/diccionario/`](docs/diccionario/).
- [`prompt/diccionario.txt`](prompt/diccionario.txt): instrucciones vigentes para generar o revisar la documentación.
- [`queries/consultas_de_verificacion.sql`](queries/consultas_de_verificacion.sql): consultas SQL auxiliares. Revisa en el propio archivo la base y los objetos requeridos antes de ejecutarlas.
- [`scripts/`](scripts/): generación del diccionario, verificación de dumps y apoyo para CSV, permisos e importaciones.
- [`seeds/`](seeds/): CSV de usuarios y productos, incluidas las entregas parciales de productos. Conserva los encabezados esperados por el proceso de carga.

Las fichas Markdown documentan el DDL del respaldo histórico `backups/historicos/db_test_corregida_final.sql`. El HTML interactivo se genera desde `backups/respaldo_10.sql` y permite cargar cualquier otro dump para consultar su propio esquema y conteos.

## Importación de CSV

Los encabezados actuales son:

- `usuarios.csv`: `email,nick,password,status`
- `productos.csv`: `SKU,name,description,current_price,current_stock,status`

Los scripts SQL de importación y privilegios son ejemplos de la práctica y deben ejecutarse en el orden descrito en sus comentarios. Confirma siempre la base, usuario y ruta local del CSV antes de ejecutar una carga. Para revisar el contenido de una exportación, usa:

```powershell
node Practica03/scripts/contar_registros_dump.js Practica03/backups/respaldo_10.sql
```

## Organización y conservación

Se conservaron los respaldos, los archivos CSV de la práctica y los scripts SQL porque sirven como fuentes, historial o insumos de importación. `campos.csv` y `diccionario.html` son productos generados y se regeneran con el comando anterior.

