show CON_NAME;
show pdbs;
alter SESSION SET CONTAINER = FREEPDB1;

-- This will introduce a simple but powerful method to validate JSON data
-- Adding JSON Schema can help maintain data integrity and consistency in your Oracle databases.

-- Sample of table with JSON datatype creation
CREATE TABLE products (
    product_id   NUMBER PRIMARY KEY,
    product_info JSON
);

-- Basic insert
INSERT INTO products (product_id, product_info) 
VALUES (1, '{"name": "Laptop", "brand": "Dell", "price": 999.99}');

INSERT INTO products (product_id, product_info) 
VALUES (2, '{"name": "Smartphone", "brand": "Apple", "price": 799.99}');

-- Basic query, JSON_VALUE: Extracts a scalar value from JSON data.
SELECT 
    product_id,
    JSON_VALUE(product_info, '$.name') AS product_name,
    JSON_VALUE(product_info, '$.brand') AS product_brand,
    JSON_VALUE(product_info, '$.price') AS product_price
FROM products;


-- Create table using the JSON data type (21c and above)
-- CHECK (vehicle_info IS JSON WITH CONDITION ...): Adds JSON schema validation. 
-- The WITH CONDITION clause allows you to define constraints directly within the JSON structure using JSON Schema syntax, specifying required fields and valid ranges for year.
DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER, -- validate keyword use for constraints check, so checking if insert has make, model, year
    vehicle_info JSON VALIDATE '{
    "type"       : "object",
    "properties" : {"make"    : {"type" : "string"},
                    "model"   : {"type" : "string"},
                    "year"    : {"type" : "integer",
                                "minimum" : 1886,
                                "maximum" : 2024}},
    "required"   : ["make", "model", "year"]
    }',
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

-- Inserts that will pass schema constraints:
INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{"make":"Toyota","model":"Camry","year":2020}')),
    (2, JSON('{"make":"Ford","model":"Mustang","year":1967}'));

-- Inserts that will fail the schema constraints:
-- Invalid: Missing 'year'
INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (3, JSON('{"make":"Honda","model":"Civic"}'));
-- Invalid: 'year' is out of range
INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (4, JSON('{"make":"Tesla","model":"Model S","year":1885}'));

-- Let's recreate the table without validate
DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER,
    vehicle_info JSON,
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

-- Insert a mix of valid and invalid JSON data
INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{"make":"Nissan","model":"Altima","year":2021}')),
    (2, JSON('{"make":"Chevrolet","model":"Malibu"}')),
    (3, JSON('{"make":"Dodge","model":"Charger","year":2023}')),
    (4, JSON('{"make":"Audi","model":"A4","year":1885}'));


-- Querying with constrait, will get ID number 1 and 3 since these are the ones that pass validate
SELECT *
FROM   vehicles
WHERE  vehicle_info IS JSON VALIDATE '{
"type"       : "object",
"properties" : {"make"    : {"type" : "string"},
                "model"   : {"type" : "string"},
                "year"    : {"type" : "integer",
                            "minimum" : 1886,
                            "maximum" : 2024}},
"required"   : ["make", "model", "year"]
}';

-- Drop to clean
DROP TABLE IF EXISTS vehicles cascade constraints;