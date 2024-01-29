CREATE DEFINER=`root`@`localhost` PROCEDURE `get_blocked_users`()
BEGIN
    SELECT * FROM users WHERE blocked = true;
END