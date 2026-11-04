-- Ejecutar como root/admin después de crear 'jonhy.neri'@'%'
-- y después de crear sp_import_users_csv.
GRANT CREATE TEMPORARY TABLES ON `db_test`.* TO 'jonhy.neri'@'%';
GRANT EXECUTE ON PROCEDURE `db_test`.`sp_import_users_csv` TO 'jonhy.neri'@'%';
FLUSH PRIVILEGES;
