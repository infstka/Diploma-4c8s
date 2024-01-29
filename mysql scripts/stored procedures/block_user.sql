CREATE DEFINER=`root`@`localhost` PROCEDURE `block_user`(IN `block_user_id` INT)
BEGIN
    DELETE FROM `bookings_archive` WHERE `user_id` = block_user_id;
	DELETE FROM `bookings` WHERE `user_id` = block_user_id;
    UPDATE users SET blocked = true WHERE id = block_user_id;
END