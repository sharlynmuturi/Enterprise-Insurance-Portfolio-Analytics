-- 02_silver.sql

DROP SCHEMA IF EXISTS silver CASCADE;

CREATE SCHEMA IF NOT EXISTS silver;



CREATE TABLE silver.employees AS
SELECT *, 
	DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS years_of_service
FROM bronze.employees
WHERE staff_number IS NOT NULL;



CREATE TABLE silver.policies AS
SELECT *,
    (end_date - start_date) AS policy_duration_days,
    premium_amount / NULLIF((end_date - start_date), 0) AS daily_premium
FROM bronze.policies
WHERE premium_amount > 0;



CREATE TABLE silver.claims AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY claim_date, policy_id) AS claim_id,
	c.*,
    (claim_amount - approved_amount) AS claim_rejected_value,
    CASE 
        WHEN approved_amount = 0 THEN 1 ELSE 0 
    END AS is_rejected,
    CASE 
        WHEN approved_amount > 0 THEN approved_amount / claim_amount 
        ELSE 0 
    END AS approval_ratio
FROM bronze.claims c
WHERE claim_amount > 0;


-- Sanity Checks

SELECT COUNT(*) FROM silver.policies;
SELECT COUNT(*) FROM silver.claims;

SELECT 
    MIN(policy_id),
    MAX(policy_id),
    COUNT(*)
FROM silver.policies;

SELECT 
    MIN(policy_id),
    MAX(policy_id),
    COUNT(*)
FROM silver.claims;

SELECT COUNT(*)
FROM silver.claims c
JOIN silver.employees e
ON c.employee_id = e.employee_id;