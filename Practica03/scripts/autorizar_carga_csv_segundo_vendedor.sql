-- Ejecutar como root/admin después de crear 'jonhy.neri'@'%'
-- y después de crear sp_import_users_csv en db_test_corregida.
GRANT CREATE TEMPORARY TABLES ON `db_test_corregida`.* TO 'jonhy.neri'@'%';
GRANT EXECUTE ON PROCEDURE `db_test_corregida`.`sp_import_users_csv` TO 'jonhy.neri'@'%';
FLUSH PRIVILEGES;
