CREATE DEFINER=`root`@`localhost` PROCEDURE `new_client`(
    IN client_name VARCHAR(255),
    IN client_image_path VARCHAR(255))
BEGIN
    INSERT INTO clients (client_name, client_image_path) 
    VALUES (client_name, client_image_path);
END
