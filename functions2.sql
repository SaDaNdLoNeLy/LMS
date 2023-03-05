create or replace function add_person(account_namef varchar(50), 
                                        passf varchar(50), 
                                        person_namef varchar(50), 
                                        dobf date, 
                                        genderf varchar(20),
                                        house_numberf varchar(20), 
                                        streetf varchar(20), 
                                        cityf varchar(20), 
                                        countryf varchar(20), 
                                        emailf varchar(50) , 
                                        phone_numberf varchar(50) , 
                                        rolef varchar(20))
returns void
as $$
begin
if not exists (select * from people pp
                where pp.person_name = person_namef
                and pp.phone_number = phone_numberf) and rolef in ('customer', 'staff')
then
    insert into people(account_name, pass, person_name, dob, gender, house_number, street, city, country, email, phone_number, role)
    values (account_namef, passf, person_namef, dobf, genderf, house_numberf, streetf, cityf, countryf, emailf, phone_numberf, rolef);
else raise exception 'Person already exist!!!!!';
end if;
end
$$
language plpgsql;


-- Add a new book to the library
create or replace function add_book(
 	book_ISBN varchar(20),
    book_title varchar(50),
    book_description varchar(100),
    book_author_name varchar(50),
    book_category varchar(50),
    book_publisher_name varchar(50),
    book_number_of_pages int,
    book_language_code varchar(3),
    book_cur_quantity int,
	base_price numeric(4,2)
) 
returns void as 
$$
begin
	if not exists (select 1 from books where ISBN = book_ISBN) then
		insert into books (ISBN, title, description, author_name, category, publisher_name, number_of_pages, language_code, cur_quantity, base_price)
  		values (book_ISBN, book_title, book_description, book_author_name, book_category, book_publisher_name, book_number_of_pages, book_language_code, book_cur_quantity, base_price);
	else
	update books 
	set cur_quantity = cur_quantity + book_cur_quantity
	where ISBN = book_ISBN;
	end if;
end;
$$ language plpgsql;
--  Borrow Book
create or replace function borrow_book(
	staff_id int,
	customer_id int, 
	ISBN varchar(20), 
	quantity int, 
	borrow_date date, 
	due_date date
)
returns void
as
$$
begin
	INSERT INTO borrowlines(staff_id, customer_id, ISBN, quantity, borrow_date, due_date)
	values(staff_id, customer_id, ISBN, quantity, borrow_date, due_date);
end;
$$ language plpgsql;

-- Return book
create or replace function return_book(
	bl_id int,
	date_of_return date
)
returns void
as $$
begin
if not exists (
	select * from borrowlines bl
    where bl.borrowline_id = bl_id
)
then
	raise exception 'There was not any borrow with this ID!';
else 
	update borrowlines
	set return_date = date_of_return
	where borrowlines.borrowline_id = bl_id;
    
end if;
end
$$
language plpgsql;
