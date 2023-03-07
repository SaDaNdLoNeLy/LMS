select * from "add_person"('johnsmith', 'password', 'John Smith', '1980-01-01', 'M', '123', 'Main St', 'New York', 'USA', 'john.smith@example.com', '123-456-7890', 'customer');
select * from "add_person"('staff2', 'password', 'John Smith', '1980-01-01', 'M', '123', 'Main St', 'New York', 'USA', 'staff2@example.com', '123-456-7892', 'staff');
select * from "add_book"('9780141036144', '1984', 'A dystopian novel about life under an oppressive government', 'George Orwell', 'Fiction', 'Penguin Books', 328, 'eng', 10, 200.0)
select * from "borrow_book"(1, 1, '9780141036144', 2, '2022-01-01', '2022-01-08')
select * from "return_book"(3, current_date, 8);
select * from "return_book"(6, current_date, 5);
select * from "add_shift"(1, '13:00:00', '14:00:00', '2023-02-22');
select * from "add_shift"(2, '13:00:00', '14:00:00', '2023-02-22');
select * from "add_shift"(2, '10:00:00', '14:00:00', '2023-02-23');
select * from "update_shift"(1, '9:00:00', '14:00:00', '2023-02-22');
select * from "get_ranking"(1);
select * from "get_final_price"(3);
select * from "get_late_fee"(3);
select * from "get_sale_off"(1);
select * from "get_shift_wage"(1);
select * from "get_salary"('2023-02-01', '2023-02-28');
select * from "get_rating"('9780141036144');
select ('2023-02-22'::date - '2023-02-10'::date);
select * from shifts;
select * from customers;
select * from staff;
select * from people;
select * from books;
select * from borrowlines;