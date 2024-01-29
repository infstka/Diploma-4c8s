CREATE DEFINER=`root`@`localhost` PROCEDURE `get_bookings`()
BEGIN
    SELECT bookings.id, users.username, bookings.timerange, bookings.data, bookings.status
    FROM bookings
    JOIN users ON bookings.user_id = users.id
    ORDER BY data DESC, timerange DESC;
END