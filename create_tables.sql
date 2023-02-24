--related tables

create table people(
	person_id serial not null primary key,
	account_name varchar(50) not null,
	pass varchar(50) not null,
	person_name varchar(50) not null,
	dob date,
	gender varchar(2) check (gender in ('F', 'M')),
	house_number varchar(20),
	street varchar(20), 
	city varchar(20),
	country varchar(20),
	email varchar(50),
	phone_number varchar(50),
	role varchar(20) check (role in ('staff', 'customer'))
);

create table staff(
	staff_id serial not null primary key,
	person_id int not null, --fk
	base_salary numeric(10, 2) not null default 15 check(base_salary >= 0),
	hire_date date,	
	
	constraint fk_staff_person foreign key (person_id) references people(person_id)
);

alter table staff
alter column base_salary set default 15

create table customers(
	customer_id serial not null primary key,
	person_id int not null, --fk
	total_books_borrowed int not null default 0 check(total_books_borrowed >= 0),
	date_registered date not null,
	ranking varchar(20) check (ranking in ('silver', 'gold', 'platinum')),
	total_spendings numeric(10, 2) default 0 check (total_spendings >= 0),
	
	constraint fk_customer_person foreign key (person_id) references people(person_id)
);

-- -- Book-related tables
-- create table author(
-- 	author_id serial not null primary key, 
-- 	author_name varchar(50) not null
-- );

-- create table category(
-- 	category_id serial not null primary key,
-- 	category_name varchar(50) not null
-- );

-- create table publisher(
-- 	publisher_id serial not null primary key,
-- 	publisher_name varchar(50) not null,
-- 	country_from varchar(50)
-- );

create table books(
	ISBN varchar(20) not null primary key,
	title varchar(50) not null,
	description varchar(100),
	author_name varchar(50), -- fk
	category varchar(50), --fk
	publisher_name varchar(50), -- fk
	number_of_pages int not null,
	language_code varchar(3),
	customer_rating numeric(2,1) check(customer_rating <= 10.0),
	cur_quantity int not null check(cur_quantity > 0)
);

-- create table bookitems(
-- 	item_id int not null primary key,
-- 	ISBN int not null, -- fk
-- 	book_type varchar(30) not null,
-- 	price numeric(10, 5),
-- 	bought_from varchar(30),p
-- 	pus varchar(20) check (status in ('available', 'borrowed', 'lost')),
-- 	bought_by int not null, --fk
	
-- 	constraint fk_isbn foreign key (ISBN) references books(ISBN),
-- 	constraint fk_bought_by foreign key (bought_by) references staff(staff_id)
-- );


-- Borrow-related tables
create table borrowlines(
	borrowline_id serial not null primary key,
	staff_id int not null, --fk
	customer_id int not null, --fk
	ISBN varchar(30) not null, --fk
	quantity int not null,
	late_fee numeric(10, 2) default 0,
	borrow_date date not null default CURRENT_DATE,
	due_date date not null,
	return_date date default null,
	sale_off numeric(2,1) default 0,
	price numeric(10, 2) not null,

	constraint fk_ISBN foreign key (ISBN) references books(ISBN),
	constraint fk_staff foreign key (staff_id) references staff(staff_id),
	constraint fk_customer foreign key (customer_id) references customers(customer_id),
	constraint date_validity check(due_date >= borrow_date)
);

-- create table borrows(
-- 	borrow_id serial not null primary key,
-- 	staff_id int not null, --fk
-- 	customer_id int not null, --fk,
-- 	total_cost numeric(10, 3) default 0 check(total_cost >= 0),
	
-- );

create table shifts(
	shift_id serial not null primary key,
	staff_id int not null, -- fk
	shift_from time,
	shift_end time,
	shift_date date,
	week_day int check(week_day >= 2 and week_day <=8),
	wage_per_hr int,
	wage_final numeric(4, 2) default 0,
	constraint fk_shift_staffid foreign key (staff_id) references staff(staff_id)
);