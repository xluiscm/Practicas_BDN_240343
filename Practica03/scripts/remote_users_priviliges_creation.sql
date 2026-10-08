-- 0. LIMPIEZA PREVIA (Evita advertencias si ya existen usuarios o roles)
DROP USER IF EXISTS 
    'luis.cazarez'@'%', 
    'marco.ramirez'@'%', 
    'aylin.luna'@'%', 
    'saul.barrios'@'%', 
    'jonhy.neri'@'%', 
    'juan.cruz'@'%', 
    'carlos.morales'@'%';

DROP ROLE IF EXISTS 
    'superadmin', 
    'admin', 
    'seller', 
    'buyer', 
    'common_user', 
    'user_not_registered', 
    'support';


-- 1. CREACION DE USUARIOS REMOTOS
CREATE USER 'luis.cazarez'@'%' IDENTIFIED BY '240343'; -- super admin
CREATE USER 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123'; -- Profe
CREATE USER 'aylin.luna'@'%' IDENTIFIED BY '240853'; -- primer vendedor
CREATE USER 'saul.barrios'@'%' IDENTIFIED BY '240196'; -- support
CREATE USER 'jonhy.neri'@'%' IDENTIFIED BY '240558'; -- segundo vendedor
CREATE USER 'juan.cruz'@'%' IDENTIFIED BY '240148'; -- usuario
CREATE USER 'carlos.morales'@'%' IDENTIFIED BY '240221'; -- usuario


-- 2. CREACION DE ROLES PARA ECOMMERCE
CREATE ROLE 'superadmin';
CREATE ROLE 'admin';
CREATE ROLE 'seller';
CREATE ROLE 'buyer';
CREATE ROLE 'common_user';
CREATE ROLE 'user_not_registered';
CREATE ROLE 'support';


-- 3. ASIGNACION DE PRIVILEGIOS A LOS ROLES

-- SUPERADMIN
GRANT ALL PRIVILEGES ON *.* 
TO 'superadmin' 
WITH GRANT OPTION;

-- ADMIN
GRANT ALL PRIVILEGES ON db_test.* 
TO 'admin';

-- SUPPORT
-- Puede visualizar todas las tablas
GRANT SELECT ON db_test.* 
TO 'support';

-- Puede insertar y actualizar usuarios
GRANT SELECT, INSERT, UPDATE 
ON db_test.tb_users 
TO 'support';

-- Puede insertar y actualizar categorías
GRANT SELECT, INSERT, UPDATE 
ON db_test.tbc_categories 
TO 'support';

GRANT SELECT, UPDATE
ON db_test.tb_products
TO 'support';

-- Puede insertar y actualizar relaciones producto-categoría
GRANT SELECT, INSERT, UPDATE 
ON db_test.tbd_products_categories 
TO 'support';

-- Puede consultar los logs para auditoría
GRANT SELECT 
ON db_test.tb_logs 
TO 'support';

-- Puede consultar los roles para auditoría
GRANT SELECT 
ON mysql.role_edges 
TO 'support';

-- Corregido para aplicarse directamente al rol 'support'
GRANT EXECUTE 
ON PROCEDURE db_test.sp_soft_delete_user
TO 'support';

-- SELLER (Se agregó INSERT y UPDATE a tbc_categories para permitir carga de datos)
GRANT SELECT, INSERT, UPDATE 
ON db_test.tb_products 
TO 'seller';

GRANT SELECT, INSERT, UPDATE 
ON db_test.tbc_categories 
TO 'seller';


-- COMMON USER
GRANT SELECT 
ON db_test.* 
TO 'common_user';


-- 4. ASIGNACION DE ROLES A LOS USUARIOS
GRANT 'superadmin' TO 'luis.cazarez'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'saul.barrios'@'%';
GRANT 'seller' TO 'aylin.luna'@'%';
GRANT 'seller' TO 'jonhy.neri'@'%';
GRANT 'common_user' TO 'juan.cruz'@'%';
GRANT 'common_user' TO 'carlos.morales'@'%';


-- 5. ACTIVACION AUTOMATICA DE ROLES PARA TODOS LOS USUARIOS
SET DEFAULT ROLE ALL TO 
    'luis.cazarez'@'%',
    'marco.ramirez'@'%', 
    'aylin.luna'@'%', 
    'saul.barrios'@'%',
    'jonhy.neri'@'%',
    'juan.cruz'@'%',
    'carlos.morales'@'%';


-- 6. REFRESCAR PRIVILEGIOS
FLUSH PRIVILEGES;


-- MENSAJE DE CONFIRMACION
SELECT "Los usuarios y privilegios han sido creados correctamente" AS mensaje;