CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_equipment`(
    IN equipment_id INT
)
BEGIN
    DECLARE image_path VARCHAR(255);
    SELECT eq_image_path INTO image_path FROM equipment WHERE id = equipment_id;
    DELETE FROM rental_equipment WHERE eq_id = equipment_id;
    DELETE FROM equipment WHERE id = equipment_id;
    SELECT image_path AS eq_image_path;
END