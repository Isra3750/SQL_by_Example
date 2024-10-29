-- connect using SYS (EE19_connect) via the JSON PDB
show con_name;
show pdbs

-- switch to JSON PDB
ALTER SESSION SET CONTAINER = ORCLPDB_JSON;
ALTER PLUGGABLE DATABASE ORCLPDB_JSON OPEN READ WRITE;

-- Use this to drop table:
DROP TABLE json_documents PURGE;

-- ODB 12.1 JSON use
---- Start, create a JSON table - this is not using the JSON data type introduced in 21c, use lax syntax not strict (data is JSON (strict))
CREATE TABLE json_documents (
  id    RAW(16) NOT NULL,
  data  CLOB,
  CONSTRAINT json_documents_pk PRIMARY KEY (id),
  CONSTRAINT json_documents_json_chk CHECK (data IS JSON)
);

-- insert JSON value into the table above, two column id and data
-- SYS_GUID() is a function that generates a globally unique identifier (GUID) in Oracle. 
-- This ensures a unique value for the id column for each row inserted, even if inserted by different users or processes.
INSERT INTO json_documents (id, data)
VALUES (SYS_GUID(),
        '{
          "FirstName"      : "John",
          "LastName"       : "Doe",
          "Job"            : "Clerk",
          "Address"        : {
                              "Street"   : "99 My Street",
                              "City"     : "My City",
                              "Country"  : "UK",
                              "Postcode" : "A12 34B"
                             },
          "ContactDetails" : {
                              "Email"    : "john.doe@example.com",
                              "Phone"    : "44 123 123456",
                              "Twitter"  : "@johndoe"
                             },
          "DateOfBirth"    : "01-JAN-1980",
          "Active"         : true
         }');

-- Insert another data
INSERT INTO json_documents (id, data)
VALUES (SYS_GUID(),
        '{
          "FirstName"      : "Jayne",
          "LastName"       : "Doe",
          "Job"            : "Manager",
          "Address"        : {
                              "Street"   : "100 My Street",
                              "City"     : "My City",
                              "Country"  : "UK",
                              "Postcode" : "A12 34B"
                             },
          "ContactDetails" : {
                              "Email"    : "jayne.doe@example.com",
                              "Phone"    : ""
                             },
          "DateOfBirth"    : "01-JAN-1982",
          "Active"         : false
         }');

COMMIT;

-- Test querying, format output first, not required in SQL developer?
-- Anyhow, Dot notation is used for access - remember python, same idea to access data inside data
COLUMN FirstName FORMAT A15
COLUMN LastName FORMAT A15
COLUMN Postcode FORMAT A10
COLUMN Email FORMAT A25

-- start your query, do it this way to Accessing JSON Attributes Individually
-- a.data.FirstName is accessing firstname inside data column inside jsondocuments table (alias)
-- AS operators help with the formatting above (COLUMN Email FORMAT A25), you see it?
SELECT a.data.FirstName,
       a.data.LastName,
       a.data.Address.Postcode AS Postcode,
       a.data.ContactDetails.Email AS Email
FROM   json_documents a
ORDER BY a.data.FirstName,
         a.data.LastName;

-- another example, this will be unformatted, Selecting All Data Directly
select * from json_documents;

-- Drill down example for address code
SELECT a.data.Address.Postcode
FROM   json_documents a;

-- If scalar object is reference, it will return raw JSON output such as contactdetails column
SELECT a.data.ContactDetails
FROM   json_documents a;

-- JSON functions, various use cases
-- JSON_EXISTS – Check if a JSON Key Exists
SELECT a.data.FirstName,
       a.data.LastName,
       a.data.ContactDetails.Email AS Email,
       a.data.ContactDetails.Phone AS Phone,
       a.data.ContactDetails.Twitter AS Twitter
FROM   json_documents a
WHERE  a.data.ContactDetails.Phone IS NULL
AND    a.data.ContactDetails.Twitter IS NULL;

-- JSON_VALUE – Extract a Scalar Value
SELECT JSON_VALUE(a.data, '$.FirstName') AS first_name,
       JSON_VALUE(a.data, '$.LastName') AS last_name
FROM   json_documents a
ORDER BY 1, 2;

-- JSON_QUERY – Retrieve Complex JSON Objects or Arrays
-- The WITH WRAPPER option surrounds the fragment with square brackets.
SELECT a.data.FirstName,
       a.data.LastName,
       JSON_QUERY(a.data, '$.ContactDetails' WITH WRAPPER) AS contact_details
FROM   json_documents a
ORDER BY a.data.FirstName,
         a.data.Last_name;

-- JSON_TABLE – Query JSON Data as if It Were a Relational Table, this is with 18c
SELECT jt.FirstName,
       jt.LastName,
       jt.Postcode,
       jt.Email
FROM json_documents,
     JSON_TABLE(data, '$'
       COLUMNS (
         FirstName VARCHAR2(50) PATH '$.FirstName',
         LastName VARCHAR2(50) PATH '$.LastName',
         Postcode VARCHAR2(10) PATH '$.Address.Postcode',
         Email VARCHAR2(50) PATH '$.ContactDetails.Email'
       )
     ) jt;

-- Note from 21c onwards we should switch to JSON data type when possible
