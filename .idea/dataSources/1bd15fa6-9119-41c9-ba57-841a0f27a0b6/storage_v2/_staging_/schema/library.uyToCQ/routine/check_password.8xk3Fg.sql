create
    definer = root@localhost procedure check_password(IN p_password varchar(255), OUT error_message varchar(300))
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

