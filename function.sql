--Admin
--cal salary
create or replace function cal_salary(month_sal int, year_sal int)
returns table(staff_idf int,person_n varchar(50), salary numeric(10,2))
as $$
begin
return query 
    select st.staff_id, person_name, (st.base_salary + shm.wage_per_month)
    from staff st 
    join (select sum(wage_final) as wage_per_month
            from shifts sh
            where date_part('month', sh.shift_from) = month_sal and date_part('year', sh.shift_from) = year_sal
            group by sh.staff_id
        ) shm on st.staff_id = shm.staff_id
    join people pp on pp.person_id = st.person_id;         
end;
$$
language plpgsql;

--cal shift hours
create or replace function cal_shift_hour(month_sal int, year_sal int)
returns table(staff_idf int, person_n varchar(50), shift_h numeric(3,2))
as $$
begin
return query
    select st.staff_id, pp.person_name, shm.hour_per_month
    from staff st
    join (select sum(cast(extract(epoch from (shift_end - shift_from))/3600 as numeric(3,2))) as hour_per_month
            from shifts sh
            where date_part('month', sh.shift_from) = month_sal and date_part('year', sh.shift_from) = year_sal
            group by sh.staff_id
        ) shm on st.staff_id = shm.staff_id
    join people pp on pp.person_id = st.person_id;  
end;
$$
language plpgsql;

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
    
end if;
end
$$
language plpgsql;

create or replace function add_customer(account_namef varchar(50), 
                                        passf varchar(50), 
                                        person_namef varchar(50), 
                                        dobf date, 
                                        genderf varchar(20),
                                        house_numberf varchar(20), 
                                        streetf varchar(20), 
                                        cityf varchar(20), 
                                        countryf varchar(20), 
                                        emailf varchar(50) , 
                                        phone_numberf varchar(50))
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
end
$$
language plpgsql;

create or repace