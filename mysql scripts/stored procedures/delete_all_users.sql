CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_all_users`()
BEGIN
    TRUNCATE TABLE bookings_archive;
    TRUNCATE TABLE bookings;
    DELETE FROM users WHERE id NOT IN (1);
END