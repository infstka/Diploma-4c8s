CREATE DEFINER=`root`@`localhost` PROCEDURE `get_booking_history`(IN uid INT)
BEGIN
    SELECT id, user_id, DATE_FORMAT(STR_TO_DATE(data, '%d.%m.%Y'), '%d.%m.%Y') AS data, timerange, category 
    FROM bookings 
    WHERE user_id = uid 
    ORDER BY STR_TO_DATE(data, '%d.%m.%Y') ASC;
END