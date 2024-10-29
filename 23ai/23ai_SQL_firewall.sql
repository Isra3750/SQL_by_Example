show CON_NAME;
show pdbs;
SELECT USER FROM DUAL; -- show current user
alter SESSION SET CONTAINER = FREEPDB1;

-- check tablespace
SELECT tablespace_name 
FROM dba_tablespaces;

-- Need to create two user first, one to enable firewall, and the other (test) to run some querys
-- Create USER SQL (this user is to start firewall)
CREATE USER TEST IDENTIFIED BY Oracledb_4U#;

-- Grant roles
GRANT CONNECT TO TEST;
GRANT RESOURCE TO TEST;
GRANT SQL_FIREWALL_ADMIN TO TEST WITH ADMIN OPTION;

-- Set quota for test user
ALTER USER TEST QUOTA UNLIMITED ON USERS;

-- Create second USER SQL (this user to simulate developer)
CREATE USER DB23AI IDENTIFIED BY Oracledb_4U#;

-- ADD ROLES
GRANT CONNECT TO DB23AI;
GRANT DB_DEVELOPER_ROLE TO DB23AI; -- New DB developer role
GRANT RESOURCE TO DB23AI;

-- QUOTA to create stuff on tablespace for DB23AI user
ALTER USER DB23AI QUOTA UNLIMITED ON USERS;

-- Enabling SQL firewall, do this as test user
EXEC DBMS_SQL_FIREWALL.ENABLE;

-- Start capturing SQL traffic (exec as test user) for the DB23AI user to learn normal activities. 
BEGIN
    DBMS_SQL_FIREWALL.CREATE_CAPTURE(
        username => 'DB23AI',
        top_level_only => TRUE,
        start_capture => TRUE
    );
END;
/

-- Random query, do this as DB23AI user
DROP TABLE IF EXISTS EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS DEPARTMENTS CASCADE CONSTRAINTS;

-- Create employees table
CREATE TABLE employees (
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT
);

-- Create departments table
CREATE TABLE departments (
    department_id INT,
    department_name VARCHAR(50)
);

-- Insert data into departments table
INSERT INTO departments (department_id, department_name)
VALUES
    (1, 'HR'),
    (2, 'IT'),
    (3, 'Finance');

-- Switch back to test user
-- Stopping SQL firewall capture
EXEC DBMS_SQL_FIREWALL.STOP_CAPTURE('DB23AI');

-- Query the SQL firewall data dict view to see captured data
SELECT sql_text
FROM DBA_SQL_FIREWALL_CAPTURE_LOGS
WHERE username = 'DB23AI';

-- Checking allow list for SQL firewall
SELECT sql_text
FROM DBA_SQL_FIREWALL_ALLOWED_SQL
WHERE username = 'DB23AI';

-- we'll turn our capture logs into our allow list. This is where you'd want to customize it yourself in a production system.
EXEC DBMS_SQL_FIREWALL.GENERATE_ALLOW_LIST('DB23AI');

-- we can enable SQL firewall so only SQL from our allow list can hit the database.
EXEC DBMS_SQL_FIREWALL.ENABLE_ALLOW_LIST(username=>'DB23AI', enforce=>DBMS_SQL_FIREWALL.ENFORCE_SQL, block=>TRUE);

-- switch back to DB23AI -> only SQL in sql allow list is allowed to run now
SELECT * FROM DEPARTMENTS; -- this will no longer work
