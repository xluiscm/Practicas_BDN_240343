use db_test;

SHOW TABLES;

SHOW TRIGGERS FROM db_test;

SELECT *
FROM vw_total_products_by_category
ORDER BY category_id is null;

SHOW PROCEDURE STATUS WHERE Db = 'db_test';