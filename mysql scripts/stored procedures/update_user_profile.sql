CREATE DEFINER=`root`@`localhost` PROCEDURE `update_user_profile`(IN uid INT, IN uname VARCHAR(255), IN upassword VARCHAR(255), IN uemail VARCHAR(255))
BEGIN
    UPDATE users 
    SET username = IF(uname = '', username, uname), 
        user_password = IF(upassword = '', user_password, upassword), 
        user_email = IF(uemail = '', user_email, uemail)
    WHERE id = uid;
END
