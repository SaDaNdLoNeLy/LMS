-- Validation Triggers 
create or replace function validate_borrowline()
returns trigger as 
$$
begin	
	update borrows
	set total_cost = total_cost + new.price + new.late_fee
	where borrow_id = new.borrow_id;
	
	return new;
end;
$$
language plpgsql;

create trigger borrowlines_validate_trigger before insert or update on borrowlines
for each row execute function validate_borrowline();

-- Create new staff
create or replace function add_person() returns trigger as $$
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

-- Update total_spending of customer after each borrow, and update ranking if necessary
create or replace function update_customer_ranking()
returns trigger as 
$$
declare
    new_ranking varchar(20);
begin
    -- update total_spendings for the borrowing customer
    update customers
    set total_spendings = total_spendings + new.total_cost
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
after insert on borrows
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

-- Addin trigger
