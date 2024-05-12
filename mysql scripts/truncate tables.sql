use dsnrecords_db;

set foreign_key_checks = 0;
truncate table users;
truncate table bookings;
truncate table bookings_archive;
truncate table reviews;
truncate table clients;
truncate table equipment;
truncate table prices;
truncate table rentals;
truncate table rental_equipment;
truncate table contacts;
truncate table rentals_archive;
truncate table rental_equipment_archive;
set foreign_key_checks = 1;