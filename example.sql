select * from "add_person"('johnsmith', 'password', 'John Smith', '1980-01-01', 'M', '123', 'Main St', 'New York', 'USA', 'john.smith@example.com', '123-456-7890', 'customer');
select * from "add_person"('staff1', 'password', 'John Smith', '1980-01-01', 'M', '123', 'Main St', 'New York', 'USA', 'staff1@example.com', '123-456-7891', 'staff');
select * from "add_book"('9780141036144', '1984', 'A dystopian novel about life under an oppressive government', 'George Orwell', 'Fiction', 'Penguin Books', 328, 'eng', 10, 200.0)
select * from "borrow_book"(1, 1, '9780141036144', 2, '2022-01-01', '2022-01-08')
select * from "return_book"(2, current_date);
select * from "add_shift"(1, '13:00:00', '14:00:00', '2023-02-22');
select * from "update_shift"(1, '9:00:00', '14:00:00', '2023-02-22');
select * from shifts;
select * from customers;
select * from people;
select * from books;
select * from borrowlines;