import itertools
import sys
import msvcrt
from mysql.connector import connect, Error
import mysql.connector
from datetime import datetime
import getpass
from pprint import pprint
import random


mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password="1234",
    database="library"
)

my_cursor = mydb.cursor()


def user_login():
    customer_tag = ''
    output_message = ''
    tag = ''
    customer_type = ''
    while True:
        print('1. sign in')
        print('2. sign up')
        choice = input()
        if choice == '1':
            print('please enter username')
            username = input()
            print('please enter your password')
            try:
                p = getpass.getpass()
            except Exception as error:
                print('ERROR', error)
            else:
                output = my_cursor.callproc('user_sign_in', (username, p , tag, output_message))
                customer_tag = output[2]
                if output[-1] == 'successfully login':
                    print(f'welcome {username}')
                    return customer_tag
                print(output[-1])
        if choice == '2':
            print('please enter your first name')
            first_name = input()
            print('enter your last name')
            last_name = input()
            while True:
                print('choose a username')
                username = input()
                output = my_cursor.callproc('check_username', (username, output_message))
                if output[-1] is None:
                    break
                print('Error ', output[-1])
            while True:
                print('enter your password')
                enter_pass = getpass.getpass()
                print('confirm your password')
                confirm_pass = getpass.getpass()
                if enter_pass == confirm_pass:
                    break
                else:
                    print('passwords are not match')
            print('enter your phone number')
            phone_number = input()
            print('enter your address')
            address = input()
            print('choose your account type')
            print(' 1. Manager \n 2. Librarian \n 3. Teacher \n 4. Student \n 5. Ordinaries')
            ch = input()
            customer_type = ch
            insert = my_cursor.callproc('create_account', (username, enter_pass, datetime.today().strftime('%Y-%m-%d'), first_name, last_name, phone_number, address,customer_type, tag, output_message))
            customer_tag = insert[-2]
            print(insert[-1])
            return customer_tag


def user_accessibility(tag):
    output_message = ''
    uid = ''
    out = my_cursor.callproc('get_user_type', (tag , uid))
    user_id = out[1]
    while True:
        if user_id == 1:
            print(' 1. sign out \n 2. search a book \n 3. barrow books \n 4. return books \n 5. Increase credit \n 6. my profile \n 7. add book \n 8. search user \n 9. see user data \n 10. see requests \n 11. remove user')
        if user_id == 2:
            print(' 1. sign out \n 2. search a book \n 3. barrow books \n 4. return books \n 5. Increase credit \n 6. my profile \n 7. add book \n 8. search user \n 9. see user data \n 10. see requests ')
        if user_id == 3 or user_id == 4 or user_id == 5:
            print(' 1. sign out \n 2. search a book \n 3. barrow books \n 4. return books \n 5. Increase credit \n 6. my profile')
        choice = input()
        if choice == '1':
            my_cursor.callproc('sign_out' , (tag ,))
            break
        if choice == '2':
            print('please fill any of the field below that you know leave the others empty')

            book_title = input('Book title>> ')
            book_author = input('Book author>> ')
            book_edition = input('Book edition>> ')
            book_publish_date = input('Publish date>> ')
            if book_publish_date == '':
                book_publish_date = None
            if book_edition == '':
                book_edition = 0
            if book_title == '':
                book_title = None
            if book_author == '':
                book_author = None
            my_cursor.callproc('search_book', (book_title , book_author , book_publish_date , book_edition))
            for result in my_cursor.stored_results():
                a = result.fetchall()
                for i in a:
                    print(i)
        if choice == '3':
            print('please enter the id of book you want to barrow ')
            book_id = input()
            output = my_cursor.callproc('barrow_book', (tag, book_id , output_message))
            print(output[2])

        if choice == '5' :
            while True:
                print('how much do you want to add to your credit')
                credit = input()
                out0 = my_cursor.callproc('increase_credit' , (tag , credit , output_message))
                if out0[2] == 'credit updated':
                    print(out0[2])
                    break
                print(out0[2])
        if choice == '6':
            username , activation_date ,first_name, last_name, phone_number, address, customer_type , account_withdrawal ='','','','','','','',''
            out1 = my_cursor.callproc('user_system_data' , (tag , username , activation_date))
            out = my_cursor.callproc('user_personal_data' , (tag , first_name , last_name , phone_number , address , customer_type , account_withdrawal))
            print('personal data : ' , '\nFirst Name :' , out[1] , '\nLast Name : ' , out[2] , '\nPhone Number : ' , out[3] , '\nAddress : ' , out[4] , '\nType of user : ' , out[5] , '\nAccount withdrawal : ' , out[6])
            print('System data : ' , '\nUsername : ' , out1[1] , '\nActivation date : ' , out1[2])
        if (user_id == 1 or user_id == 2) and choice == '7':
            print('fill below information to add the book please do not let any field empty')
            book_volume = input('Book volume>> ')
            book_title = input('Book title>> ')
            book_category = input('Category of book must be an integer value>> ')
            book_num_of_page = input('Number of pages>> ')
            book_price = input('Book price>> ')
            book_author = input('Book author>> ')
            book_edition = input('Book edition>> ')
            book_publish_date = input('Publish date>> ')
            book_publisher_name = input('Book publisher>> ')
            out = my_cursor.callproc('add_book' , (tag ,book_volume , book_title , book_category , book_num_of_page , book_price , book_author , book_edition , book_publish_date , book_publisher_name , output_message))
            print(out[10])
        if (user_id == 1 or user_id == 2) and choice == '8':
            print('please fill any of the field below that you want to search on leave the others empty')

            user_name = input('Username>> ')
            user_last_name = input('Last name>> ')
            if user_name == '':
                user_name = None
            if user_last_name == '':
                user_last_name = None
            out = my_cursor.callproc('search_user', (tag , user_name, user_last_name , 5 , 0, output_message))
            for result in my_cursor.stored_results():
                a = result.fetchall()
                for i in a :
                    print(i)
            if out[5] is not None:
                print(out[5])


# userTag = user_login()
# user_accessibility(userTag)




err =''
outt = my_cursor.callproc('check_password', ('hello' , err))
print(outt)

# 'Brondon Mull'

# insert = my_cursor.callproc('create_account', (username, enter_pass, datetime.today().strftime('%Y/%m/%d'), first_name, last_name, phone_number, address,customer_type, output_message))
# output_message = ''

