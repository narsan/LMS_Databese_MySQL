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
#     ALTER TABLE customeraccount
#     ADD CONSTRAINT CHECK (p_password like '%[0-9]%' AND (p_password like '%[a-z]%' or p_password like '%[A-Z]%'));
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
    out error_message varchar(300)
)
begin
    declare position int ;
    declare contain_letter boolean;
    declare contain_number boolean;
    set position = 1;
    set contain_letter = false;
    set contain_number = false;
    IF CHAR_LENGTH(p_password) < 8 then
            set  error_message = 'An error has occurred, password should have more than 8 character';
    else
    my_loop: LOOP
            if position > CHAR_LENGTH(p_password) then
                leave my_loop;
            end if;

            if substring(p_password , position , 1) like '[a-z]' then
                set contain_letter = true;
                set position = position+1;
            end if;
            if substring(p_password , position , 1) like '[0-9]' then
                set contain_number = true;
                set position = position+1;
            end if;
            if substring(p_password , position , 1) like '[A-Z]' then
                set contain_letter = true;
                set position = position+1;
            end if;

        end LOOP my_loop;
        if contain_letter != true or contain_number != true then
            set error_message = 'password must contain number and letter';
        else
            set error_message = 'valiiid';
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
    in p_tag varchar(100),
    out p_username varchar(20),
    out p_activateDate nchar(20)
)
begin
    select username INTO @user from user where tag = p_tag;
    IF @user is not NULL then
        select username , activationDate into @name , @date from user where userName = @user;
        set p_username = @name;
        set p_activateDate = @date;
    end if;

end;


create procedure user_personal_data(
    in p_tag varchar(100),
    out p_FirstName nchar(50),
    out p_LastName nchar(50),
    out p_PhoneNumber varchar(12),
    out p_Address varchar(200),
    out customerTypeID nchar(20),
    out p_Withdrawal integer
)
begin
    select username INTO @user from user where tag = p_tag;
    IF @user is not NULL then
        select FirstName , LastName , PhoneNumber , Address , user_type_id , Withdrawal INTO @firs , @last , @num , @adrs , @typeID , @count
        from user where userName = @user;
        select user_type into @type from usertype where user_type_id = @typeID;
        set p_FirstName = @firs;
        set p_LastName = @last;
        set p_PhoneNumber = @num;
        set p_Address = @adrs;
        set customerTypeID = @type;
        set p_Withdrawal = @count;
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
     SET SQL_SAFE_UPDATES=0;
     update user set Withdrawal = Withdrawal + credit where tag = p_tag;
     set error_message = 'credit updated';
     commit;
     IF credit < 1000 Then
         set error_message = 'you entered an invalid number please try again';
         rollback ;
     end if;

end;


create procedure search_book(
#     in p_tag varchar(100),
    in book_title nchar(100),
    in book_Author nchar (20),
    in book_publish_date date,
    in book_edition integer
#     out result varchar(300)
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
end;

# create trigger log_inbox after update on barrowstatus
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


end;