use library;
start transaction;
create procedure create_account(
    in p_userName varchar(20),
    in p_password varchar(255),
    in p_activateDate nchar(20),
    in p_FirstName nchar(50),
    in p_LastName nchar(50),
    in p_PhoneNumber varchar(12),
    in p_Address varchar(200),
    in p_userTypeID int,
    out p_tag varchar(100),
    out error_message varchar(300)

)
begin
    insert into user(username, password, activationdate, firstname, lastname, phonenumber, address, user_type_id)
    values (p_userName, MD5(p_password), p_activateDate, p_FirstName, p_LastName, p_PhoneNumber, p_Address, p_userTypeID);
    commit;
    SET SQL_SAFE_UPDATES=0;
    update user set tag =  md5(concat(p_userName,p_password,CURRENT_TIME)) where userName = p_userName;
    commit;
    select tag INTO @p_tag from user where username = p_userName;
    set p_tag = @p_tag;
    set error_message = 'you sign up successfully';
end;

create procedure check_username(
    in p_userName varchar(20),
    out error_message varchar(300)

)
begin
    SET @User_exists = 0;
    SELECT 1 INTO @User_exists
    FROM user
    WHERE username = p_userName;
    SELECT @User_exists;
    IF @User_exists != 1 then
        IF CHAR_LENGTH(p_userName) < 5 then
            set  error_message = 'An error has occurred, userName does not have enough character';
        end if;
    else
        set error_message = 'user already exists';
    end if;

end;



create procedure check_password(
    in p_password varchar(255),
    out error_message varchar(300),
    out invalid boolean
)
begin
    declare contain_letter boolean;
    declare contain_number boolean;
    declare char_check int;
    declare num_check int;
    set num_check = 48;
    set char_check = 65;
    set contain_letter = 0;
    set contain_number = 0;
    set invalid = 0;
    IF CHAR_LENGTH(p_password) < 8 then
            set  error_message = 'An error has occurred, password should have more than 8 character';
            set invalid = 1;
    else
        loop_label1 : LOOP
            if char_check > ASCII('Z') then
                leave loop_label1;
            end if;
            IF p_password LIKE CONCAT('%', CHAR(char_check), '%') THEN
                SET contain_letter = 1;
                LEAVE loop_label1;
            END IF;
            SET char_check = char_check + 1;
        end loop loop_label1;

        loop_label2 : LOOP
            if num_check > ASCII('9') then
                leave loop_label2;
            end if;
            IF p_password LIKE CONCAT('%', CHAR(num_check), '%') THEN
                SET contain_number = 1;
                LEAVE loop_label2;
            END IF;
            SET num_check = num_check + 1;

        end loop loop_label2;
        if contain_number = 1 and contain_letter =1 then
            set error_message = 'password contain number and letter';
        else
            set error_message = 'invalid password , password must contain number and letter';
            set invalid = 1;
        end if;

    end if;
end;


create procedure user_sign_in(
    in p_userName varchar(20),
    in p_password varchar(255),
    out p_tag varchar(100),
    out error_message varchar(300)
)
begin
    SET @User_exists = 0;
    SELECT 1 INTO @User_exists
    FROM user
    WHERE username = p_userName;
    SELECT @User_exists;
    IF @User_exists != 1 then
        set error_message = 'username is not exist please sign up';
    else
        select 1 INTO @correct_pass from user where userName = p_userName and password = md5(p_password);
        IF @correct_pass = 1 then
            set error_message = 'successfully login';
            SET SQL_SAFE_UPDATES=0;
            update user set tag =  md5(concat(p_userName,p_password,CURRENT_TIME)) where userName = p_userName;
            commit;
            select tag INTO @p_tag from user where username = p_userName;
            set p_tag = @p_tag;
        else
            set error_message = 'incorrect password';
        end if;
    end if;
end;

create procedure user_system_data(
    in p_tag varchar(100)

)
begin
    select username INTO @user from user where tag = p_tag;
    IF @user is not NULL then
        select username , activationDate from user where userName = @user;
    end if;

end;


create procedure user_personal_data(
    in p_tag varchar(100)
)
begin
    select username INTO @user from user where tag = p_tag;
    IF @user is not NULL then
        select FirstName , LastName , PhoneNumber , Address , user_type , Withdrawal
        from user natural join usertype where userName = @user and user.user_type_id = user_type_id;
    end if;

end;

create procedure sign_out(
 in p_tag varchar(100)
)
begin
    SET SQL_SAFE_UPDATES=0;
    update user set tag =  null where tag = p_tag;
    commit;
end;

create procedure increase_credit(
    in p_tag varchar(100),
    in credit int,
    out error_message varchar(100)
)
begin
     select Withdrawal into @withd from user where tag = p_tag;
     SET SQL_SAFE_UPDATES=0;
     if @withd is null then
         update user set Withdrawal = 0 where tag = p_tag;
         commit ;
     end if;
     update user set  Withdrawal = Withdrawal + credit where tag = p_tag;
     commit;
     set error_message = 'credit updated';
     IF credit < 1000 Then
         set error_message = 'you entered an invalid number please try again';
         rollback ;
     end if;

