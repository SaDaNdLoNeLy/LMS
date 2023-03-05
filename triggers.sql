-- Calculate Late fee and Update quantity of book
create or replace function calculate_late_fee()
returns trigger as 
$$
declare 
	number_of_late_days float;
begin
	if old.return_date is null and new.return_date is not null then
	
		if (new.return_date > new.due_date) then
			number_of_late_days :=  new.return_date - new.due_date;

			update borrowlines
			set late_fee = number_of_late_days
			where borrowline_id = new.borrowline_id;

		end if;
	end if;
	return new;
end;
$$
language plpgsql;

-- drop trigger get_late_fee on borrowlines
create trigger get_late_fee
after update on borrowlines
for each row
execute function calculate_late_fee();


-- Update sale_off amount and total_spending of customer after each borrow, and update ranking if necessary
create or replace function update_customer_ranking()
returns trigger as 
$$
declare
    new_ranking varchar(20);
	discount float;
begin
	-- update discount, 20% if platinum, 10% if gold	
	if ((select ranking from customers where customer_id = new.customer_id) = 'gold') then
		update borrowlines
		set sale_off = 0.1 * new.price
		where borrowline_id = new.borrowline_id;
		discount := 0.1 * new.price;
	
	elsif ((select ranking from customers where customer_id = new.customer_id) = 'platinum') then
		update borrowlines
		set sale_off = 0.2 * new.price
		where borrowline_id = new.borrowline_id;
		discount := 0.2 * new.price;
		
	end if;
	
    -- update total_spendings for the borrowing customer
    update customers
    set total_spendings = total_spendings + new.price - discount
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

-- drop trigger update_customer_ranking_trigger on borrowlines

create trigger update_customer_ranking_trigger
after insert on borrowlines
for each row
execute function update_customer_ranking();



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

-- Calculate Final Wage of a Shift
create or replace function calculate_final_wage()
returns trigger as 
$$
declare 
	hourly_rate integer;
	working_hours numeric(10, 2);
begin
	select base_salary into hourly_rate from staff where staff.staff_id = new.staff_id;
	if (new.week_day >= 7) then -- weekend: 20$/hour
		hourly_rate := 1.5 * hourly_rate;
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

-- Check if the same staff has 2 overlapping shifts
create or replace function check_shift_overlap()
returns trigger as
$$
declare
	shift_exists int;
begin
	select count(*) into shift_exists
	from shifts
	where staff_id = new.staff_id and shift_date = new.shift_date and (
		(new.shift_from <= shift_end and new.shift_from >= shift_from) or 
		(new.shift_end <= shift_end and new.shift_end >= shift_from) or 
		(new.shift_from <= shift_from and new.shift_end >= shift_end)
	);

	if shift_exists > 0 then
		raise exception 'Shift overlaps with existing shift for staff % on %', new.staff_id, new.shift_date;
	end if;
	return new;
end;
$$
language plpgsql;

create trigger check_shift_overlap
before insert on shifts
for each row
execute function check_shift_overlap();