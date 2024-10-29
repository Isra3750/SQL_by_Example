select * from v$version;

alter session set container = FREEPDB1;
show con_name

-- create some tables first
DROP TABLE if exists orders CASCADE CONSTRAINTS;
DROP TABLE if exists customers CASCADE CONSTRAINTS;

-- Create a table to store order data
CREATE TABLE if not exists orders (
    id NUMBER,
    product_id NUMBER,
    order_date TIMESTAMP,
    customer_id NUMBER,
    total_value NUMBER(6,2),
    order_shipped BOOLEAN,
    warranty INTERVAL YEAR TO MONTH
);

-- Create a table to store customer data
CREATE TABLE if not exists customers (
    id NUMBER,
    first_name VARCHAR2(100),
    last_name VARCHAR2(100),
    dob DATE,
    email VARCHAR2(100),
    address VARCHAR2(200),
    zip VARCHAR2(10),
    phone_number VARCHAR2(20),
    credit_card VARCHAR2(20),
    joined_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    gold_customer BOOLEAN DEFAULT FALSE,
    CONSTRAINT new_customers_pk PRIMARY KEY (id)
);

-- Add foreign key constraint to new_orders table
ALTER TABLE orders ADD (CONSTRAINT orders_pk PRIMARY KEY (id));
ALTER TABLE orders ADD (CONSTRAINT orders_fk FOREIGN KEY (customer_id) REFERENCES customers (id));

-- create duality view
-- JSON duality views are a new feature in Oracle 23c that provides a dual representation 
-- of relational tables in both relational and JSON formats
--  They allow you to work with relational data as if it were JSON.
-- @insert @update @delete: Specifies that this JSON duality view supports inserts, updates, and deletes.
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW customers_dv AS
customers @insert @update @delete
{
    _id      : id,
    FirstName       : first_name,
    LastName        : last_name,
    DateOfBirth     : dob,
    Email           : email,
    Address         : address,
    Zip             : zip
    phoneNumber     : phone_number
    creditCard      : credit_card
    joinedDate      : joined_date 
    goldStatus      : gold_customer
}
;

-- Two ways to insert into table
-- way 1, normal insert to both underlying tables
INSERT INTO customers (id, first_name, last_name, dob, email, address, zip, phone_number, credit_card)
VALUES (1, 'Alice', 'Brown', DATE '1990-01-01', 'alice.brown@example.com', '123 Maple Street', '12345', '555-1234', '4111 1111 1111 1111');

INSERT INTO orders (id, customer_id, product_id, order_date, total_value)
VALUES (100, 1, 101, SYSTIMESTAMP, 300.00);

-- way 2, via duality view
INSERT INTO customers_DV values ('{"_id": 2, "FirstName": "Jim", "LastName":"Brown", "Email": "jim.brown@example.com", "Address": "456 Maple Street", "Zip": 12345}');
commit;

-- Now let's query stuffs
-- We get JSON out from duality view from relational table
select * from customers_dv;
select dv.DATA.FirstName from customers_dv dv; -- this will no longer be in JSON format

-- same as regular querys
select * from customers;
select * from orders;

-- See LL for more example like updating tables or REST API
-- You would click on the schema object and enable REST and grab the URL
