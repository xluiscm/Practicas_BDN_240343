-- Ejecutar conectado como carlos.morales desde el equipo remoto.
-- Copia usuarios.csv a C:/Users/xidon/Downloads/ en ese equipo.
-- Requiere que el admin ejecute configurar_importacion_usuarios_csv.sql
-- y autorizar_carga_csv_carlos.sql en db_test_corregida.
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
SELECT COUNT(*) AS filas_invalidas
  FROM `tmp_users_csv`
 WHERE `email` IS NULL OR TRIM(`email`) = ''
    OR `nick` IS NULL OR TRIM(`nick`) = ''
    OR `password` IS NULL OR TRIM(`password`) = ''
    OR `status` NOT IN ('0', '1');

-- El procedimiento exige exactamente 10,000 filas, valida duplicados y
-- usuarios existentes, e inserta en tb_users y tb_people en una transacción.
CALL `db_test_corregida`.`sp_import_users_csv`();
DROP TEMPORARY TABLE `tmp_users_csv`;

SELECT COUNT(*) AS usuarios_seed_insertados
  FROM `db_test_corregida`.`tb_users`
 WHERE LEFT(`email`, 10) = 'seed_user_'
   AND `email` LIKE '%@example.test';
SELECT COUNT(*) AS personas_seed_vinculadas
  FROM `db_test_corregida`.`tb_users` u
  JOIN `db_test_corregida`.`tb_people` p ON p.user_ID = u.ID
 WHERE LEFT(u.`email`, 10) = 'seed_user_'
   AND u.`email` LIKE '%@example.test';
