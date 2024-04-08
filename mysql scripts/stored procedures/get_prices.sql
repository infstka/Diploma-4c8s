CREATE DEFINER=`root`@`localhost` PROCEDURE `get_prices`()
BEGIN
    SELECT * FROM prices;
END