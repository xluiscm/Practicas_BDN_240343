-- 1. CREACION DE USUARIOS REMOTOS
CREATE USER IF NOT EXISTS 'luis.cazarez'@'%' IDENTIFIED BY '240343';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'aylin.luna'@'%' IDENTIFIED BY '240853';
CREATE USER IF NOT EXISTS 'angel.barrios'@'%' IDENTIFIED BY '240628';
CREATE USER IF NOT EXISTS 'jonhy.neri'@'%' IDENTIFIED BY '240598';
CREATE USER IF NOT EXISTS 'juan.cruz'@'%' IDENTIFIED BY '240148';
CREATE USER IF NOT EXISTS 'carlos.morales'@'%' IDENTIFIED BY '240221';

-- 2. ASIGNACION DE PRIVILEGIOS DE SUPERUSUARIO
GRANT ALL PRIVILEGES ON *.* TO 'angel.barrios'@'%';

-- 3. CREACION DE ROLES PARA ECOMMERCE
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'common_user';
CREATE ROLE IF NOT EXISTS 'user_not_registered';
CREATE ROLE IF NOT EXISTS 'support';

/* Asignacion de privilegios a los roles */

/* Superadmin: Todos los privilegios en todas las bases de datos */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';

/* Admin: Todos los privilegios en la base de datos db_test */
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

/* Support: Privilegios limitados para soporte */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';

/* Seller: Privilegios para gestionar productos y pedidos */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';

-- Role: support
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';

-- Role: common_user / buyer (Ejemplo de lectura)
GRANT SELECT ON db_test.* TO 'common_user';

-- 5. ASIGNACION DE ROLES A LOS USUARIOS
GRANT 'superadmin' TO 'luis.cazarez'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'seller' TO 'aylin.luna'@'%';
GRANT 'support' TO 'angel.barrios'@'%';
GRANT 'common_user' TO 'jonhy.neri'@'%';
GRANT 'common_user' TO 'juan.cruz'@'%';
GRANT 'common_user' TO 'carlos.morales'@'%';

-- 6. ACTIVACION AUTOMATICA DE ROLES PARA TODOS LOS USUARIOS (CRITICO)
SET DEFAULT ROLE ALL TO 
  'marco.ramirez'@'%', 
  'aylin.luna'@'%', 
  'angel.barrios'@'%',
  'jonhy.neri'@'%';

-- 7. REFRESCAR PRIVILEGIOS
FLUSH PRIVILEGES;