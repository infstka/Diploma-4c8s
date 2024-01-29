CREATE DEFINER=`root`@`localhost` PROCEDURE `unblock_user`(IN `block_user_id` INT)
BEGIN
    UPDATE users SET blocked = false WHERE id = block_user_id;
END