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
category varchar(50),
foreign key (user_id) references users (id)
);

create table bookings_archive (
id int auto_increment primary key,
user_id int,
timerange varchar(20),
status int,
data varchar(20),
category varchar(50),
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

create table equipment (
    id int auto_increment primary key,
    eq_name varchar(50) not null,
    eq_category varchar(50) not null,
    eq_image_path varchar(255) not null,
    is_rentable bool not null,
    price_id int,
    foreign key (price_id) references prices (id)
);

create table prices (
    id int auto_increment primary key,
    service varchar(255) not null,
    price varchar(50) not null,
    category varchar(50) not null
);

create table clients (
    id int auto_increment primary key,
    client_name varchar(255) not null,
    client_image_path varchar(255) not null
);

create table contacts (
    id int auto_increment primary key,
    contact varchar(255) not null,
    contact_type varchar(255) not null
);

create table rentals (
    id int auto_increment PRIMARY KEY,
    start_date varchar(20) not null,
    end_date varchar(20) not null,
    fullname varchar(255) not null,
    phone varchar(20) not null,
    user_id int not null,
    foreign key (user_id) references users(id)
);

create table rental_equipment (
    rental_id int,
    eq_id int,
    foreign key (rental_id) references rentals(id),
    foreign key (eq_id) references equipment(id),
    primary key (rental_id, eq_id)
);

create table rentals_archive (
    id int auto_increment PRIMARY KEY,
    start_date varchar(20) not null,
    end_date varchar(20) not null,
    fullname varchar(255) not null,
    phone varchar(20) not null,
    user_id int not null,
    foreign key (user_id) references users(id)
);

create table rental_equipment_archive (
    rental_id int,
    eq_id int,
    primary key (rental_id, eq_id)
);