-- Ejecutar conectado a MySQL como jonhy.neri.
-- Requiere LOCAL INFILE habilitado en Workbench/cliente.
USE `db_test_corregida`;
SET NAMES utf8mb4;

DROP TEMPORARY TABLE IF EXISTS `tmp_users_csv`;
CREATE TEMPORARY TABLE `tmp_users_csv` (
    `email` VARCHAR(100) NOT NULL,
    `nick` VARCHAR(50) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `status` CHAR(1) NOT NULL
) ENGINE=InnoDB;

LOAD DATA LOCAL INFILE 'C:/Users/xidon/Downloads/usuarios.csv'
INTO TABLE `tmp_users_csv`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(`email`, `nick`, `password`, `status`);

SELECT COUNT(*) AS filas_leidas FROM `tmp_users_csv`;
CALL `db_test_corregida`.`sp_import_users_csv`();
DROP TEMPORARY TABLE `tmp_users_csv`;

SELECT COUNT(*) AS total_usuarios FROM `db_test_corregida`.`tb_users`;
SELECT COUNT(*) AS usuarios_con_persona
  FROM `db_test_corregida`.`tb_users` u
  JOIN `db_test_corregida`.`tb_people` p ON p.user_ID = u.ID;
