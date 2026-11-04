-- Ejecutar como root/admin en db_test después de restaurar el respaldo.
-- Después, jonhy.neri carga el CSV con cargar_usuarios_csv.sql.
USE `db_test`;

DROP PROCEDURE IF EXISTS `sp_import_users_csv`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_import_users_csv`()
SQL SECURITY DEFINER
MODIFIES SQL DATA
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_invalid INT DEFAULT 0;
    DECLARE v_duplicates INT DEFAULT 0;
    DECLARE v_existing INT DEFAULT 0;
    DECLARE v_caller VARCHAR(32);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_caller = SUBSTRING_INDEX(USER(), '@', 1);
    IF v_caller <> 'jonhy.neri' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo jonhy.neri puede importar usuarios desde CSV';
    END IF;

    SELECT COUNT(*) INTO v_total FROM `tmp_users_csv`;
    IF v_total <> 10000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El CSV debe contener exactamente 10000 filas';
    END IF;

    SELECT COUNT(*) INTO v_invalid
      FROM `tmp_users_csv`
     WHERE `email` IS NULL OR TRIM(`email`) = ''
        OR `nick` IS NULL OR TRIM(`nick`) = ''
        OR `password` IS NULL OR TRIM(`password`) = ''
        OR `status` NOT IN ('0','1');
    IF v_invalid > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hay campos vacios o status distinto de 0/1 en el CSV';
    END IF;

    SELECT COUNT(*) INTO v_duplicates
      FROM (
          SELECT LOWER(TRIM(`email`)) AS email_key
            FROM `tmp_users_csv`
           GROUP BY LOWER(TRIM(`email`))
          HAVING COUNT(*) > 1
      ) AS duplicated_emails;
    IF v_duplicates > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El CSV contiene correos duplicados';
    END IF;

    SELECT COUNT(*) INTO v_duplicates
      FROM (
          SELECT LOWER(TRIM(`nick`)) AS nick_key
            FROM `tmp_users_csv`
           GROUP BY LOWER(TRIM(`nick`))
          HAVING COUNT(*) > 1
      ) AS duplicated_nicks;
    IF v_duplicates > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El CSV contiene nicks duplicados';
    END IF;

    SELECT COUNT(*) INTO v_existing
      FROM `tmp_users_csv` s
      JOIN `tb_users` u
        ON LOWER(u.email) = LOWER(TRIM(s.email))
        OR LOWER(u.nick) = LOWER(TRIM(s.nick));
    IF v_existing > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hay correos o nicks del CSV que ya existen en tb_users';
    END IF;

    START TRANSACTION;

    INSERT INTO `tb_users` (`email`, `nick`, `password`, `status`, `creation_date`, `last_update`, `last_login`)
    SELECT LOWER(TRIM(`email`)), TRIM(`nick`), `password`,
           IF(`status` = '1', b'1', b'0'), CURRENT_TIMESTAMP, NULL, NULL
      FROM `tmp_users_csv`;

    INSERT INTO `tb_people` (`user_ID`, `given_names`, `gender`, `status`, `creation_date`, `last_update`)
    SELECT u.ID, 'Pendiente de completar', 'Prefiero no decirlo',
           IF(s.`status` = '1', b'1', b'0'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM `tmp_users_csv` s
      JOIN `tb_users` u
        ON u.email = LOWER(TRIM(s.email))
       AND u.nick = TRIM(s.nick);

    COMMIT;

    SELECT COUNT(*) AS usuarios_importados FROM `tmp_users_csv`;
    SELECT COUNT(*) AS personas_vinculadas
      FROM `tmp_users_csv` s
      JOIN `tb_users` u ON u.email = LOWER(TRIM(s.email)) AND u.nick = TRIM(s.nick)
      JOIN `tb_people` p ON p.user_ID = u.ID;
END ;;
DELIMITER ;

