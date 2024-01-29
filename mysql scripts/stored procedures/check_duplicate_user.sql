CREATE DEFINER=`root`@`localhost` PROCEDURE `check_duplicate_user`(IN uid INT, IN uname VARCHAR(255), IN uemail VARCHAR(255), OUT user_count INT)
BEGIN
    SELECT COUNT(*) INTO user_count FROM users WHERE (username = uname OR user_email = uemail) AND id != uid;
END