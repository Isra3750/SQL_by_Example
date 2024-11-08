---- Use student user (EE19_student_user) - Student:learn
SHOW con_name;
-- WHERE CLAUSE
-- Select where clause much match excatly
SELECT first_name, last_name, phone FROM instructor WHERE last_name = 'Schorin';

-- Operators, arimathic
SELECT description, cost FROM course WHERE cost >= 1195;

-- IN BETWEEN 
SELECT description, cost FROM course WHERE cost BETWEEN 1000 AND 1100;

-- Select either in list with IN
SELECT description, cost FROM course WHERE cost IN (1095, 1595);

-- Pattern matching with LIKE
SELECT first_name, last_name, phone FROM instructor WHERE last_name LIKE 'S%';

-- Another like using _ for second letter o and anything after is fine, _ and % are wildcards btw
SELECT first_name, last_name, phone FROM instructor WHERE last_name LIKE '_o%';

-- NOT and NULL operators
SELECT phone FROM instructor WHERE last_name NOT LIKE 'S%';
SELECT description, prerequisite FROM course WHERE prerequisite IS NULL;

-- Logical operators AND and OR
SELECT description, cost FROM course WHERE cost = 1095 AND description LIKE 'I%';

-- ORDER BY CLAUSE - order by description, default sort in asc
SELECT course_no, description FROM course WHERE prerequisite IS NULL ORDER BY description

-- Error - order by clause is not part of select
SELECT DISTINCT first_name, last_name from student where zip = '10025' order by student_id;

-- Alias, three different ways to do an alias to change column name in output
SELECT first_name first,
first_name "First Name",
first_name AS "First"
FROM student
WHERE zip = '10025';

-- Continue to chapter 4 or page 135 in sqlbyexample book


