CREATE DEFINER=`root`@`localhost` PROCEDURE `get_users`()
BEGIN
    SELECT * FROM users WHERE blocked = false;
END