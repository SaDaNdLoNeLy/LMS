INSERT INTO people (account_name, pass, person_name, dob, gender, house_number, street, city, country, email, phone_number, role)
VALUES
    ('johnsmith', 'password', 'John Smith', '1980-01-01', 'M', '123', 'Main St', 'New York', 'USA', 'john.smith@example.com', '123-456-7890', 'staff'),
    ('janesmith', 'password', 'Jane Smith', '1985-02-01', 'F', '456', 'Elm St', 'Los Angeles', 'USA', 'jane.smith@example.com', '234-567-8901', 'customer'),
    ('bobsanchez', 'password', 'Bob Sanchez', '1990-03-01', 'M', '789', 'Oak St', 'Chicago', 'USA', 'bob.sanchez@example.com', '345-678-9012', 'customer');

INSERT INTO people (account_name, pass, person_name, dob, gender, house_number, street, city, country, email, phone_number, role)
VALUES
    ('johnsmitsh', 'passwords', 'John Smith', '1980-01-01', 'M', '123', 'Main St', 'New York', 'USA', 'john.smith@example.com', '123-456-2890', 'staff')
	
INSERT INTO books (ISBN, title, description, author_name, category, publisher_name, number_of_pages, language_code, customer_rating, cur_quantity)
VALUES
    ('9780141036144', '1984', 'A dystopian novel about life under an oppressive government', 'George Orwell', 'Fiction', 'Penguin Books', 328, 'eng', 9.0, 10),
    ('9780679783268', 'To Kill a Mockingbird', 'A coming-of-age novel about race relations in the American South', 'Harper Lee', 'Fiction', 'Vintage Books', 336, 'eng', 8.0, 5),
    ('9780545010221', 'Harry Potter and the Deathly Hallows', 'The final book in the Harry Potter series', 'J.K. Rowling', 'Fiction', 'Arthur A. Levine Books', 784, 'eng', 9.5, 15);

INSERT INTO people (account_name, pass, person_name, dob, gender, house_number, street, city, country, email, phone_number, role)
VALUES
('staff_1', 'pass123', 'John Smith', '1990-04-03', 'M', '123', 'Elm Street', 'New York', 'USA', 'john.smith@gmail.com', '123-456-7890', 'staff'),
('staff_2', 'pass456', 'Jane Doe', '1985-12-12', 'F', '456', 'Main Street', 'Los Angeles', 'USA', 'jane.doe@gmail.com', '123-456-7891', 'staff'),
('staff_3', 'pass789', 'Peter Parker', '1995-07-01', 'M', '789', '2nd Avenue', 'San Francisco', 'USA', 'peter.parker@gmail.com', '123-456-7892', 'staff'),
('staff_4', 'pass101', 'Sarah Johnson', '1992-10-15', 'F', '101', '3rd Street', 'Chicago', 'USA', 'sarah.johnson@gmail.com', '123-456-7893', 'staff');

select "add_book"('97801241036144', 'Dog Luat', 'A true story', 'George Orwell', 'Non-Fiction', 'Penguin Books', 500, 'eng', 9.9, 2)

INSERT INTO borrowlines (staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price)
VALUES
    (1, 1, '9780141036144', 2, 0.00, '2022-01-01', '2022-01-08', 10.00),
    (1, 2, '9780679783268', 1, 0.00, '2022-02-01', '2022-02-08', 5.00);
	
INSERT INTO borrowlines (staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price)
VALUES
    (1, 1, '9780141036144', 2, 0.00, '2022-01-01', '2022-01-08', 45.00);
	
INSERT INTO borrowlines (staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price)
VALUES
    (1, 2, '9780679783268', 4, 0.00, '2022-02-01', '2022-03-08', 10.00);
	
INSERT INTO borrowlines (staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price)
VALUES
    (1, 1, '9780679783268', 3, 0.00, '2022-02-01', '2022-03-08', 10.00);

INSERT INTO shifts(staff_id, shift_from, shift_end, shift_date, week_day, wage_per_hr) VALUES
-- (1, '08:00:00', '12:00:00', '2023-02-22', 2, 20),
-- (3, '14:00:00', '18:00:00', '2023-02-22', 2, 20),
-- (4, '08:00:00', '12:00:00', '2023-02-23', 3, 20),
-- (5, '09:00:00', '13:00:00', '2023-02-23', 3, 20),
-- (6, '14:00:00', '18:00:00', '2023-02-23', 3, 20),
-- (1, '08:00:00', '12:00:00', '2023-02-24', 4, 20),
-- (3, '14:00:00', '18:00:00', '2023-02-24', 4, 20)
(7, '08:00:00', '12:00:00', '2023-02-22', 2, 20),
(8, '14:00:00', '18:00:00', '2023-02-22', 2, 20),
(9, '08:00:00', '12:00:00', '2023-02-23', 3, 20),
(10, '09:00:00', '13:00:00', '2023-02-23', 3, 20),
(11, '14:00:00', '18:00:00', '2023-02-23', 3, 20),
(12, '08:00:00', '12:00:00', '2023-02-24', 4, 20)

INSERT INTO shifts(staff_id, shift_from, shift_end, shift_date, week_day, wage_per_hr) VALUES
(1, '07:00:00', '11:00:00', '2023-05-22', 2, 20)

INSERT INTO shifts(staff_id, shift_from, shift_end, shift_date, week_day, wage_per_hr) VALUES
(6, '08:00:00', '12:00:00', '2023-02-22', 7, 20)

INSERT INTO shifts(staff_id, shift_from, shift_end, shift_date, week_day, wage_per_hr) VALUES
(1, '07:00:00', '11:00:00', '2023-01-22', 2, 20)

INSERT INTO borrowlines (staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price)
VALUES
    (1, 1, '9780679783268', 4, 0.00, '2022-02-01', '2022-03-08', 10.00);
	
INSERT INTO borrowlines (staff_id, customer_id, ISBN, quantity, late_fee, borrow_date, due_date, price)
VALUES
    (1, 1, '9780679783268', 10, 0.00, '2022-02-01', '2022-03-08', 10.00);
	