CREATE DEFINER=`root`@`localhost` PROCEDURE `get_equipment`()
BEGIN
    SELECT * FROM equipment;
END
