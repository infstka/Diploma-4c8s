CREATE DEFINER=`root`@`localhost` PROCEDURE `register`(IN p_username VARCHAR(255), IN p_user_email VARCHAR(255), IN p_user_password VARCHAR(255), IN p_user_type VARCHAR(255), IN p_blocked INT)
BEGIN
    INSERT INTO users(username, user_email, user_password, user_type, blocked)
    VALUES (p_username, p_user_email, p_user_password, p_user_type, p_blocked);
END