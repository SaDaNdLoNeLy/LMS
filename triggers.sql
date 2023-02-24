-- -- Validation Triggers 
-- create or replace function validate_borrowline()
-- returns trigger as 
-- $$
-- begin	
-- 	update borrows
-- 	set total_cost = total_cost + new.price + new.late_fee
-- 	where borrow_id = new.borrow_id;
	
-- 	return new;
-- end;
-- $$
-- language plpgsql;

-- create trigger borrowlines_validate_trigger before insert or update on borrowlines
-- for each row execute function validate_borrowline();

-- Calculate Late fee
create or replace function calculate_late_fee()
returns trigger as 
$$
declare 
	number_of_late_days integer;
begin
	if (new.return_date > new.due_date) then
		number_of_late_days := extract (epoch from (new.shift_end - new.shift_from))/86400;
		
		update borrowlines
		set new.late_fee = number_of_late_days
		where borrowline_id = new.borrowline_id;
	end if;
end;
$$
language plpgsql;

create trigger get_late_fee
after update on borrowlines
for each row
execute function calculate_late_fee();

-- Create new staff or customer
create or replace function add_person() 
returns trigger as 
$$
begin
  if new.role = 'staff' then
    insert into staff (staff_id, person_id, base_salary, hire_date)
    values (default, new.person_id, default, current_date);
  end if;
  
  if new.role = 'customer' then
    insert into customers (customer_id, person_id, date_registered, ranking)
    values (default, new.person_id, current_date, 'silver');
  end if;
  
  return new;
end;
$$ language plpgsql;

create trigger add_person_trigger
after insert on people
for each row
execute function add_person();

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
	if not exists (select 1 from books where ISBN = new.ISBN) then
		insert into books (ISBN, title, description, author_name, category, publisher_name, number_of_pages, language_code, customer_rating, cur_quantity)
  		values (book_ISBN, book_title, book_description, book_author_name, book_category, book_publisher_name, book_number_of_pages, book_language_code, book_customer_rating, book_cur_quantity);
	else
	update books 
	set cur_quantity = cur_quantity + book_cur_quantity
	where ISBN = book_ISBN;
	end if;
end;
$$ language plpgsql;

-- Update sale_off amount and total_spending of customer after each borrow, and update ranking if necessary
create or replace function update_customer_ranking()
returns trigger as 
$$
declare
    new_ranking varchar(20);
begin
	-- update discount, 20% if platinum, 10% if gold	
	if ((select ranking from customers where customer_id = new.customer_id) = 'gold') then
		update borrowlines
		set sale_off = 0.1 * new.price
		where borrowline_id = new.borrowline_id;
	elsif ((select ranking from customers where customer_id = new.customer_id) = 'platinum') then
		update borrowlines
		set sale_off = 0.2 * new.price
		where borrowline_id = new.borrowline_id;
	end if;
	
    -- update total_spendings for the borrowing customer
    update customers
    set total_spendings = total_spendings + new.price - new.sale_off
    where customer_id = new.customer_id;
    
    -- determine new ranking based on total_spendings
    select case
        when total_spendings < 50 then 'silver'
        when total_spendings <= 200 then 'gold'
        else 'platinum'
    end into new_ranking
	
    from customers
    where customer_id = new.customer_id;
    
    -- update ranking for the borrowing customer
    update customers
    set ranking = new_ranking
    where customer_id = new.customer_id;
    
    return new;
end;
$$ 
language plpgsql;

create trigger update_customer_ranking_trigger
after insert on borrowlines
for each row
execute function update_customer_ranking();

--
create or replace function update_cur_quantity() 
returns trigger as 
$$
declare
    borrowed_quantity integer;
begin
    if (tg_op = 'insert') then  -- if a book is borrowed
        borrowed_quantity := new.quantity;
        update books set cur_quantity = cur_quantity - borrowed_quantity where ISBN = new.ISBN;
    
	elsif (tg_op = 'update') then  -- if a book is returned
        borrowed_quantity := old.quantity - new.quantity;
        update books set cur_quantity = cur_quantity + borrowed_quantity where ISBN = old.ISBN;
    end if;
    return new;
end;
$$ 
language plpgsql;

create trigger update_cur_quantity_trigger
after insert or update on borrowlines
for each row
execute function update_cur_quantity();

-- Check availability of book before borrow
create or replace function check_book_availability() 
returns trigger as 
$$
declare current_quantity int;
begin
    if tg_op = 'insert' then
        select cur_quantity into strict current_quantity from books where ISBN = new.ISBN;
        if current_quantity < new.quantity then
            raise exception 'The book(s) are not available';
        end if;
    end if;
    return new;
end;
$$ 
language plpgsql;

create trigger check_book_availability_trigger
before insert on borrowlines
for each row
execute function check_book_availability();

-- Calculate Final Wage of a Shift
create or replace function calculate_final_wage()
returns trigger as 
$$
declare 
	hourly_rate integer;
	working_hours numeric(10, 2);
begin
	if (new.week_day >= 7) then -- weekend: 20$/hour
		hourly_rate := 20;
	else 
		hourly_rate := 15;
	end if;
	
	update shifts
	set wage_per_hr = hourly_rate
	where shift_id = new.shift_id;
	
	working_hours := extract (epoch from (new.shift_end - new.shift_from))/3600;
	update shifts
	set wage_final = hourly_rate * working_hours
	where shift_id = new.shift_id;
	
	return new;
end;
$$
language plpgsql;

create trigger get_final_wage
after insert on shifts
for each row
execute function calculate_final_wage();