CREATE DEFINER=`root`@`localhost` PROCEDURE `get_available_equipment`(IN startDate VARCHAR(20), IN endDate VARCHAR(20))
BEGIN
    SELECT * FROM equipment WHERE id NOT IN (
        SELECT eq_id FROM rental_equipment
        INNER JOIN rentals ON rental_equipment.rental_id = rentals.id
        WHERE (STR_TO_DATE(start_date, '%d.%m.%Y') <= STR_TO_DATE(startDate, '%d.%m.%Y') AND STR_TO_DATE(end_date, '%d.%m.%Y') >= STR_TO_DATE(startDate, '%d.%m.%Y'))
        OR (STR_TO_DATE(start_date, '%d.%m.%Y') <= STR_TO_DATE(endDate, '%d.%m.%Y') AND STR_TO_DATE(end_date, '%d.%m.%Y') >= STR_TO_DATE(endDate, '%d.%m.%Y'))
        OR (STR_TO_DATE(start_date, '%d.%m.%Y') >= STR_TO_DATE(startDate, '%d.%m.%Y') AND STR_TO_DATE(end_date, '%d.%m.%Y') <= STR_TO_DATE(endDate, '%d.%m.%Y'))
    ) AND is_rentable = 1;
END