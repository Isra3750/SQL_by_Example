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

-- NOT and NULL operators
SELECT phone FROM instructor WHERE last_name NOT LIKE 'S%';
SELECT description, prerequisite FROM course WHERE prerequisite IS NULL;

-- Logical operators AND and OR
SELECT description, cost FROM course WHERE cost = 1095 AND description LIKE 'I%';

-- ORDER BY COURSE - order by description
SELECT course_no, description FROM course WHERE prerequisite IS NULL ORDER BY description

-- Alias
SELECT first_name first,
first_name "First Name",
first_name AS "First"
FROM student
WHERE zip = '10025';
