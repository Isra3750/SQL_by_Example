select * from v$version;

alter session set container = FREEPDB1;
show con_name

-- Schema Annotations provide a way to add additional property metadata for database objects, such as tables, columns, views, materialized views, and even domains.
-- Compared to comments, annotations offer more flexibility. They can be used with various types of database elements, not just tables.
-- Also, you can attach multiple annotations to the same object, which isn't possible with comments
-- creating a table with annotation (meta data)
DROP TABLE IF EXISTS books;

CREATE TABLE books (
book_id      NUMBER        ANNOTATIONS (mandatory, system_generated),
title        VARCHAR2(100), 
genre        VARCHAR2(100),
rating       NUMBER        ANNOTATIONS (description 'A single natural number from zero to ten')
)
ANNOTATIONS (books_table 'Table storing information about books');

-- you can add or drop annotation on tables (can this be done inside table?)
alter table books annotations (drop books_table);
alter table books annotations (add books_table 'Table storing information about books');

--  you can view the anno made
select COLUMN_NAME,
        ANNOTATION_NAME,
        ANNOTATION_VALUE
from   user_annotations_usage
where annotation_name = 'DESCRIPTION' -- needed to add this for some reason?
order by annotation_name, annotation_value;