end;


create procedure search_book(
    in book_title nchar(100),
    in book_Author nchar (20),
    in book_publish_date date,
    in book_edition integer
)
begin
     select bookID , Title, Volume, bookCategory , NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock
     from  book join bookcategory b on book.bookCategoryID = b.bookCategoryID
     where (book_title is null or book_title = Title ) and (book_Author is null or book_Author = Author)
     and (book_publish_date is null or book_publish_date = publish_date) and (book_edition = 0 or book_edition = edition)
     order by book.Title;

end;

create procedure barrow_book(
    in p_tag varchar(100),
    in book_id_to_barrow int,
    out error_message varchar(300)
)
begin
    declare book_deadline date;
    select username , Withdrawal , user_type_id INTO @user , @money, @typeID from user where tag = p_tag;
    IF @user is not NULL then
        select count(*) into @numberOfDelay from loginbox
        where late_return = 1 and log_date between (curdate()-interval 2 month) and curdate() and userName = @user;
        SELECT ban_date into @ban_user_date from user where userName = @user;
        if @numberOfDelay >= 4 or (@ban_user_date is not null and timestampdiff(MONTH, @ban_user_date,curdate()) < 1) then
            set error_message = 'you can not barrow any book for 1 month from now ';
            SET SQL_SAFE_UPDATES=0;
            update user set ban_date = curdate() where userName = @user;
            commit;
        elseif timestampdiff(MONTH, @ban_user_date,curdate()) >= 1 or @ban_user_date is null then
            select bookID , Price , stock , bookCategoryID into @id , @book_price , @num_of_book , @cat_id from book where bookID = book_id_to_barrow;
            if @typeID = 4 and @cat_id = 2 then
                set error_message = 'you do not have access to this category';
                rollback;
            elseif @typeID = 5 and (@cat_id = 2 or  @cat_id = 3) then
                set error_message = 'you do not have access to this category';
                rollback;
            else
                if @money - (5/100)*@book_price > 0 and @num_of_book - 1 > 0 then
                    SET SQL_SAFE_UPDATES=0;
                    update book set stock = stock -1 where bookID = book_id_to_barrow;
                    commit;
                    update user set Withdrawal = @money - (5/100)*@book_price where userName = @user;
                    commit;
                    set book_deadline = curdate()+ interval 10 day;
                    set error_message = concat('you have the book until ',book_deadline ,' please return it on time');
                    insert into barrowstatus (userName, bookID, ReceivedDate, Deadline , history)
                    values(@user , @id , curdate(), book_deadline , error_message);
                    commit;
                elseif @money - (5/100)*@book_price < 0 then
                    set error_message = 'you do not have enough credit';
                    insert into barrowstatus (userName, bookID, history)
                    values(@user , @id , error_message);
                    commit;
                elseif @num_of_book - 1 < 0 then
                    set error_message = 'book is not available in the stuck';
                    insert into barrowstatus (userName, bookID, history)
                    values(@user , @id , error_message);
                    commit;
                end if;
            end if;
        end if;
    end if;
end;



create procedure return_book(
      in p_tag varchar(100),
      in book_id_to_return int,
      out error_message varchar(300)
)
begin
     select username INTO @user from user where tag = p_tag;
     select 1 into @userBarrowBook from barrowstatus where userName = @user and ReturnDate is null;
     IF @user is not NULL and @userBarrowBook = 1 then
         SET SQL_SAFE_UPDATES=0;
         update book set stock = stock + 1 where bookID = book_id_to_return;
         commit;
         update barrowstatus set ReturnDate = curdate() where bookID = book_id_to_return;
         commit;
         select ReturnDate  , Deadline into @ret , @deadline from barrowstatus where bookID = book_id_to_return;
         if @ret < @deadline then
             set error_message =concat(@user ,' return bookID ',book_id_to_return,' with no delay');
             update barrowstatus set history = error_message where BarrowID = book_id_to_return;
             commit;
         else
             set error_message = concat(@user ,' return bookID ',book_id_to_return ,' with ', datediff(@ret , @deadline),' day delay');
             update barrowstatus set history = error_message where BarrowID = book_id_to_return;
             commit;
         end if;
     else
         set error_message = 'you did not barrow any book to return';
     end if;
end;






create procedure get_user_type(
    in p_tag varchar(100),
    out type int
)
begin
    select user_type_id into type from user where tag = p_tag;
end;

