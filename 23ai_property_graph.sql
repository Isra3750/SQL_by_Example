select * from v$version;

alter session set container = FREEPDB1;
show con_name

-- Setup - create some tables
drop table if exists people cascade CONSTRAINTS;
drop table if exists relationship cascade CONSTRAINTS;

CREATE TABLE people (
    p_id NUMBER PRIMARY KEY,
    name VARCHAR2(50)
);

INSERT INTO people (p_id, name) VALUES 
    (1, 'Alice'), 
    (2, 'Bob'), 
    (3, 'Carol'), 
    (4, 'Dave'), 
    (5, 'Eve');

CREATE TABLE relationship (
    r_id NUMBER PRIMARY KEY,
    source_id NUMBER,
    target_id NUMBER,
    relationship VARCHAR2(50),
    CONSTRAINT connections_people_1_fk FOREIGN KEY (source_id) REFERENCES people (p_id),
    CONSTRAINT connections_people_2_fk FOREIGN KEY (target_id) REFERENCES people (p_id)
);

INSERT INTO relationship (r_id, source_id, target_id, relationship) 
VALUES 
    (1, 1, 2, 'friend'),
    (2, 2, 3, 'colleague'),
    (3, 3, 4, 'neighbor'),
    (4, 4, 1, 'sibling'),
    (5, 1, 3, 'mentor');
    
-- Property graphs give you a different way of looking at your data. With Property Graphs you model data with edges and nodes.
-- Oracle have had a Graph Server and Client product for some time, 
-- but in Oracle database 23ai some of the property graph functionality has been built directly into the database.
-- With Oracle 23c, you can use relational tables (above) as the basis for creating a property graph, 21c and before required Graph API
-- Let's take a look at how to create property graphs and query them using the SQL/PGQ extension.
drop property graph if exists relationships_pg;

CREATE PROPERTY GRAPH relationships_pg
    VERTEX TABLES (
        people
        KEY (p_id)
        LABEL person
        PROPERTIES ALL COLUMNS
    )
    EDGE TABLES (
        relationship
        KEY (r_id)
        SOURCE KEY (source_id) REFERENCES people (p_id)
        DESTINATION KEY (target_id) REFERENCES people (p_id)
        LABEL relationship
        PROPERTIES ALL COLUMNS
    );

-- Vertex represent our people table
-- Edges represent how they are connected (relationship table)
-- Our edges table has a source key and destination key, representing the connection between the two people
-- Let's see how to query these graph, see relationship between people (SQL/PQG, before this PGQL was used
SELECT person_1, relationship, person_2
FROM   graph_table (relationships_pg
        MATCH
        (p1 IS person) -[r IS relationship]-> (p2 IS person)
        COLUMNS (p1.name AS person_1, r.relationship, p2.name AS person_2)
    );