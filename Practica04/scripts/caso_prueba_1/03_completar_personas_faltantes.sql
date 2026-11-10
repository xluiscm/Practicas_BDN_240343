-- Completa tb_people para los usuarios existentes sin crear usuarios nuevos.
-- Ejecutar como DBA en db_test_corregida. Es seguro volver a ejecutarlo:
-- solo inserta personas cuyo user_ID todavía no aparece en tb_people.

USE db_test_corregida;

DROP PROCEDURE IF EXISTS sp_sync_people_from_users;
DELIMITER $$

CREATE PROCEDURE sp_sync_people_from_users()
BEGIN
    DECLARE v_unlinked_people INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- No se puede garantizar el mismo total si ya existen personas sin usuario.
    SELECT COUNT(*)
      INTO v_unlinked_people
      FROM tb_people
     WHERE user_ID IS NULL;

    IF v_unlinked_people > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hay filas en tb_people sin user_ID; corrígelas antes de sincronizar';
    END IF;

    INSERT INTO tb_people (
        user_ID,
        given_names,
        status,
        creation_date,
        last_update
    )
    SELECT
        u.ID,
        COALESCE(NULLIF(TRIM(u.nick), ''), CONCAT('Usuario ', u.ID)),
        u.status,
        u.creation_date,
        COALESCE(u.last_update, u.creation_date)
    FROM tb_users AS u
    LEFT JOIN tb_people AS p ON p.user_ID = u.ID
    WHERE p.person_ID IS NULL;

    COMMIT;

    SELECT
        (SELECT COUNT(*) FROM tb_users) AS total_usuarios,
        (SELECT COUNT(*) FROM tb_people) AS total_personas,
        (SELECT COUNT(*)
           FROM tb_users AS u
           LEFT JOIN tb_people AS p ON p.user_ID = u.ID
          WHERE p.person_ID IS NULL) AS usuarios_sin_persona;
END$$

DELIMITER ;

CALL sp_sync_people_from_users();

