CREATE DEFINER=`root`@`localhost` PROCEDURE `update_contact`(
    IN new_contact VARCHAR(255),
    IN contact_id INT
)
BEGIN
    UPDATE contacts SET contact = new_contact WHERE id = contact_id;
END
