CREATE DEFINER=`root`@`localhost` PROCEDURE `get_clients`()
BEGIN
    SELECT * FROM clients;
END
