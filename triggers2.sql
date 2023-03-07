--
create or replace function update_cur_quantity() 
returns trigger as 
$$
declare
    borrowed_quantity integer;
begin
    if (TG_OP = 'INSERT') then  -- if a book is borrowed
        borrowed_quantity := new.quantity;
        update books 
		set cur_quantity = cur_quantity - borrowed_quantity  
		where ISBN = new.ISBN;
   
	elsif (TG_OP = 'UPDATE' and old.return_date is null and new.return_date is not null) then  -- if a book is returned
        borrowed_quantity := new.quantity;
        update books 
		set cur_quantity = cur_quantity + borrowed_quantity 
		where ISBN = new.ISBN;
    end if;
    return new;
end;
$$ 
language plpgsql;

-- drop trigger update_cur_quantity_trigger on borrowlines
create trigger update_cur_quantity_trigger
after insert or update on borrowlines
for each row
execute function update_cur_quantity();



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
    insert into customers (customer_id, person_id, date_registered, total_spendings)
    values (default, new.person_id, current_date, 0);
  end if;
  
  return new;
end;
$$ language plpgsql;

create trigger add_person_trigger
after insert on people
for each row
execute function add_person();

-- Check availability of book before borrow
create or replace function check_book_availability() 
returns trigger as 
$$
declare current_quantity int;
begin
    if tg_op = 'INSERT' then
        select cur_quantity into strict current_quantity from books where ISBN = new.ISBN;
        if current_quantity < new.quantity then
            raise exception 'The book(s) are not available';
        end if;
    end if;
    return new;
end;
$$ 
language plpgsql;

-- drop trigger check_book_availability_trigger on borrowlines
create trigger check_book_availability_trigger
before insert on borrowlines
for each row
execute function check_book_availability();
