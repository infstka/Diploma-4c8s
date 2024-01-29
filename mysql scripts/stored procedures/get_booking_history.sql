CREATE DEFINER=`root`@`localhost` PROCEDURE `get_booking_history`(IN uid INT)
BEGIN
    SELECT id, user_id, data, timerange 
    FROM bookings 
    WHERE user_id = uid 
    ORDER BY data DESC;
END