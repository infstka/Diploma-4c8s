CREATE DEFINER=`root`@`localhost` PROCEDURE `get_rentals_history`(
    IN user_id INT
)
BEGIN
    SELECT rentals.*, GROUP_CONCAT(equipment.eq_name SEPARATOR ', ') AS eq_names
    FROM rentals
    INNER JOIN rental_equipment ON rentals.id = rental_equipment.rental_id
    INNER JOIN equipment ON rental_equipment.eq_id = equipment.id
    WHERE rentals.user_id = user_id
    GROUP BY rentals.id;
END;
