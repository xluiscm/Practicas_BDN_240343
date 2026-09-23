-- ==========================================
-- 1. CREACION DE USUARIOS REMOTOS (Total: 7)
-- ==========================================
CREATE USER IF NOT EXISTS 'luis.cazarez'@'%' IDENTIFIED BY '240343';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'aylin.luna'@'%' IDENTIFIED BY '240853';
CREATE USER IF NOT EXISTS 'angel.barrios'@'%' IDENTIFIED BY '240628';
CREATE USER IF NOT EXISTS 'jonhy.neri'@'%' IDENTIFIED BY '240598';
CREATE USER IF NOT EXISTS 'juan.cruz'@'%' IDENTIFIED BY '240148';
CREATE USER IF NOT EXISTS 'carlos.morales'@'%' IDENTIFIED BY '240221';

-- ==========================================
-- 2. ASIGNACION DE PRIVILEGIOS DE SUPERUSUARIO
-- ==========================================
GRANT ALL PRIVILEGES ON *.* TO 'angel.barrios'@'%';

-- ==========================================
-- 3. CREACION DE ROLES PARA ECOMMERCE
-- ==========================================
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'common_user';
CREATE ROLE IF NOT EXISTS 'user_not_registered';
CREATE ROLE IF NOT EXISTS 'support';

-- ==========================================
-- 4. ASIGNACION DE PRIVILEGIOS A LOS ROLES
-- ==========================================
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

-- Privilegios de Support
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';

-- Privilegios de Seller (Gestionar productos)
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';

-- Privilegios de Common User (Solo lectura general)
GRANT SELECT ON db_test.* TO 'common_user';

-- ==========================================
-- 5. ASIGNACION DE ROLES A LOS USUARIOS
-- ==========================================
GRANT 'superadmin' TO 'luis.cazarez'@'%';

-- Marco Ramírez se queda ÚNICAMENTE con el rol de admin
GRANT 'admin' TO 'marco.ramirez'@'%';

GRANT 'support' TO 'angel.barrios'@'%';

-- Los 2 Sellers
GRANT 'seller' TO 'aylin.luna'@'%';
GRANT 'seller' TO 'jonhy.neri'@'%';

-- Los 2 Common Users
GRANT 'common_user' TO 'juan.cruz'@'%';
GRANT 'common_user' TO 'carlos.morales'@'%';

-- ==========================================
-- 6. ACTIVACION AUTOMATICA DE ROLES PARA TODOS LOS USUARIOS
-- ==========================================
SET DEFAULT ROLE ALL TO 
  'luis.cazarez'@'%',
  'marco.ramirez'@'%', 
  'aylin.luna'@'%', 
  'angel.barrios'@'%',
  'jonhy.neri'@'%',
  'juan.cruz'@'%',
  'carlos.morales'@'%';

-- ==========================================
-- 7. REFRESCAR PRIVILEGIOS
-- ==========================================
FLUSH PRIVILEGES;