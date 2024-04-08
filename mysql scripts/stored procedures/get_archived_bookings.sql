CREATE DEFINER=`root`@`localhost` PROCEDURE `get_archived_bookings`()
BEGIN
    SELECT bookings_archive.id, users.username, bookings_archive.timerange, bookings_archive.data, bookings_archive.status, bookings_archive.category
    FROM bookings_archive
    JOIN users ON bookings_archive.user_id = users.id
    ORDER BY data DESC, timerange DESC;
END