use dsnrecords_db;

set foreign_key_checks = 0;
truncate table users;
truncate table bookings;
truncate table bookings_archive;
truncate table reviews;
set foreign_key_checks = 1;