# Bases de Datos en la Nube

**Asignatura:** Optativa I: Bases de Datos en la Nube  
**Programa:** Ingeniería en Tecnologías de la Información e Innovación Digital  
**Docente:** M.T.I. Marco A. Ramírez Hernández  
**Periodo:** septiembre–diciembre de 2026

## Diccionario interactivo de Práctica 04

**[Abrir el diccionario de datos y diagrama ER](https://xluiscm.github.io/Practicas_BDN_240343/practica04/diccionario.html)**

El enlace abre directamente el explorador de la base `db_test_corregida`. La vista inicial muestra el diagrama ER navegable; usa **Tablas y campos** para consultar columnas, y **Seleccionar respaldo SQL** para cargar otro archivo `.sql`. El archivo seleccionado se analiza localmente en el navegador y no se envía a un servidor.

El diccionario se genera desde `Practica04/backups/respaldo_5casostotalesfinal.sql` y documenta 27 tablas, 225 campos y 33 claves foráneas. Consulta también las [relaciones entre tablas](https://xluiscm.github.io/Practicas_BDN_240343/practica04/relaciones.html) y el [diagrama ERE](https://xluiscm.github.io/Practicas_BDN_240343/practica04/diagrama_ere.html).

## Ponderación y estado

| ID | Práctica | Nombre | Ponderación | Estado | Material |
|---:|---|---|---:|---|---|
| 1 | Práctica 02 | Conexión remota en MySQL | 42 | Concluida | [Archivos](Practica02/) |
| 2 | Práctica 02 | Conexiones remotas para bases de datos SQL: usuarios y privilegios | 60 | Concluida | [Archivos](Practica02/) |
| 3 | Práctica 03 | Manipulación de datos en conexiones remotas | 100 | Concluida | [README](Practica03/README.md) · [Diccionario](https://xluiscm.github.io/Practicas_BDN_240343/diccionario/diccionario.html) |
| 4 | Práctica 04 | Simulación de compra, cancelaciones, reembolsos y entrega | — | Concluida | [README](Practica04/README.md) · [Consultas](Practica04/queries/visualizar_casos_prueba_1_a_5.sql) |

Cada carpeta de práctica conserva sus respaldos, scripts SQL, consultas y documentación.

## GitHub Pages

El sitio publica las vistas HTML desde `docs/`, en la rama `master`. El índice del sitio está en [GitHub Pages](https://xluiscm.github.io/Practicas_BDN_240343/). Para regenerar el diccionario interactivo de Práctica 04 desde la raíz del repositorio:

```powershell
node Practica04/scripts/generar_diccionario_interactivo.js
```

El generador actualiza `Practica04/diccionario/` y `docs/practica04/`. La configuración de Pages debe usar **Deploy from a branch**, rama `master` y carpeta `/docs`.
