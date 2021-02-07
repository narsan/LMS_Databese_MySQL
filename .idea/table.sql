create database library;
use library;
create table if not exists user (
    ID int auto_increment primary key,
    userName varchar (20) unique not null, #handle case sensitivity
    password varchar(255) not null,
    activationDate date not null,
    FirstName nchar(50) not null,
    LastName nchar(50) not null,
    PhoneNumber varchar(12) not null ,
    Address varchar(200) not null,
    user_type_id int not null,
    Withdrawal integer,
    tag varchar(100),
    note varchar(200),
    foreign key (user_type_id) references userType (user_type_id),
#     CONSTRAINT CHECK (password like '%[0-9]%' AND (password like '%[a-z]%' or password like '%[A-Z]%'))
);


create table if not exists BarrowStatus(
    BarrowID integer primary key auto_increment not null,
    userName varchar(20) not null, # id
    bookID INTEGER not null,
    ReceivedDate date ,
    ReturnDate date,
    Deadline date ,
    history varchar(200),
    foreign key (bookID) references book(bookID)
);



CREATE table if not exists book (
    bookID INTEGER primary key auto_increment not null,
    Volume smallint,
    Title nchar(100) not null,
    bookCategoryID int not null,
    NumberOfPages integer,
    Price integer,
    Author nchar(20),
    edition integer,
    publish_date date not null,
    PublisherName nchar(50) not null,
    stock integer,
    foreign key (bookCategoryID) references bookCategory (bookCategoryID)
);


create table if not exists bookCategory(
    bookCategoryID int primary key not null ,
    bookCategory varchar(20) not null
);

create table if not exists userType(
    user_type_id int primary key not null ,
    user_type varchar(20) not null
);


