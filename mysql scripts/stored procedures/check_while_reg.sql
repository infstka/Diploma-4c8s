CREATE DEFINER=`root`@`localhost` PROCEDURE `check_while_reg`(IN p_username VARCHAR(255), IN p_user_email VARCHAR(255), OUT p_userExists INT)
BEGIN
SELECT COUNT(*) INTO p_userExists FROM users WHERE username = p_username OR user_email = p_user_email;
END