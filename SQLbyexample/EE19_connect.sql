select * from dual;

-- Check con_name, make sure in PDB or else USER creation must have C## in front as common user
show con_name;
Show user;

-- check your tablespace
SELECT tablespace_name
FROM dba_tablespaces
ORDER BY tablespace_name;

-- Create user student
CREATE USER student IDENTIFIED by learn
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP;

-- check if created
SELECT username FROM all_users WHERE username = 'STUDENT';

-- connect to student schema via SQLPLUS = sqlplus student@//localhost:1521/orclpdb1

-- Grant to user
GRANT CONNECT, RESOURCE TO student;
GRANT SELECT_CATALOG_ROLE TO student;
GRANT CREATE VIEW TO student;

-- grant more space in table
ALTER USER student QUOTA UNLIMITED ON USERS;

