-- 01_bronze.sql

DROP SCHEMA IF EXISTS bronze CASCADE;

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE TABLE bronze.employees (
    employee_id SERIAL PRIMARY KEY,
    staff_number VARCHAR(20),
    employee_name VARCHAR(100),
    employee_type VARCHAR(50),
    department VARCHAR(100),
    status VARCHAR(50),
    hire_date DATE
);


CREATE TABLE bronze.policies (
    policy_id INT,
    insurer_id INT,
    policy_type_id INT,
    coverage_type_id INT,
    policy_year INT,
    start_date DATE,
    end_date DATE,
    premium_amount NUMERIC(12,2),
    policy_status VARCHAR(50)
);


CREATE TABLE bronze.claims (
    policy_id INT,
    employee_id INT,
    claim_date DATE,
    claim_amount NUMERIC(12,2),
    approved_amount NUMERIC(12,2),
    settlement_date DATE,
    claim_status VARCHAR(50),
    department_id INT
);

COPY bronze.employees
FROM 'C:/data/insurance/dim_employees.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.policies
FROM 'C:/data/insurance/fact_policies.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.claims
FROM 'C:/data/insurance/fact_claims.csv'
DELIMITER ','
CSV HEADER;


-- Sanity Checks

SELECT COUNT(*) FROM bronze.policies;
SELECT COUNT(*) FROM bronze.claims;
SELECT COUNT(*) FROM bronze.employees;