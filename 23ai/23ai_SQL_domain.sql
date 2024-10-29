select * from v$version;

alter session set container = FREEPDB1;
show con_name

-- Data Usecase Domains serve as a way for defining properties and constraints associated with columns. 
-- They ensure consistency in data representation and validation throughout the application
-- 4 types of data usecase domain -> single col, multi col domain, flexible and enumeration domain.

-- Drop the domain if it already exists
drop domain if exists price force;
-- create single colummn domain -> constraints to one single col
create domain price as number
constraint price check (value > 0);


-- Drop the domain if it already exists
drop domain if exists coordinates force;
-- Creating a multi-column domain -> constrait to multiple col
create domain coordinates as (
    latitude  as number,
    longitude as number,
    location_name as varchar2 (100)
)
constraint coordinates check (latitude between -90 and 90 and longitude between -180 and 180);

-- Flexible Domain Example: For the flexible domain, let's consider a scenario where we want to store contact information for individuals. 
-- We'll create Data Usecase Domains for different types of contacts and dynamically select the appropriate domain based on the contact type
-- Drop the Data Usecase Domains if they already exists
drop domain if exists personal_contact_dom force;
drop domain if exists business_contact_dom force;
drop domain if exists default_contact_dom force;

-- Personal contact domain
create domain personal_contact_dom as (
    first_name     as varchar2(50),
    last_name      as varchar2(50),
    email          as varchar2(100),
    phone          as varchar2(20)
)
constraint personal_contact_dom check (first_name is not null and 
                                       phone is not null);
-- Business contact domain
create domain business_contact_dom as (
    company_name   as varchar2(100),
    first_name     as varchar2(50),
    last_name      as varchar2(50),
    email          as varchar2(100),
    phone          as varchar2(20)

)
constraint business_contact_dom check (first_name is not null and 
                                       phone is not null);
-- Default contact domain
create domain default_contact_dom as (
    first_name     as varchar2(50),
    last_name      as varchar2(50),
    email          as varchar2(100),
    phone          as varchar2(20)
)
constraint default_contact_dom check (first_name is not null and 
                                       phone is not null);
-- Flexible domain to choose contact based on type
create flexible domain contact_flex_dom (company_name, first_name, last_name, email, phone)
choose domain using (contact_type varchar2(100))
from case
    when contact_type = 'personal' then personal_contact_dom(first_name, last_name, email, phone)
    when contact_type = 'business' then business_contact_dom(company_name, first_name, last_name, email, phone)
    else default_contact_dom(first_name, last_name, email, phone)
end;

-- see pre-created domain in 23ai and user-created ones as well
select name as "System provided domains" from all_domains where owner = 'SYS'

-- Let's create some tables using the created domains:
-- Drop table with single column domain if exists
drop table if exists products purge;

-- Table with single column domain
create table products (
    product_id   number,
    name         varchar2(100),
    price        price          -- User defined domain
);

-- Drop table with multi-column domain if exists
drop table if exists locations purge;

-- Table with multi-column domain
create table locations (
    location_id     number,
    latitude        number,
    longitude       number,
    location_name   varchar2(100),
    domain  coordinates(latitude, longitude, location_name)    -- User defined domain
);

-- Drop table with flexible domain if exists
drop table if exists contacts purge;

-- Table with flexible domain
create table contacts (
    contact_id     number,
    contact_type   varchar2(100),
    company_name   varchar2(100),
    first_name     varchar2(50),
    last_name      varchar2(50),
    email          varchar2(100),
    phone          varchar2(20),
    domain         contact_flex_dom(company_name, first_name, last_name, email, phone) using (contact_type) -- User defined domain
);

-- try inserting stuff into tables with domains constraits
-- Inserting data into products table
insert into products (product_id, name, price) values (1, 'Widget', 10.99);
insert into products (product_id, name, price) values (2, 'Gadget', -5.99); -- This will fail due to price domain

-- Inserting data into locations table with multi-column domain
insert into locations (location_id, location_name, latitude, longitude) 
values (1, 'Headquarters', 100.7749, -122.4194); -- This will fail 

insert into locations (location_id, location_name, latitude, longitude) 
values (2, 'Branch Office', 40.7128, -74.0060);


-- Inserting a personal contact
insert into contacts (contact_id, contact_type, first_name, last_name, email, phone)
values (1, 'personal', 'John', 'Doe', 'john.doe@example.com', 1231231231);

-- You can also create enumeration use case domains
drop domain if exists order_status_domain;

create domain order_status_domain as
enum (
pending,
processing,
shipped,
delivered
);

select * from order_status_domain;

-- for more information check live labs
