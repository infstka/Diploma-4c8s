CREATE DEFINER=`root`@`localhost` PROCEDURE `update_service`(
    IN service VARCHAR(255),
    IN price VARCHAR(50),
    IN service_id INT
)
BEGIN
    UPDATE prices SET service = service, price = price WHERE id = service_id;
END