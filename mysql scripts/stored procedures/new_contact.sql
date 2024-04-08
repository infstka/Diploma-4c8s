CREATE DEFINER=`root`@`localhost` PROCEDURE `new_contact`(
    IN contact VARCHAR(255),
    IN contact_type VARCHAR(255)
)
BEGIN
    INSERT INTO contacts (contact, contact_type) VALUES (contact, contact_type);
END