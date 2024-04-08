CREATE DEFINER=`root`@`localhost` PROCEDURE `restore_archived_rental`(IN p_rental_id INT)
BEGIN
    INSERT INTO rentals SELECT * FROM rentals_archive WHERE id = p_rental_id;
    DELETE FROM rentals_archive WHERE id = p_rental_id;
	INSERT INTO rental_equipment SELECT * FROM rental_equipment_archive WHERE rental_id = p_rental_id;
    DELETE FROM rental_equipment_archive WHERE rental_id = p_rental_id;
END