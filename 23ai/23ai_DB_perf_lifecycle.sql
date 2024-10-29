show CON_NAME;
show pdbs;
alter SESSION SET CONTAINER = FREEPDB1;

-- new shrink_tablespace procedure introduced in Oracle Database 23ai. 
-- This procedure offers a simple way to reclaim unused or free space in your tablespace, optimizing database performance and resource use.

-- Make sure to be a users not sys (sys tables will be added to SYSTEM tbs, while users will go to USERS tbs)
-- check all tbss
SELECT tablespace_name 
FROM dba_tablespaces;

-- First off, check current tablespace size, check again after adding 2 million rows (make sure to add 2 mil row in user not sys) , make sure you have enough quota to add rows
SELECT tablespace_name,
    ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS "Size_GB"
FROM dba_data_files
where TABLESPACE_NAME = 'USERS'
GROUP BY tablespace_name;

-- create tbs
drop table if exists my_table purge;

CREATE TABLE my_table (
    id NUMBER,
    name VARCHAR2(100),
    description VARCHAR2(1000)
);

-- Add around two million rows of data to the table via PL/SQL
DECLARE
    v_id NUMBER;
    v_name VARCHAR2(100);
    v_description VARCHAR2(1000);
BEGIN
    FOR i IN 1..2000000 LOOP -- Inserting 2 million rows
        v_id := i;
        v_name := 'Name_' || i;
        v_description := 'Description for row ' || i;

        INSERT INTO my_table (id, name, description) VALUES (v_id, v_name, v_description);

        IF MOD(i, 1000) = 0 THEN
            COMMIT; -- Commit every 1000 rows to avoid running out of undo space
        END IF;
    END LOOP;
    COMMIT; -- Final commit
END;

-- check if row is added
select * FROM MY_TABLE;

-- drop table to see unused space
drop table my_table cascade constraints;

-- Now we can execute the shrink_tablespace procedure to reclaim unused space in the tablespace.
-- ts_name: Name of the tablespace to shrink.
-- shrink_mode: Options include TS_MODE_SHRINK, TS_MODE_ANALYZE, and TS_MODE_SHRINK_FORCE.
-- target_size: New size of the tablespace datafile (in bytes).

-- First we analyze
execute dbms_space.SHRINK_TABLESPACE('USERS', SHRINK_MODE=>DBMS_SPACE.TS_MODE_ANALYZE);

-- Then we shrink
execute dbms_space.SHRINK_TABLESPACE('USERS');



-- New live labs:
-- Error message improvement, first add 
DROP TABLE if exists EMPLOYEES;

CREATE TABLE employees (
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50)
);

INSERT INTO employees (employee_id, first_name, last_name, department)
VALUES
    (4, 'Emily', 'Johnson', 'Marketing'),
    (5, 'Michael', 'Williams', 'Sales'),
    (6, 'Kyle', 'Brown', 'HR');

-- Check the error message, more detail compared to previous version which is helpful
select employee_id, first_name, count(*)
from EMPLOYEES
group by EMPLOYEE_ID;


-- New lab
-- SQL Analysis Report
-- Create some test data first
DROP TABLE IF EXISTS sales cascade constraints;
DROP TABLE IF EXISTS products cascade constraints;

CREATE TABLE sales (
    sale_id INT,
    quantity_sold INT,
    prod_id INT
);

CREATE TABLE products (
    prod_id INT,
    prod_name VARCHAR(100),
    prod_subcategory VARCHAR(50)
);

INSERT INTO sales (sale_id, quantity_sold, prod_id)
VALUES
    (1, 10, 101),
    (2, 20, 102),
    (3, 15, 103),
    (4, 12, 104),
    (5, 8, 105);

INSERT INTO products (prod_id, prod_name, prod_subcategory)
VALUES
(101, 'Laptop', 'Electronics'),
(102, 'Smartphone', 'Electronics'),
(103, 'Headphones', 'Electronics'),
(104, 'Lion trouser Set', 'Clothing'),
(105, 'Shirt - Boys', 'Shirts'),
(106, 'Shirt - Girls', 'Shirts');

-- The SQL Analysis Report appears in a new section at the end of a SQL execution plan
-- The SQL Analysis Report is available in DBMS_XPLAN and SQL Monitor. We are going to take a look at the DBMS_XPLAN functionality.
-- We can also choose how to format the report. The SQL Analysis Report has two format options: TYPICAL and BASIC. The default value is 'TYPICAL'.
EXPLAIN PLAN FOR
SELECT sum(quantity_sold)
FROM   sales s,
    products p
WHERE  p.prod_name = 'Lion trouser Set';

SELECT * FROM table(DBMS_XPLAN.DISPLAY()); -- read plan, last section and make adjustment

-- Make adjustment based on plan, see now we use join as required from the explained plan 
EXPLAIN PLAN FOR
SELECT sum(quantity_sold)
FROM   sales s
JOIN   products p ON s.prod_id = p.prod_id
WHERE  p.prod_name = 'Lion trouser Set';

SELECT * FROM table(DBMS_XPLAN.DISPLAY()); -- re-read