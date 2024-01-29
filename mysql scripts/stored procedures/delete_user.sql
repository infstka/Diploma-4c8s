CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_user`(IN `delete_user_id` INT)
BEGIN
    DELETE FROM `bookings_archive` WHERE `user_id` = delete_user_id;
	DELETE FROM `bookings` WHERE `user_id` = delete_user_id;
    DELETE FROM `users` WHERE `id` = delete_user_id;
END