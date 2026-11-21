-- Ejecutar como root/admin después de instalar sp_import_users_csv
-- en db_test_corregida. Aplica al usuario MySQL carlos.morales desde cualquier host.
GRANT CREATE TEMPORARY TABLES ON `db_test_corregida`.* TO 'carlos.morales'@'%';
GRANT EXECUTE ON PROCEDURE `db_test_corregida`.`sp_import_users_csv` TO 'carlos.morales'@'%';
SHOW GRANTS FOR 'carlos.morales'@'%';
