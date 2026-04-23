-- 03_dim_tables.sql

DROP TABLE IF EXISTS dim_employees CASCADE;
DROP TABLE IF EXISTS dim_coverage_type CASCADE;
DROP TABLE IF EXISTS dim_insurers CASCADE;
DROP TABLE IF EXISTS dim_policy_type CASCADE;
DROP TABLE IF EXISTS dim_department CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;


CREATE TABLE dim_employees (
    employee_id INT PRIMARY KEY,
    staff_number VARCHAR(20) UNIQUE,
    employee_name VARCHAR(100),
    employee_type VARCHAR(50),
    department VARCHAR(100),
    status VARCHAR(50),
    hire_date DATE,
	years_of_service INT
);

CREATE TABLE dim_insurers (
    insurer_id SERIAL PRIMARY KEY,
    insurer_name VARCHAR(100),
    insurer_type VARCHAR(50)
);

CREATE TABLE dim_policy_type (
    policy_type_id SERIAL PRIMARY KEY,
    policy_type_name VARCHAR(100)
);


CREATE TABLE dim_coverage_type (
    coverage_type_id SERIAL PRIMARY KEY,
    coverage_name VARCHAR(100),
    description TEXT
);

CREATE TABLE dim_department (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT
);


INSERT INTO dim_employees
SELECT * FROM silver.employees;


INSERT INTO dim_insurers (insurer_name, insurer_type) VALUES
('ICEA Lion', 'General'),
('APA Insurance', 'General'),
('Britam', 'General'),
('CIC Insurance', 'General'),
('Jubilee Insurance', 'General'),
('Old Mutual', 'Life');

INSERT INTO dim_policy_type (policy_type_name) VALUES
('Group Life Policy'),
('Group Personal Accident (GPA / WIBA)'),
('Motor Insurance (Fleet)'),
('Fire and Special Perils'),
('Fire Consequential Loss'),
('Machinery Breakdown'),
('Machinery Breakdown Consequential Loss'),
('Engineering All Risk'),
('Computer & Electronic Equipment'),
('Contractors All Risk'),
('Marine Cargo'),
('Medical Insurance');

INSERT INTO dim_department (department_name) VALUES
('Claims Department'),
('Underwriting Department'),
('Finance Department');

INSERT INTO dim_coverage_type (coverage_name, description) VALUES
('Employees', 'Staff covered under life and accident policies'),
('Directors & Executives', 'High-level executive coverage'),
('Vehicles', 'Covers company motor vehicles and fleet'),
('Buildings & Plants', 'Covers power plants, offices, infrastructure'),
('Machinery & Equipment', 'Covers turbines, generators, heavy equipment'),
('IT Systems', 'Covers servers, computers, digital infrastructure'),
('Goods in Transit', 'Covers transport of fuel, parts, materials');

INSERT INTO dim_date (full_date, year, quarter, month, day)
SELECT 
    d::date,
    EXTRACT(YEAR FROM d),
    EXTRACT(QUARTER FROM d),
    EXTRACT(MONTH FROM d),
    EXTRACT(DAY FROM d)
FROM generate_series(
    '2022-01-01'::date,
    '2025-12-31'::date,
    '1 day'
) AS d;
