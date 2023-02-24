--Admin
--Calculate salary
create or replace function cal_salary(month_sal int, year_sal int)
returns table(staff_idf int, salary numeric(10,2))
as $$
begin
return query 
	select staff.staff_id, COALESCE( swf.wage_final, 0 )
	from staff left join
    (select staff_id, sum(wage_final) as wage_final
	from shifts
	where extract(month from shift_date) = month_sal and extract(year from shift_date) = year_sal
	group by (staff_id)) as swf
	on swf.staff_id = staff.staff_id
	;
end;
$$
language plpgsql;

--cal shift hours
-- create or replace function cal_shift_hour(month_sal int, year_sal int)
-- returns table(staff_idf int, person_n varchar(50), shift_h numeric(3,2))
-- as $$
-- begin
-- return query
--     select st.staff_id, pp.person_name, shm.hour_per_month
--     from staff st
--     join (select sum(cast(extract(epoch from (shift_end - shift_from))/3600 as numeric(3,2))) as hour_per_month
--             from shifts sh
--             where date_part('month', sh.shift_from) = month_sal and date_part('year', sh.shift_from) = year_sal
--             group by sh.staff_id
--         ) shm on st.staff_id = shm.staff_id
--     join people pp on pp.person_id = st.person_id;  
-- end;
-- $$
-- language plpgsql;

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
    insert into people(account_name, pass, person_name, dob, gender, house_number, street, city, country, email, phone_number, rolef)
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
    book_customer_rating numeric(2,2),
    book_cur_quantity int) 
returns void as 
$$
begin
	if not exists (select 1 from books where ISBN = book_ISBN) then
		insert into books (ISBN, title, description, author_name, category, publisher_name, number_of_pages, language_code, customer_rating, cur_quantity)
  		values (book_ISBN, book_title, book_description, book_author_name, book_category, book_publisher_name, book_number_of_pages, book_language_code, book_customer_rating, book_cur_quantity);
	else
	update books 
	set cur_quantity = cur_quantity + book_cur_quantity
	where ISBN = book_ISBN;
	end if;
end;
$$ language plpgsql;

create or replace function borrow_book(
	staff_id int,
	customer_id int, 
	ISBN varchar(20), 
	quantity int, 
	late_fee numeric(10, 2), 
	borrow_date date, 
	due_date date, 
	price numeric(10, 2) 
)
returns void
as
$$
begin
	INSERT INTO borrowlines(staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price)
	values(staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price);
end;
$$ language plpgsql;
-- drop function search_book
create or replace function search_book(
	pISBN varchar(20),
	ptitle varchar(50), 
	pauthor_name varchar(50),
	pcategory varchar(50),
	planguage_code varchar(3)
)
returns table(
	rISBN varchar(20), 
	rtitle varchar(50), 
	rauthor_name varchar(50),
	rcategory varchar(50),
	rpublisher_name varchar(50), 
	rlanguage_code varchar(3),
	rcustomer_rating numeric(2,1)) 
as
$$
begin
return query 
	select ISBN, title, author_name, category, publisher_name, language_code, customer_rating
	from books where
	(pISBN is null or ISBN like concat('%',pISBN,'%')) and
	(ptitle is null or title like concat('%',ptitle,'%')) and
	(pauthor_name is null or author_name like concat('%',pauthor_name,'%')) and
	(pcategory is null or category like concat('%',pcategory,'%'));
end
$$ language plpgsql

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

-- Rate a book
-- create or replace function rate_book(
-- 	pISBN varchar(20),
-- 	prating numeric(2,1)
-- )
-- returns void as
-- $$
-- begin
	
-- end
-- $$ language plpgsql;














