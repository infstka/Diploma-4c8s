CREATE DEFINER=`root`@`localhost` PROCEDURE `book_time`(IN p_user_id INT, IN p_timerange VARCHAR(20), IN p_data VARCHAR(20))
BEGIN
    INSERT INTO bookings (user_id, timerange, status, data) VALUES (p_user_id, p_timerange, 1, p_data);
END