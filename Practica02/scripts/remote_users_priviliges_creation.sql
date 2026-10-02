-- ==========================================
-- 1. CREACION DE USUARIOS REMOTOS
-- ==========================================
CREATE USER IF NOT EXISTS 'luis.cazarez'@'%' IDENTIFIED BY '240343';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'aylin.luna'@'%' IDENTIFIED BY '240853';
CREATE USER IF NOT EXISTS 'angel.barrios'@'%' IDENTIFIED BY '240196';
CREATE USER IF NOT EXISTS 'jonhy.neri'@'%' IDENTIFIED BY '240558';
CREATE USER IF NOT EXISTS 'juan.cruz'@'%' IDENTIFIED BY '240148';
CREATE USER IF NOT EXISTS 'carlos.morales'@'%' IDENTIFIED BY '240221';

-- ==========================================
-- 2. CREACION DE ROLES PARA ECOMMERCE
-- ==========================================
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'common_user';
CREATE ROLE IF NOT EXISTS 'user_not_registered';
CREATE ROLE IF NOT EXISTS 'support';

-- ==========================================
-- 3. ASIGNACION DE PRIVILEGIOS A LOS ROLES
-- ==========================================
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

-- Privilegios de Support (Incluye lectura a mysql.role_edges para auditoría)
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';
GRANT SELECT ON mysql.role_edges TO 'support'; 

-- Privilegios de Seller (Gestionar productos)
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';

-- Privilegios de Common User (Solo lectura general)
GRANT SELECT ON db_test.* TO 'common_user';

-- ==========================================
-- 4. ASIGNACION DE ROLES A LOS USUARIOS
-- ==========================================
GRANT 'superadmin' TO 'luis.cazarez'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'angel.barrios'@'%'; -- Corregido: ya no tiene ALL PRIVILEGES directos
GRANT 'seller' TO 'aylin.luna'@'%';
GRANT 'seller' TO 'jonhy.neri'@'%';
GRANT 'common_user' TO 'juan.cruz'@'%';
GRANT 'common_user' TO 'carlos.morales'@'%';

-- ==========================================
-- 5. ACTIVACION AUTOMATICA DE ROLES
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
-- 6. REFRESCAR PRIVILEGIOS
-- ==========================================
FLUSH PRIVILEGES;