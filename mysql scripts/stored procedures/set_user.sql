CREATE DEFINER=`root`@`localhost` PROCEDURE `set_user`(IN `user_id` INT)
BEGIN
    UPDATE users SET user_type = "user" WHERE id = user_id;
END