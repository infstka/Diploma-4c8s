CREATE DEFINER=`root`@`localhost` PROCEDURE `get_bookings_by_date`(IN p_data varchar(20))
BEGIN
    SELECT * FROM bookings WHERE data = p_data;
END