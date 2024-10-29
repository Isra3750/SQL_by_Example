show CON_NAME;
show pdbs;
alter SESSION SET CONTAINER = FREEPDB1;

-- Schema privillages
-- First create users
drop user if exists bob cascade;
drop user if exists sally cascade;
create user bob identified by Oracle123long;
create user sally identified by Oracle123long;

-- Can now grant schema-level privileges 
-- tables, views, and materialized views
grant select any table on schema sally to bob;
grant insert any table on schema sally to bob;
grant update any table on schema sally to bob;
grant delete any table on schema sally to bob;

-- procedures, functions, packages, and sequences
grant execute any procedure on schema sally to bob;
grant select any sequence on schema sally to bob;

-- View to check schema-level privilges granted to user
SELECT * FROM DBA_SCHEMA_PRIVS WHERE GRANTEE = 'BOB';

-- And of course - you can revoke privilleges as well
-- tables, views, and materialized views
revoke select any table on schema sally from bob;
revoke insert any table on schema sally from bob;
revoke update any table on schema sally from bob;
revoke delete any table on schema sally from bob;

-- procedures, functions, packages, and sequences
revoke execute any procedure on schema sally from bob;
revoke select any sequence on schema sally from bob;

-- drop user to clean
drop user if exists bob cascade;
drop user if exists sally cascade;


-- Also developer role is added now!

-- Benefits of Developer Role:
-- Least-Privilege Principle: Granting the Developer Role follows the least-privilege principle. 
-- This means that application developers (and all other database users) only have access to the necessary privileges.

-- Enhanced Security: Using the Developer Role improves database security by reducing the risk of granting unneeded privileges to application users, 
-- which ties into the least-privilege principle from above.

-- Simplified Management: Granting the Developer Role simplifies the management of role grants and revokes for application users.

-- There is an PL/SQL that will show all granst this role brings - search the web or check LL
-- Create a User and check the current granted role (which is nothing)
DROP USER IF EXISTS KILLIAN CASCADE;
CREATE USER KILLIAN IDENTIFIED BY Oracle123_long;

SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE='KILLIAN';

-- Grant the DB role
GRANT DB_DEVELOPER_ROLE TO killian;

-- Revoke role
REVOKE DB_DEVELOPER_ROLE FROM KILLIAN;