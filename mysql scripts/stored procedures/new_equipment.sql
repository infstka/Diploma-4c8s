CREATE DEFINER=`root`@`localhost` PROCEDURE `new_equipment`(
    IN eq_name VARCHAR(255),
    IN eq_category VARCHAR(255),
    IN is_rentable INT,
    IN eq_image_path VARCHAR(255),
    IN price_id INT
)
BEGIN
    INSERT INTO equipment (eq_name, eq_category, is_rentable, eq_image_path, price_id) 
    VALUES (eq_name, eq_category, is_rentable, eq_image_path, price_id);
END