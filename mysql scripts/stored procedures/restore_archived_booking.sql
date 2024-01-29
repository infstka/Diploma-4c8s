CREATE DEFINER=`root`@`localhost` PROCEDURE `restore_archived_booking`(IN `booking_id` INT)
BEGIN
    INSERT INTO `bookings` SELECT * FROM `bookings_archive` WHERE `id` = booking_id;
    DELETE FROM `bookings_archive` WHERE `id` = booking_id;
END