CREATE DEFINER=`root`@`localhost` PROCEDURE `get_bookings`()
BEGIN
    SELECT bookings.id, users.username, bookings.timerange, bookings.data, bookings.status, bookings.category
    FROM bookings
    JOIN users ON bookings.user_id = users.id
    ORDER BY data ASC;
END