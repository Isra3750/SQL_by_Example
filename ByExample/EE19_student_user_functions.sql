show con_name;

-- Lower case functions, upper case function, first letter capitalize function
select state, lower(state) as "lower state" from zipcode;
select upper(city) as "upper case city",  state, INITCAP(state) from zipcode where zip = '10035';

-- LPAD, RPAD are padding functions, (data, num of pad, what to pad with)
SELECT RPAD(city, 20, '*') "City Name",
LPAD(state, 10, '-') "State Name"
FROM zipcode;

-- L/RTRIM function, opposite of padding function, example with alias in query
SELECT LTRIM('0001234500', '0') left,
RTRIM('0001234500', '0') right,
LTRIM(RTRIM('0001234500', '0'), '0') both
FROM dual;

-- TRIM does both of previous function in one
SELECT TRIM(LEADING '0' FROM '0001234500') leading,
TRIM(TRAILING '0' FROM '0001234500') trailing,
TRIM('0' FROM '0001234500') both
FROM dual

-- SUBSTR - return a substring based on input
SELECT last_name,
SUBSTR(last_name, 1, 5),
SUBSTR(last_name, 6)
FROM student

-- INSTR - occurence of str inside str, return position of str
SELECT description, INSTR(description, 'er') FROM course;

-- length, as name suggest, return length of str as number
SELECT LENGTH('Hello there') FROM dual;

-- Functions combine with where and order by clause, start with Mo, first char, len = 2
SELECT first_name, last_name
FROM student
WHERE SUBSTR(last_name, 1, 2) = 'Mo';

-- Nested functions - The following example shows the city column formatted in uppercase and right padded with periods.
SELECT RPAD(UPPER(city), 20,'.') padded
FROM zipcode
WHERE state = 'CT'

-- Concatenation - Concatenation connects strings together to become one
-- When you want to concatenate cities and states together using the CONCAT function:
SELECT CONCAT(city, state)
FROM zipcode

-- For a result set that is easier to read, concatenate the strings with spaces and separate the CITY
-- and STATE columns with a comma.
SELECT city||', '||state||' '||zip
FROM zipcode

-- Replace function -- The REPLACE function replaces one string with another string
SELECT REPLACE('My hand is asleep', 'hand', 'foot') -- replace hand with foot
FROM dual

-- Translate function -- Unlike REPLACE, which replaces an entire string, the TRANSLATE function provides a 
-- one-for one character substitution. TRANSLATE(char, if, then)
SELECT phone FROM student
WHERE TRANSLATE(phone, '0123456789',
'##########') <> '###-###-####';

-- SOUNDEX, The SOUNDEX function allows you to compare differently spelled words that phonetically sound alike
SELECT student_id, last_name
FROM student
WHERE SOUNDEX(last_name) = SOUNDEX('MARTIN')