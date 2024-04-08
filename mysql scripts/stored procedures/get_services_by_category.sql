CREATE DEFINER=`root`@`localhost` PROCEDURE `get_services_by_category`(IN p_category VARCHAR(255))
BEGIN
    SELECT * FROM prices WHERE p_category = category;
END