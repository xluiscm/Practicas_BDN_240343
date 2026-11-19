# Bases de Datos en la Nube

**Asignatura:** Optativa I: Bases de Datos en la Nube  
**Programa:** Ingeniería en Tecnologías de la Información e Innovación Digital  
**Docente:** M.T.I. Marco A. Ramírez Hernández  
**Periodo:** septiembre–diciembre de 2026

## Diccionarios interactivos

### Diccionario interactivo de Práctica 03

**[Abrir el diccionario de datos y diagrama ER](https://xluiscm.github.io/Practicas_BDN_240343/diccionario/diccionario.html)**

### Diccionario interactivo de Práctica 04

**[Abrir el diccionario de datos y diagrama ER](https://xluiscm.github.io/Practicas_BDN_240343/practica04/diccionario.html)**

En ambos diccionarios puedes navegar el diagrama ER y consultar tablas y campos. El de Práctica 04 también permite cargar otro archivo `.sql` con **Seleccionar respaldo SQL**; se analiza localmente en el navegador y no se envía a un servidor. Su respaldo de referencia documenta 27 tablas, 225 campos y 33 claves foráneas.

## Ponderación y estado

| ID | Práctica | Nombre | Ponderación | Estado | Material |
|---:|---|---|---:|---|---|
| 1 | Práctica 02 | Conexión remota en MySQL | 42 | Concluida | [Archivos](Practica02/) |
| 2 | Práctica 02 | Conexiones remotas para bases de datos SQL: usuarios y privilegios | 60 | Concluida | [Archivos](Practica02/) |
| 3 | Práctica 03 | Manipulación de datos en conexiones remotas | 100 | Concluida | [README](Practica03/README.md) |
| 4 | Práctica 04 | Simulación de compra, cancelaciones, reembolsos y entrega | — | Concluida | [README](Practica04/README.md) · [Consultas](Practica04/queries/visualizar_casos_prueba_1_a_5.sql) |

Cada carpeta de práctica conserva sus respaldos, scripts SQL, consultas y documentación.

## GitHub Pages

El sitio publica las vistas HTML desde `docs/`, en la rama `master`. El índice del sitio está en [GitHub Pages](https://xluiscm.github.io/Practicas_BDN_240343/). Para regenerar el diccionario interactivo de Práctica 04 desde la raíz del repositorio:

```powershell
node Practica04/scripts/generar_diccionario_interactivo.js
```

El generador actualiza `Practica04/diccionario/` y `docs/practica04/`. La configuración de Pages debe usar **Deploy from a branch**, rama `master` y carpeta `/docs`.
