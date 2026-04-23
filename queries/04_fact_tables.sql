-- 04_fact_tables.sql

DROP TABLE IF EXISTS fact_policies CASCADE;
DROP TABLE IF EXISTS fact_premiums CASCADE;
DROP TABLE IF EXISTS fact_claims CASCADE;

CREATE TABLE fact_policies (
    policy_id SERIAL PRIMARY KEY,
    insurer_id INT REFERENCES dim_insurers(insurer_id),
    policy_type_id INT REFERENCES dim_policy_type(policy_type_id),
    coverage_type_id INT REFERENCES dim_coverage_type(coverage_type_id),
    policy_year INT,
    start_date DATE,
    end_date DATE,
    premium_amount NUMERIC(12,2),
    policy_status VARCHAR(50)
);

CREATE TABLE fact_premiums (
    payment_id SERIAL PRIMARY KEY,
    policy_id INT REFERENCES fact_policies(policy_id),
    payment_date DATE,
    amount_paid NUMERIC(12,2),
    payment_status VARCHAR(50)
);

CREATE TABLE fact_claims (
    claim_id SERIAL PRIMARY KEY,
    policy_id INT REFERENCES fact_policies(policy_id),
    employee_id INT REFERENCES dim_employees(employee_id),
    claim_date DATE,
    claim_amount NUMERIC(12,2),
    approved_amount NUMERIC(12,2),
    settlement_date DATE,
    claim_status VARCHAR(50),
    department_id INT REFERENCES dim_department(department_id),
	approval_ratio INT
);

INSERT INTO fact_policies (
    policy_id,
    insurer_id,
    policy_type_id,
    coverage_type_id,
    policy_year,
    start_date,
    end_date,
    premium_amount,
    policy_status
)
SELECT 
    p.policy_id,
    p.insurer_id,
    p.policy_type_id,
    p.coverage_type_id,
    p.policy_year,
    p.start_date,
    p.end_date,
    p.premium_amount,
    p.policy_status
FROM silver.policies p
WHERE p.premium_amount > 0;



INSERT INTO fact_claims (
    policy_id,
    employee_id,
    claim_date,
    claim_amount,
    approved_amount,
    settlement_date,
    claim_status,
    department_id,
	approval_ratio
)
SELECT 
    c.policy_id,
    c.employee_id,
    c.claim_date,
    c.claim_amount,
    c.approved_amount,
    c.settlement_date,
    c.claim_status,
    c.department_id,
	c.approval_ratio
FROM silver.claims c
JOIN fact_policies p ON c.policy_id = p.policy_id
JOIN dim_employees e ON c.employee_id = e.employee_id
JOIN dim_department d ON c.department_id = d.department_id
WHERE c.claim_amount > 0;



-- Sanity Checks

SELECT COUNT(*) FROM fact_policies;
SELECT COUNT(*) FROM fact_claims;


SELECT COUNT(*)
FROM silver.claims c
JOIN fact_policies p ON c.policy_id = p.policy_id;

SELECT COUNT(*)
FROM silver.claims c
JOIN dim_employees e ON c.employee_id = e.employee_id;

SELECT COUNT(*)
FROM silver.claims c
JOIN dim_department d ON c.department_id = d.department_id;

SELECT * FROM fact_policies;

SELECT * FROM fact_claims;
