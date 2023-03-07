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

