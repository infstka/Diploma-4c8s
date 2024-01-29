CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_review`(IN `delete_review_id` INT)
BEGIN
    DELETE FROM `reviews` WHERE `id` = delete_review_id;
END