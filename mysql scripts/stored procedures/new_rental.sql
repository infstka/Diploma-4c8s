CREATE DEFINER=`root`@`localhost` PROCEDURE `new_rental`(    
    IN start_date VARCHAR(20),
    IN end_date VARCHAR(20),
    IN fullname VARCHAR(255),
    IN phone VARCHAR(20),
    IN user_id INT,
    IN eq_ids VARCHAR(255))
BEGIN
    DECLARE rental_id INT;
    
    -- Вставляем данные в таблицу аренды
    INSERT INTO rentals (start_date, end_date, fullname, phone, user_id) 
    VALUES (start_date, end_date, fullname, phone, user_id);
    
    -- Получаем ID новой записи аренды
    SET rental_id = LAST_INSERT_ID();
    
    -- Разбиваем строку с ID оборудования на массив
    CREATE TEMPORARY TABLE temp_eq_ids (eq_id INT);
    SET @sql = CONCAT('INSERT INTO temp_eq_ids (eq_id) VALUES (', REPLACE(eq_ids, ',', '), ('), ')');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Вставляем данные о выбранном оборудовании в таблицу аренды оборудования
    INSERT INTO rental_equipment (rental_id, eq_id) 
    SELECT rental_id, eq_id FROM temp_eq_ids;
    
    -- Удаляем временную таблицу
    DROP TEMPORARY TABLE IF EXISTS temp_eq_ids;
    
END