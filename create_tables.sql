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
	person_id int unique not null, --fk
	base_salary numeric(10, 2) not null default 15 check(base_salary >= 0),
	hire_date date,	
	
	constraint fk_staff_person 
		foreign key (person_id) references people(person_id)
		on delete set null
		on update cascade
);

create table customers(
	customer_id serial not null primary key,
	person_id int unique not null, --fk
	date_registered date not null,
	total_spendings numeric(10, 2) default 0 check (total_spendings >= 0),
	
	constraint fk_customer_person 
		foreign key (person_id) references people(person_id)
		on delete set null
		on update cascade
);

create table books(
	ISBN varchar(20) not null primary key,
	title varchar(50) not null,
	description varchar(100),
	author_name varchar(50), -- fk
	category varchar(50), --fk
	publisher_name varchar(50), -- fk
	number_of_pages int not null,
	language_code varchar(3),
	cur_quantity int not null check(cur_quantity > 0),
	base_price numeric(6,2) not null check(base_price > 0)
);

-- Borrow-related tables
create table borrowlines(
	borrowline_id serial not null primary key,
	staff_id int not null, --fk
	customer_id int not null, --fk
	ISBN varchar(30) not null, --fk
	quantity int not null,
	borrow_date date not null default CURRENT_DATE,
	due_date date not null,
	return_date date default null,
	rating numeric(4, 2) default null check(rating between 0 and 10),

	constraint fk_ISBN foreign key (ISBN) references books(ISBN)
		on delete set null
		on update cascade,
	constraint fk_staff foreign key (staff_id) references staff(staff_id)
		on delete set null
		on update cascade,
	constraint fk_customer foreign key (customer_id) references customers(customer_id)
		on delete set null
		on update cascade,
	constraint date_validity check(due_date >= borrow_date)
);

create table shifts(
	shift_id serial not null primary key,
	staff_id int not null, -- fk
	shift_from time,
	shift_end time,
	shift_date date,
	constraint fk_shift_staffid foreign key (staff_id) references staff(staff_id)
		on delete set null
		on update cascade,
	constraint shift_time_check check(shift_end > shift_from)
);