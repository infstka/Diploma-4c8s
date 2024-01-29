CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_and_archive_booking`(IN `booking_id` INT)
BEGIN
    INSERT INTO `bookings_archive` SELECT * FROM `bookings` WHERE `id` = booking_id;
    DELETE FROM `bookings` WHERE `id` = booking_id;
END