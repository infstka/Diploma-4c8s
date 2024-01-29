CREATE DEFINER=`root`@`localhost` PROCEDURE `get_reviews`()
BEGIN
    SELECT reviews.id, users.username, reviews.review_datetime, reviews.review_mark, reviews.review_comment
    FROM reviews
    JOIN users ON reviews.user_id = users.id;
END