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

-- Add shift
create or replace function add_shift(
	staff_id int,
	shift_from time,
	shift_end time,
	shift_date date
)
returns void
as $$
begin 
	insert into shifts(staff_id, shift_from, shift_end, shift_date) values (staff_id, shift_from, shift_end, shift_date);
end
$$
language plpgsql;

create or replace function update_shift(
	fshift_id int,
	fshift_from time,
	fshift_end time,
	fshift_date date
)
returns void
as $$
begin 
	update shifts set shift_from = fshift_from, shift_end = fshift_end, shift_date = fshift_date 
	where shift_id = fshift_id;
end
$$
language plpgsql;

--ultil func
create or replace function getRanking(CID int)
returns varchar(10) 
as $$
declare 
spending numeric(10,2);
begin
    select c.total_spendings into spending from customers c where c.customer_id = CID; 
    if spending >= 500 then
        return 'Diamond';
    elsif spending >= 200 then 
        return 'Gold';
    else 
        return 'Silver';
end if;
end;
$$ 
language plpgsql;

create or replace function getSaleOff(CID int)
returns numeric(3,1)
as $$
declare 
spending numeric(10,2);
begin
    select c.total_spendings into spending from customers c where c.customer_id = CID; 
    if spending >= 500 then
        return 0.2;
    elsif spending >= 200 then 
        return 0.1;
    else 
        return 0;
end if;
end;
$$ 
language plpgsql;

create or replace function getLateFee(BID int)
returns numeric(6,2)
as $$
declare
due_d date;
return_d date;
begin
select bl.return_date, bl.due_date into return_d, due_d from borrowlines bl where bl.borrowline_id = BID;
if (return_d is not null and return_d > due_d)
then  
    return  2*(return_d::date - due_d::date);
elsif (return_d is not null and return_d < due_d)
then
    return 0;
end if;
end;
$$
language plpgsql;

create or replace function getFinalPrice(BID int)
returns numeric(10,2)
as $$
declare
saleoff numeric(2,1);
price numeric(4,2);
latefee numeric(4,1);
begin
    select getSaleOff(bl.customer_id), getLateFee(bl.borrowline_id) into saleoff, latefee 
    from borrowlines bl join customers c on bl.customer_id = c.customer_id;
    select (bl.due_date::date - bl.borrow_date::date)*0.01*b.base_price into price
    from borrowlines bl join books b on bl.ISBN = b.ISBN;
    return price*(1-saleoff) + latefee;
    
end;
$$
language plpgsql;

create or replace function getShiftWage(SID int)
returns numeric(8,2)
as $$
declare 
weekday int;
shift_last numeric(4,2);
salary numeric(6,2);
begin 
    select extract(isodow from shift_date)+1, extract(epoch from (shift_end - shift_from)/3600) into weekday, shift_last
    from shifts;

    select s.base_salary
    into salary
    from shifts sh join staff s on sh.staff_id = s.staff_id;

    if (weekday between 2 and 6) then
        return salary*shift_last;
    elsif (weekday in (7,8)) then   
        return 1.5*salary*shift_last;
    end if;
end;
$$
language plpgsql;

create or replace function getSalary(date_start date, date_end date)
returns query;
