CREATE DEFINER=`root`@`localhost` PROCEDURE `get_archived_rentals`()
BEGIN
    SELECT rentals_archive.*, GROUP_CONCAT(equipment.eq_name SEPARATOR ', ') AS eq_names
    FROM rentals_archive
    INNER JOIN rental_equipment_archive ON rentals_archive.id = rental_equipment_archive.rental_id
    INNER JOIN equipment ON rental_equipment_archive.eq_id = equipment.id
    GROUP BY rentals_archive.id;
END