--Admin
create or replace function add_Book(varchar(20) ISBNf, titlef varchar(50), descriptionf varchar(100), varchar(50) author_n, varchar(50) category_n, varchar(50) publisher_n)
language plpgsql
as $$
begin

end
$$;

create or replace function add_Author(varchar(50) author_n)
language plpgsql
as $$
begin
if not exists (select * from author
                where author_name = author_n)
begin
    insert into author(author_name) values (author_n);
end
end
$$;

create or replace function add_Category(varchar(50) category_n)
language plpgsql
as $$
begin
if not exists (select * from category
                where category_name = category_n)
begin
    insert into category(category_name) values (category_n);
end
end
$$;

create or replace function add_Publisher(varchar(50) publisher_n, varchar(50) country_f)
language plpgsql
as $$
begin
if not exists (select * from publisher
                where publisher_name = publisher_n)
begin
    insert into publisher(publisher_name, country_from) values (publisher_n, country_f);
end
end
$$;

create or replace function add_People()

create or replace function cal_Salary(int month_sal, int year_sal)
returns table(int staff_idf, numeric(10,2) salary)
language plpgsql
as $$
begin
return query select staff_id, 
end
$$
