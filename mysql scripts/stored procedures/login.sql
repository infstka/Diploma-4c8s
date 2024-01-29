CREATE DEFINER=`root`@`localhost` PROCEDURE `login`(IN p_user_email VARCHAR(255))
BEGIN
    SELECT *
    FROM users
    WHERE user_email = p_user_email;
END