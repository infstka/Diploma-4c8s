CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_contact`(
    IN contact_id INT
)
BEGIN
    DELETE FROM contacts WHERE id = contact_id;
END