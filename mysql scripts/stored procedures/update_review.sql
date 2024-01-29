CREATE DEFINER=`root`@`localhost` PROCEDURE `update_review`(IN p_review_datetime DATETIME, IN p_review_mark INT, IN p_review_comment TEXT, IN p_review_id INT)
BEGIN
    UPDATE reviews SET review_datetime = p_review_datetime, review_mark = p_review_mark, review_comment = p_review_comment WHERE id = p_review_id;
END