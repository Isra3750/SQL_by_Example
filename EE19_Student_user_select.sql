-- Student user -- user: student, PW: learn
show con_name;
Show user;
-- connect to student schema via SQLPLUS Easyconnect = sqlplus student@//localhost:1521/orclpdb1

-- Load in data from downloaded file: navigiate to file via SQL developer and execute script
-- Click File Open and then click the Browse button to locate in the C:\guest\schemasetup directory the script named createStudent.sql.
select * from course;
desc course;

-- SQL select
-- select multiple col
SELECT description, cost
FROM course;

-- You can drag tables for left pannel for quick query
SELECT
    course_no,
    description,
    cost,
    prerequisite,
    created_by,
    created_date,
    modified_by,
    modified_date
FROM
    course;

-- DISTINCT, DISTINCT and UNIQUE can be use interchangably 
SELECT DISTINCT zip
FROM instructor;





