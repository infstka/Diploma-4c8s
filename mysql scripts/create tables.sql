use dsnrecords_db;

create table users (
id int auto_increment primary key,
username text,
user_email text,
user_password text,
user_type text,
blocked boolean
);

create table bookings (
id int auto_increment primary key,
user_id int,
timerange varchar(20),
status int,
data varchar(20),
foreign key (user_id) references users (id)
);

create table bookings_archive (
id int auto_increment primary key,
user_id int,
timerange varchar(20),
status int,
data varchar(20),
foreign key (user_id) references users (id)
);

create table reviews (
id int auto_increment primary key,
user_id int,
review_datetime datetime,
review_mark int,
review_comment text,
foreign key (user_id) references users (id)
);