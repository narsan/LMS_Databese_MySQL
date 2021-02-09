use library;

insert into user(username, password, activationdate, firstname, lastname, phonenumber, address, user_type_id, withdrawal)
values ('narsan78', MD5('hello1378'), '2019-1-26', 'narges' , 'sodeifi','09123331534','azadi street', 4 , 50000 );

insert into user(username, password, activationdate, firstname, lastname, phonenumber, address, user_type_id, withdrawal)
values ('sansan85', MD5('byebye54'), '2019-10-26', 'sana' , 'sodeifi', '09122241534' , 'parkvay No.4', 3 , 100000);

insert into user(username, password, activationdate, firstname, lastname, phonenumber, address, user_type_id, withdrawal)
values ('Leiso' , MD5('leilasod78'), '2018-11-3', 'leila' , 'sodeifi' ,'09021141534','farmanie street No.6', 5 ,9000);

insert into user(username, password, activationdate, firstname, lastname, phonenumber, address, user_type_id, withdrawal)
values ('leixi' , MD5('leir79onboard'), '2017-6-10', 'leia' , 'rostami' ,'09128974656','modares chamran africa No.20', 2 , 2000);

insert into user(username, password, activationdate, firstname, lastname, phonenumber, address, user_type_id, withdrawal)
values ('theMan', MD5('imboss567'), '2010-1-1', 'maryam' , 'kiani' ,'09123883416','elahie street', 1 , 500000);

#amirdashti  amirm1999

insert into book (bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (1 , 1 , 'Fablehaven' , 1 , 200 , 15000 , 'Brondon Mull' , 2 , '2015-1-1' , 'behnam' , 5);

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (2 , 2 , 'Fablehaven: Rise of the Evening Star' , 1 , 300 , 15000 , 'Brondon Mull' , 2 , '2015-10-1' , 'behnam' , 4);

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (3 ,3 , 'Fablehaven: Grip of the Shadow Plague', 1 , 450 , 16000 , 'Brondon Mull' , 2 , '2016-1-1' , 'behnam' , 6);

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (4 ,4, 'Fablehaven: Secrets of the Dragon Sanctuary' , 1 , 550 , 17000 , 'Brondon Mull' , 2 , '2016-10-1' , 'behnam' , 5);

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (5 ,5 ,  'Fablehaven: Keys to the Demon Prison' , 1 , 600 , 18000 , 'Brondon Mull' , 2 , '2017-1-1' , 'behnam' , 7);

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (6 , 1 , 'The Brothers Karamazov' , 4 , 1000 , 20000 , 'Dostoevsky' , 1 , '1985-1-1' , 'nahid' , 10);

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (7 , 1 , 'Her Eyes' , 5, 1000 , 40000 , 'Bozorg Alavi' , 3 , '1952-1-1' , 'negah' , 3 );

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (8 , 1 , 'operating system concepts' , 2 , 1278 , 100000 , 'abraham silberschatz' , 10 , '2000-1-1' , 'wiley' , 3 );


insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (13 , 1 , 'mantegh o falsafe konkur' , 3 , 800 , 32000 , 'saba koohsari' , 5 , '2020-1-1' , 'gaj' , 4 );

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (14 , 1 , 'fast book math ' , 3 , 1000 , 60000 , 'ali fereshtian' , 4 , '2020-1-2' , 'loh bartar' , 5 );

insert into book(bookID, Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
values (15 , 1 , '3 grade english language' , 3 , 1200 , 43500 , 'grouh moalefan' , 7 , '2020-1-3' , 'ghalam chi' , 2 );


insert into barrowstatus (BarrowID, userName, bookID, ReceivedDate, ReturnDate, Deadline)
values (1 , 'narsan78' , 1 , '2020-1-1' , null , '2020-1-15' );

insert into barrowstatus (userName, bookID, ReceivedDate, ReturnDate, Deadline)
values ('sansan85' , 6 , '2020-3-1' , null , '2020-3-15');

insert into barrowstatus (userName, bookID, ReceivedDate, ReturnDate, Deadline)
values ('Leiso' , 2 , '2020-2-1' , null ,'2020-2-15'  );


insert into barrowstatus (userName, bookID, ReceivedDate, ReturnDate, Deadline)
values ('lovelyspid' , 13 , '2020-1-1' , null ,'2020-1-11'  );
insert into barrowstatus (userName, bookID, ReceivedDate, ReturnDate, Deadline)
values ('lovelyspid' , 14 , '2020-1-1' , null ,'2020-1-11'  );
insert into barrowstatus (userName, bookID, ReceivedDate, ReturnDate, Deadline)
values ('lovelyspid' , 15 , '2020-1-1' , null ,'2020-1-11'  );
insert into barrowstatus (userName, bookID, ReceivedDate, ReturnDate, Deadline)
values ('lovelyspid' , 11 , '2020-1-2' , null ,'2020-1-12'  );



insert into bookcategory(bookCategoryID, bookCategory)
values (1, 'fiction');

insert into bookcategory(bookCategoryID, bookCategory)
values (2, 'reference');

insert into bookcategory(bookCategoryID, bookCategory)
values (3, 'study book');

insert into bookcategory(bookCategoryID, bookCategory)
values (4, 'Philosophical');

insert into bookcategory(bookCategoryID, bookCategory)
values (5 , 'Romance novel');

insert into bookcategory(bookCategoryID, bookCategory)
values (6 , 'Poem');

insert into usertype (user_type_id, user_type)
values (1 , 'Manager');

insert into usertype (user_type_id, user_type)
values (2 , 'Librarian');

insert into usertype (user_type_id, user_type)
values (3 , 'Teacher');

insert into usertype (user_type_id, user_type)
values (4 , 'student');

insert into usertype (user_type_id, user_type)
values (5 , 'Ordinary');

insert into loginbox(userName, logs, late_return, log_date)
values ('Leiso' , 'blablabla' , false , '2021-02-12');

