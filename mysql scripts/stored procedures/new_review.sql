CREATE DEFINER=`root`@`localhost` PROCEDURE `new_review`(IN p_user_id INT, IN p_review_datetime DATETIME, IN p_review_mark INT, IN p_review_comment TEXT)
BEGIN
    INSERT INTO reviews (user_id, review_datetime, review_mark, review_comment)
    VALUES (p_user_id, p_review_datetime, p_review_mark, p_review_comment);
END