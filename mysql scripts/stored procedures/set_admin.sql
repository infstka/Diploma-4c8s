CREATE DEFINER=`root`@`localhost` PROCEDURE `set_admin`(IN `user_id` INT)
BEGIN
    UPDATE users SET user_type = "admin" WHERE id = user_id;
END