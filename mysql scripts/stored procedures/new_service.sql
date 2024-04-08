CREATE DEFINER=`root`@`localhost` PROCEDURE `new_service`(
    IN service VARCHAR(255),
    IN price VARCHAR(50),
    IN category VARCHAR(255)
)
BEGIN
    INSERT INTO prices (service, price, category) 
    VALUES (service, price, category);
END