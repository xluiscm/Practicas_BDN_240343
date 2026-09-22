-- 1. CREACION DE USUARIOS REMOTOS (Solo los del primer archivo)
CREATE USER IF NOT EXISTS 'luis.cazarez'@'%' IDENTIFIED BY '240343';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'aylin.luna'@'%' IDENTIFIED BY '240853';
CREATE USER IF NOT EXISTS 'angel.barrios'@'%' IDENTIFIED BY '240628';
CREATE USER IF NOT EXISTS 'jonhy.neri'@'%' IDENTIFIED BY '240558';
CREATE USER IF NOT EXISTS 'juan.cruz'@'%' IDENTIFIED BY '240148';
CREATE USER IF NOT EXISTS 'carlos.morales'@'%' IDENTIFIED BY '240221';

-- 2. ASIGNACION DIRECTA DE PRIVILEGIOS A USUARIOS
GRANT ALL PRIVILEGES ON *.* TO 'angel.barrios'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'aylin.luna'@'%' WITH GRANT OPTION;

-- 3. CREACION DE ROLES PARA ECOMMERCE
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'common_user';
CREATE ROLE IF NOT EXISTS 'user_not_registered';
CREATE ROLE IF NOT EXISTS 'support';

-- 4. ASIGNACION DE PRIVILEGIOS A LOS ROLES
/* Superadmin: Todos los privilegios en todas las bases de datos */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';

/* Admin: Todos los privilegios en la base de datos db_test */
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

/* Support: Privilegios limitados para soporte */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';

/* Seller: Privilegios para gestionar productos */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';

/* Common_user / Buyer: Lectura general */
GRANT SELECT ON db_test.* TO 'common_user';

-- 5. ASIGNACION DE ROLES A LOS USUARIOS
GRANT 'superadmin' TO 'luis.cazarez'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'seller' TO 'aylin.luna'@'%';
GRANT 'seller' TO 'jonhy.neri'@'%';
GRANT 'support' TO 'angel.barrios'@'%';
GRANT 'common_user' TO 'juan.cruz'@'%';
GRANT 'common_user' TO 'carlos.morales'@'%';

-- 6. ACTIVACION AUTOMATICA DE ROLES (SET DEFAULT ROLE)
SET DEFAULT ROLE 'superadmin' TO 'luis.cazarez'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'seller' TO 'aylin.luna'@'%', 'jonhy.neri'@'%';
SET DEFAULT ROLE 'support' TO 'angel.barrios'@'%';
SET DEFAULT ROLE 'common_user' TO 'juan.cruz'@'%', 'carlos.morales'@'%';

-- 7. REFRESCAR PRIVILEGIOS Y MENSAJE DE CONFIRMACION
FLUSH PRIVILEGES;

SELECT "Los usuarios y privilegios han sido creados correctamente" AS mensaje;