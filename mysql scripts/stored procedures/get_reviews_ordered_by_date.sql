CREATE DEFINER=`root`@`localhost` PROCEDURE `get_reviews_ordered_by_date`(IN sortOrder VARCHAR(4))
BEGIN
    SET @orderByClause = CONCAT('ORDER BY reviews.review_datetime ', sortOrder);
    SET @sqlQuery = 'SELECT reviews.id, users.username, reviews.review_datetime, reviews.review_mark, reviews.review_comment
                    FROM reviews
                    JOIN users ON reviews.user_id = users.id ';
    SET @sqlQuery = CONCAT(@sqlQuery, @orderByClause);
    PREPARE finalQuery FROM @sqlQuery;
    EXECUTE finalQuery;
    DEALLOCATE PREPARE finalQuery;
END