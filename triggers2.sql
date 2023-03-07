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
		
		update customers
		set total_spendings = total_spendings + get_final_price(new.borrowline_id) - get_late_fee(new.borrowline_id)
		where customer_id = new.customer_id;
   
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

-- Check if the same staff has 2 overlapping shifts
create or replace function check_shift_overlap()
returns trigger as
$$
declare
	shift_exists int;
begin
	if tg_op = 'INSERT' then
        select count(*) into shift_exists
		from shifts
		where staff_id = new.staff_id and shift_date = new.shift_date and (
			(new.shift_from <= shift_end and new.shift_from >= shift_from) or 
			(new.shift_end <= shift_end and new.shift_end >= shift_from) or 
			(new.shift_from <= shift_from and new.shift_end >= shift_end)
		);
	elsif tg_op = 'UPDATE' then
		select count(*) into shift_exists
		from shifts
		where staff_id = new.staff_id and shift_date = new.shift_date and (shift_id != old.shift_id) and (
			(new.shift_from <= shift_end and new.shift_from >= shift_from) or 
			(new.shift_end <= shift_end and new.shift_end >= shift_from) or 
			(new.shift_from <= shift_from and new.shift_end >= shift_end)
		);
    end if;
	

	if shift_exists > 0 then
		raise exception 'Shift overlaps with existing shift for staff % on %', new.staff_id, new.shift_date;
	end if;
	return new;
end;
$$
language plpgsql;

create trigger check_shift_overlap
before insert or update on shifts
for each row
execute function check_shift_overlap();