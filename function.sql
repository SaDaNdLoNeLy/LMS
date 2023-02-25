--Admin
--cal salary
create or replace function cal_salary(month_sal int, year_sal int)
returns table(staff_idf int,person_n varchar(50), salary numeric(10,2))
as $$
begin
return query 
    select st.staff_id, pp.person_name, (st.base_salary + shm.wage_on_shift)
    from staff st 
    join (select sum(wage_final) as wage_on_shift
            from shifts sh
            where date_part('month', sh.shift_date) = month_sal and date_part('year', sh.shift_date) = year_sal
            group by sh.staff_id
        ) shm on st.staff_id = shm.staff_id
    join people pp on pp.person_id = st.person_id;         
end;
$$
language plpgsql;

--cal shift hours
create or replace function cal_shift_hour(date_from date, date_end date)
returns table(staff_idf int, person_n varchar(50), shift_h numeric(3,2))
as $$
begin
return query
    select st.staff_id, pp.person_name, shm.hour_per_month
    from staff st
    join (select sum(cast(extract(epoch from (shift_end - shift_from))/3600 as numeric(4,2))) as hour_per_month
            from shifts sh
            where sh.shift_date >= date_from and sh.shift_date <= date_end
            group by sh.staff_id
        ) shm on st.staff_id = shm.staff_id
    join people pp on pp.person_id = st.person_id;  
end;
$$
language plpgsql;

create or replace function add_person(
    account_namef varchar(50), 
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
    rolef varchar(20)
)
returns void
as $$
begin
if not exists (select * from people pp
            where pp.person_name = person_namef
            and pp.phone_number = phone_numberf) and rolef in ('customer', 'staff')
then
    insert into people(account_name, pass, person_name, dob, gender, house_number, street, city, country, email, phone_number, rolef)
    values (account_namef, passf, person_namef, dobf, genderf, house_numberf, streetf, cityf, countryf, emailf, phone_numberf, rolef);
end if;
end;
$$
language plpgsql;

create or replace function add_shift(
    staff_idf int,
    shift_fromf time,
    shift_endf time,
    shift_datef date
)
returns void
as $$
begin
insert into shifts(staff_id, shift_from, shift_end, shift_date)
values (staff_idf, shift_fromf, shift_endf, shift_datef);
end;
$$
language plpgsql;

create or replace function find_shift_info(time_from timestamp, time_to timestamp)
returns shift_list
as $$
begin
select sh.*, pp.person_name from shift sh 
join staff st on sh.staff_id = st.staff_id
join people pp on pp.person_id = st.person_id
where (time_from::timestamp::time < sh.shift_from) 
and (time_from::timestamp::time > sh.shift_end)
and (sh.shift_date between time_from::timestamp::date and time_end::timestamp::date)
end;
$$
language plpgsql;

--Staff
create or replace function add_customer(
    account_namef varchar(50), 
    passf varchar(50), 
    person_namef varchar(50), 
    dobf date, 
    genderf varchar(20),
    house_numberf varchar(20), 
    streetf varchar(20), 
    cityf varchar(20), 
    countryf varchar(20), 
    emailf varchar(50) , 
    phone_numberf varchar(50)
)
returns void
as $$
declare rolef varchar(20) := 'customer';
begin
if not exists (select * from people pp
                where pp.person_name = person_namef
                and pp.phone_number = phone_numberf) and rolef in ('customer', 'staff')
then
    insert into people(account_name, pass, person_name, dob, gender, house_number, street, city, country, email, phone_number, rolef)
    values (account_namef, passf, person_namef, dobf, genderf, house_numberf, streetf, cityf, countryf, emailf, phone_numberf, rolef);
    
end if;
end;
$$
language plpgsql;

--Customer

create or replace function search_book(titlef varchar(50))
returns table(
    ISBN varchar(20), 
    title varchar(50), 
    description varchar(100), 
    author_name varchar(50),
    category varchar(50), 
    publisher_name varchar(50), 
    number_of_pages int, 
    language_code varchar(3), 
    customer_rating numeric(2,2), 
    cur_quantity int)
as $$
begin
select * from books where books.title = titlef;
end;
$$
language plpgsql;

create or replace function borrow_book( 
    ISBNf varchar(20),
    staff_idf int,
    customer_idf int, 
    quantityf int, 
    borrow_time interval
)     
returns void
as $$
begin
if not exists (select * from books b where b.ISBN = ISBNf and b.cur_quantity >0) and (quantityf<5)
then
    insert into borrowlines(staff_id, customer_id, ISBN, quantity, borrow_date, due_date)
    values (staff_idf, customer_idf, ISBNf, quantityf, CURRENT_DATE, CURRENT_DATE+borrow_time);
end if;
end;
$$
language plpgsql;

create or replace function return_book (
    ISBNf varchar(20),
    customer_idf int,
    borrow_datef date,
    quantityf int,
    ratingf numeric(2,2)
)
returns void
as $$
begin
if exists (select * from borrowlines bl where bl.ISBN = ISBNf 
            and bl.customer_id = customer_idf
            and bl.borrow_date = borrow_datef
            and bl.quantity = quantityf) 
then
    update borrowlines 
    set return_date = CURRENT_DATE,
        rating = ratingf
    where ISBN = ISBNf and customer_id = customer_idf 
    and borrow_datef = borrow_date and quantityf = quantity;
end if;
end;
$$
language plpgsql;

create or replace function list_books(
    categoryf varchar(50)
)
returns table(
	ISBN varchar(20),
	title varchar(50),
	description varchar(100),
	author_name varchar(50),
	category varchar(50),
	publisher_name varchar(50),
	number_of_pages int,
	language_code varchar(3),
	customer_rating numeric(2,2),
	cur_quantity int
)
as $$
begin
if categoryf is null then
	return query
    select * from books order by customer_rating DESC;
else
	return query
    select * from books where books.category = categoryf order by customer_rating DESC;
end if;
end;
$$
language plpgsql;

create or replace function check_history(customer_idf int)
returns table(
	borrow_id int, 
	staff_id int, 
	customer_id int,
	book_title varchar(50),
	quantity int,
	borrow_date date,
	due_date date,
	return_date date,
	expenditure numeric(10,2),
	rating numeric(2,2))
as $$
begin
return query
select bl.borrowline_id, bl.staff_id, bl.customer_id, b.title, bl.quantity, bl.borrow_date, bl.due_date, bl.return_date, bl.price, bl.rating from borrowlines bl 
join books b on bl.ISBN = b.ISBN
where bl.customer_id = customer_idf;
end;
$$
language plpgsql;