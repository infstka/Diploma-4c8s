CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_and_archive_rental`(IN p_rental_id INT)
BEGIN
    INSERT INTO rental_equipment_archive SELECT * FROM rental_equipment WHERE rental_id  = p_rental_id;
    INSERT INTO rentals_archive SELECT * FROM rentals WHERE id = p_rental_id;
    DELETE FROM rental_equipment WHERE rental_id = p_rental_id;
    DELETE FROM rentals WHERE id = p_rental_id;
END