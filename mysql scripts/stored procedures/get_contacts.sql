CREATE DEFINER=`root`@`localhost` PROCEDURE `get_contacts`()
BEGIN
    SELECT * FROM contacts;
END