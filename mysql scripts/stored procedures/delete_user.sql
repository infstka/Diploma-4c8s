CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_user`(IN `delete_user_id` INT)
BEGIN
    DELETE FROM `rental_equipment` 
    WHERE `rental_id` IN (SELECT id FROM rentals WHERE user_id = delete_user_id);

    DELETE FROM `rental_equipment_archive` 
    WHERE `rental_id` IN (SELECT id FROM rentals_archive WHERE user_id = delete_user_id);

    DELETE FROM `bookings_archive` WHERE `user_id` = delete_user_id;
    DELETE FROM `bookings` WHERE `user_id` = delete_user_id;
    DELETE FROM `rentals_archive` WHERE `user_id` = delete_user_id;
    DELETE FROM `rentals` WHERE `user_id` = delete_user_id;
    DELETE FROM `reviews` WHERE `user_id` = delete_user_id;
    DELETE FROM `users` WHERE `id` = delete_user_id;
END