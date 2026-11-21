# Manual VPS - Bases de Datos NoSQL

## Descripción
Proyecto de despliegue y administración de bases de datos en un VPS Debian mediante Docker Compose.

## Tecnologías
- Debian
- Docker y Docker Compose
- MongoDB 7.0
- Mongo Express
- Node.js
- Apollo Server y GraphQL
- PostgreSQL
- pgAdmin

## Estructura
- docker-compose.yml: configuración de servicios.
- .env.example: ejemplo de variables de entorno.
- init.sql: inicialización de PostgreSQL.
- mongodb/: usuarios, roles, schemas, datos, índices, vistas y pruebas CRUD.
- graphql/: API GraphQL, consultas y mutaciones.

## Despliegue
Configurar las variables de entorno y ejecutar:

    docker compose up -d

Consultar los servicios:

    docker compose ps

Detener los servicios:

    docker compose down

## Persistencia
Para reiniciar los servicios sin eliminar los volúmenes:

    docker compose down
    docker compose up -d

## Seguridad
El archivo .env contiene información sensible y no debe versionarse. Los respaldos y archivos temporales se excluyen mediante .gitignore.
