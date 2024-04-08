CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_service`(
    IN service_id INT
)
BEGIN
    DELETE FROM prices WHERE id = service_id;
END