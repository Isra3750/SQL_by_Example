show CON_NAME;
show pdbs;
alter SESSION SET CONTAINER = FREEPDB1;

-- SQL Enchancements: 4 mains area today in this lab (check full LL for more details on each of them):

-- Boolean Data Type: The introduction of a new boolean data type enhances data modeling capabilities, allowing for more efficient representation and manipulation of boolean values.
-- Table Value Constructors: Table value constructors provide a convenient way to specify multiple rows in insert, select, or merge statements, simplifying data manipulation tasks.
-- Direct Joins in Updates: Streamlined syntax for performing direct joins in update operations simplifies query construction and improves code readability.
-- IF EXISTS: The IF EXISTS statements are powerful tools for executing SQL commands based on the existence or non-existence of certain conditions or objects inside the database.

-- New boolean data type
drop table if EXISTS product;

CREATE TABLE product (
    product_name VARCHAR2(100),
    available BOOLEAN
);

-- Insert
INSERT INTO product (product_name, available) VALUES ('Laptop', TRUE), ('Smartphone', FALSE);

-- select where bool is true/false
SELECT * FROM product WHERE available = TRUE;
SELECT * FROM product WHERE available = FALSE;

-- And of course, you can update the bool
UPDATE product SET available = TRUE WHERE product_name = 'Smartphone';


-- "IF EXISTS" and "IF NOT EXISTS" statements in SQL within Oracle Database 23ai. 
-- You will explore their usage for checking the existence or non-existence of tables, columns, and records, and execute conditional commands based on these checks
-- Create table
DROP TABLE if exists customer CASCADE CONSTRAINTS;

-- We'll use the IF NOT EXISTS clause meaning the table only gets created if it doesn't already exist in the database.
CREATE TABLE IF NOT EXISTS customer (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
);

-- Let's now drop objects using the IF EXISTS clause. This means that we can drop non-existent and existing objects without receiving an error. 
-- Notice, we don't have a customer_view. However, with IF EXISTS statement we wont get an error.
-- Drop a table with IF EXISTS clause
DROP TABLE IF EXISTS customer;

-- We don't have a view but wont get an error using the if exists statement
DROP VIEW IF EXISTS customer_view;



-- Power of Table Value Constructors in SQL
-- which allows you to define multiple rows using a single constructor for use in SQL statements
-- create some tables first
DROP TABLE if exists EMPLOYEES cascade constraints;
DROP TABLE if exists PRODUCTS cascade constraints;

-- Create a table to store employee data
CREATE TABLE employees (
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50)
);

-- Create a table to store product data
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    category VARCHAR(50)
);

-- Table value constructors, also known as row value constructors, allow you to specify multiple rows of data within a single INSERT, SELECT, UPDATE, or MERGE statement. 
-- This feature simplifies the process of working with multiple rows of data, eliminating the need for multiple INSERT or SELECT statements.
-- Here's an old way of inserting:
-- Insert sample data into the employees table
INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (1, 'John', 'Doe', 'IT');

INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (2, 'Jane', 'Smith', 'HR');

INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (3, 'Bob', 'Johnson', 'Finance');

-- Insert sample data into the products table
INSERT INTO products (product_id, product_name, price, category)
VALUES
    (101, 'Laptop', 1200.00, 'Electronics');

INSERT INTO products (product_id, product_name, price, category)
VALUES
    (102, 'Smartphone', 800.00, 'Electronics');

INSERT INTO products (product_id, product_name, price, category)
VALUES
    (103, 'Headphones', 150.00, 'Electronics');

-- But now with Table Value Constructor, multiple rows can be inserted into table in a single INSERT Statement
INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (4, 'Emily', 'Johnson', 'Marketing'),
    (5, 'Michael', 'Williams', 'Sales'),
    (6, 'Kyle', 'Brown', 'HR');

-- Same thing in DML update - Suppose we want to update the department for employees whose first name starts with 'J':
UPDATE employees
SET department = 'IT'
WHERE first_name IN (
    SELECT first_name
    FROM (
        VALUES ('John'), ('Jane')
    ) AS first_names(first_name)
);

-- same thing for delete, Suppose we want to delete employees whose department is 'HR'
DELETE FROM employees
WHERE department IN (
    SELECT department
    FROM (
        VALUES ('HR')
    ) AS departments(department)
);

-- Last thing, Direct Joins
-- Direct joins allow you to easily update and delete data across multiple related tables.
-- First, the legendary tables
DROP TABLE if exists GENRES CASCADE CONSTRAINT;
DROP TABLE if exists MOVIES CASCADE CONSTRAINT;

-- Create GENRES table
CREATE TABLE GENRES (
    GENRE_ID INT PRIMARY KEY,
    GENRE_NAME VARCHAR(50)
);

-- Create MOVIES table
CREATE TABLE MOVIES (
    MOVIE_ID INT PRIMARY KEY,
    TITLE VARCHAR(100),
    GENRE_ID INT,
    RATING DECIMAL(3,1),
    FOREIGN KEY (GENRE_ID) REFERENCES GENRES(GENRE_ID)
);

-- Insert sample data into GENRES table
INSERT INTO GENRES (GENRE_ID, GENRE_NAME) VALUES
(1, 'Thriller'),
(2, 'Horror'),
(3, 'Comedy'),
(4, 'Drama');

-- Insert sample data into MOVIES table
INSERT INTO MOVIES (MOVIE_ID, TITLE, GENRE_ID, RATING) VALUES
(1, 'The Silence of the Lambs', 1, 8.6),
(2, 'Psycho', 2, 8.5),
(3, 'Airplane!', 3, 7.7),
(4, 'The Shawshank Redemption', 4, 9.3),
(5, 'Seven', 1, 8.6),
(6, 'A Nightmare on Elm Street', 2, 7.5),
(7, 'Monty Python and the Holy Grail', 3, 8.2),
(8, 'The Godfather', 4, 9.2);

-- First we'll take a look at all of our thriller movies and their ratings
SELECT m.movie_id, m.title, m.genre_id, m.rating
FROM movies m
JOIN genres g ON m.genre_id = g.genre_id
WHERE g.genre_name = 'Thriller';

-- In 23ai, the syntax is much simpler and the join can be performed in the same update statement.
UPDATE movies m
SET m.rating = m.rating + 0.5
FROM genres g
WHERE m.genre_id = g.genre_id
AND g.genre_name = 'Thriller';

-- Wait, what if we don't like horror movies? Let's say we decide to purge all of our Horror genre.
SELECT m.movie_id, m.title, m.genre_id, m.rating
FROM movies m
JOIN genres g ON m.genre_id = g.genre_id
WHERE g.genre_name = 'Horror';

-- Again, with Oracle 23ai's direct join capability, removing these movies becomes a lot easier.
DELETE FROM movies m
FROM genres g
WHERE m.genre_id = g.genre_id
AND g.genre_name = 'Horror';