create procedure add_book(
    in p_tag varchar(100),
    in inp_Volume smallint,
    in inp_Title nchar(100),
    in inp_bookCategoryID int,
    in inp_NumberOfPages integer,
    in inp_Price integer,
    in inp_Author nchar(20),
    in inp_edition integer,
    in inp_publish_date date,
    in inp_PublisherName nchar(50),
    out error_message varchar(300)
)
begin
    select userName,user_type_id into @user , @id from user where p_tag = tag;
    if @user is not null then
        if @id = 1 or @id = 2 then
            select 1 into @book_available from book where Volume = inp_Volume and Title = inp_Title
            and bookCategoryID = inp_bookCategoryID and NumberOfPages = inp_NumberOfPages and Price = inp_Price
            and Author = inp_Author and edition = inp_edition and publish_date = inp_publish_date and PublisherName = inp_PublisherName;
            if @book_available = 1 then
                update book set stock = stock + 1 where Title = inp_Title;
                set error_message = 'book updated on stock';
            else
                insert into book(Volume, Title, bookCategoryID, NumberOfPages, Price, Author, edition, publish_date, PublisherName, stock)
                values (inp_Volume , inp_Title , inp_bookCategoryID , inp_NumberOfPages , inp_Price , inp_Author , inp_edition , inp_publish_date , inp_PublisherName , 1);
                commit;
                set error_message = 'book added to library';
            end if;
        else
            set error_message = 'you do not have access to this field';
            rollback ;
        end if;
    else
        set error_message = 'please log in first';
        rollback;
    end if;
end;



CREATE procedure search_user(
    in p_tag varchar(100),
    in inp_userName varchar(20),
    in inp_LastName varchar(50),
    in inp_limit int,
    in inp_offset int,
    out error_message varchar(300)
)
begin
    select userName,user_type_id into @user , @id from user where p_tag = tag;
    if @user is not null then
        if @id = 1 or @id = 2 then
            select ID , userName ,activationDate , FirstName, LastName,PhoneNumber , Address ,user_type,Withdrawal
            from user join usertype u on user.user_type_id = u.user_type_id
            where userName is null or userName = inp_userName or LastName is null or LastName = inp_LastName order by FirstName
            limit inp_limit offset inp_offset;
        else
            set error_message = 'you do not have access to this field';
            rollback ;
        end if;
    else
        set error_message = 'please log in first';
        rollback;
    end if;
end;

create procedure admins_get_successful_barrow_req(
    in p_tag varchar(100),
    in inp_limit int,
    in inp_offset int,
    out error_message varchar(300)
)
begin
    select userName,user_type_id into @user , @id from user where p_tag = tag;
    if @user is not null then
        if @id = 1 or @id = 2 then
            select userName , logs from loginbox natural join barrowstatus
            where ReceivedDate is not null and ReturnDate is null order by log_date desc
            limit inp_limit offset inp_offset;
        else
            set error_message = 'you do not have access to this field';
            rollback ;
        end if;
    else
        set error_message = 'please log in first';
        rollback;
    end if;
end;

create procedure search_late_return_books(
    in p_tag varchar(100),
    out error_message varchar(300)
)
begin
    select userName,user_type_id into @user , @id from user where p_tag = tag;
    if @user is not null then
        if @id = 1 or @id = 2 then
            select userName , Title , timestampdiff(day, Deadline, curdate()) as latency
            from barrowstatus join book b on barrowstatus.bookID = b.bookID
            where ReturnDate is null and curdate() > Deadline order by latency desc ;
        else
            set error_message = 'you do not have access to this field';
            rollback ;
        end if;
    else
        set error_message = 'please log in first';
        rollback;
    end if;
end;



create procedure check_book_logs(
    in p_tag varchar(100),
    in which_book int,
    out error_message varchar(300)
)
begin
    select userName,user_type_id into @user , @id from user where p_tag = tag;
    if @user is not null then
        if @id = 1 or @id = 2 then
            select logs , bookID from barrowstatus join loginbox l on barrowstatus.userName = l.userName
            where bookID = which_book order by log_date desc;
        else
            set error_message = 'you do not have access to this field';
            rollback ;
        end if;
    else
        set error_message = 'please log in first';
        rollback;
    end if;
end;

create procedure check_user_activity(
    in p_tag varchar(100),
    in inp_userName varchar(20),
    out error_message varchar(300)
)
begin
    select userName,user_type_id into @user , @id from user where p_tag = tag;
    if @user is not null then
        if @id = 1 or @id = 2 then
            select distinct FirstName , LastName , PhoneNumber , Address , user_type , Withdrawal, history
            from user natural join barrowstatus natural join usertype
            where user.userName = inp_userName and user.user_type_id = usertype.user_type_id;
        else
            set error_message = 'you do not have access to this field';
            rollback ;
        end if;
    else
        set error_message = 'please log in first';
        rollback;
    end if;
end;

create procedure remove_user(
     in p_tag varchar(100),
     in inp_userName varchar(20),
     out error_message varchar(300)
)
begin
    select userName,user_type_id into @user , @id from user where p_tag = tag;
    if @user is not null then
        if @id = 1  then
            SET FOREIGN_KEY_CHECKS=0;
            delete from barrowstatus where userName = inp_userName;
            delete from loginbox where userName = inp_userName;
            delete from user where userName = inp_userName;
            commit;
            set error_message = 'user removed';
            SET FOREIGN_KEY_CHECKS=1;

        else
            set error_message = 'you do not have access to this field';
            rollback ;
        end if;
    else
        set error_message = 'please log in first';
        rollback;
    end if;
end;
