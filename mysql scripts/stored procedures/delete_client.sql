CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_client`(IN client_id INT)
BEGIN
    DECLARE image_path VARCHAR(255);
    SELECT client_image_path INTO image_path FROM clients WHERE id = client_id;
    DELETE FROM clients WHERE id = client_id;
    SELECT image_path AS client_image_path;
    END