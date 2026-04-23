-- 05_analytics.sql

SELECT 
    SUM(premium_amount) AS total_premiums
FROM fact_policies;


SELECT 
    SUM(approved_amount) AS total_claims
FROM fact_claims;

SELECT 
    COUNT(*) AS rejected_claims
FROM fact_claims
WHERE claim_status = 'Rejected';

SELECT 
    ROUND(SUM(c.approved_amount) / SUM(p.premium_amount), 2) AS loss_ratio
FROM fact_claims c
JOIN fact_policies p ON c.policy_id = p.policy_id;

SELECT 
    pt.policy_type_name,
    ct.coverage_name,
    i.insurer_name,
    p.premium_amount,
    p.policy_status
FROM fact_policies p
JOIN dim_policy_type pt ON p.policy_type_id = pt.policy_type_id
JOIN dim_coverage_type ct ON p.coverage_type_id = ct.coverage_type_id
JOIN dim_insurers i ON p.insurer_id = i.insurer_id;


DROP SCHEMA IF EXISTS analytics CASCADE;

CREATE SCHEMA IF NOT EXISTS analytics;


CREATE VIEW analytics.policy_type_count AS
SELECT 
    pt.policy_type_name,
    COUNT(*) AS total_policies
FROM fact_policies p
JOIN dim_policy_type pt ON p.policy_type_id = pt.policy_type_id
GROUP BY pt.policy_type_name
ORDER BY total_policies DESC;

SELECT * FROM analytics.policy_type_count

-----

CREATE VIEW analytics.policy_type_profitability AS
SELECT 
	p.policy_type_id,
    pt.policy_type_name,
	COUNT(*) AS total_policies,
    SUM(p.premium_amount) AS premiums,
    SUM(c.approved_amount) AS claims,
    (SUM(p.premium_amount) - SUM(c.approved_amount)) AS profit
FROM fact_policies p
LEFT JOIN fact_claims c ON p.policy_id = c.policy_id
JOIN dim_policy_type pt ON p.policy_type_id = pt.policy_type_id
GROUP BY pt.policy_type_name, p.policy_type_id;

SELECT * FROM analytics.policy_type_profitability

-----

CREATE VIEW analytics.policy_performance AS
SELECT
    p.policy_type_id,
    COUNT(*) AS total_policies,
    SUM(p.premium_amount) AS total_premium
FROM fact_policies p
GROUP BY p.policy_type_id;

SELECT * FROM analytics.policy_performance

-----

CREATE VIEW analytics.claim_summary AS
SELECT
    policy_id,
    COUNT(*) AS total_claims,
    SUM(approved_amount) AS total_paid
FROM fact_claims
GROUP BY policy_id;

SELECT * FROM analytics.claim_summary

-----

CREATE VIEW analytics.loss_ratio AS
SELECT
    p.policy_type_id,
    SUM(c.approved_amount) / NULLIF(SUM(p.premium_amount),0) AS loss_ratio
FROM fact_policies p
LEFT JOIN fact_claims c
ON p.policy_id = c.policy_id
GROUP BY p.policy_type_id;

SELECT * FROM analytics.loss_ratio

-----

CREATE VIEW analytics.employee_risk AS
SELECT
    e.employee_type,
    COUNT(c.claim_id) AS total_claims,
    SUM(c.approved_amount) AS total_paid,
    AVG(c.approval_ratio) AS avg_approval_ratio
FROM dim_employees e
JOIN fact_claims c
ON e.employee_id = c.employee_id
GROUP BY e.employee_type;

SELECT * FROM analytics.employee_risk

-----

CREATE VIEW analytics.department_risk AS
SELECT
    department_id,
    COUNT(*) AS total_claims,
    SUM(approved_amount) AS total_paid
FROM fact_claims
GROUP BY department_id;

SELECT * FROM analytics.department_risk

-----

CREATE VIEW analytics.claims_status AS
SELECT 
    claim_status,
    COUNT(*) AS total
FROM fact_claims
GROUP BY claim_status;

SELECT * FROM analytics.claims_status

-----


CREATE VIEW analytics.claim_severity AS
SELECT
    policy_id,
    AVG(claim_amount) AS avg_claim,
    MAX(claim_amount) AS max_claim,
    SUM(claim_amount) AS total_claim_value
FROM fact_claims
GROUP BY policy_id;

SELECT * FROM analytics.claim_severity

-----

CREATE VIEW analytics.claim_settlement_time AS
SELECT
    policy_id,
    AVG(settlement_date - claim_date) AS avg_settlement_days
FROM fact_claims
WHERE settlement_date IS NOT NULL
GROUP BY policy_id;


SELECT * FROM analytics.claim_settlement_time

----
-- Loss Ratio Analysis = ∑Approved Claims / ∑Premiums

CREATE VIEW analytics.overall_loss_ratio AS
SELECT 
    SUM(c.approved_amount) AS total_claims,
    SUM(p.premium_amount) AS total_premiums,
    ROUND(SUM(c.approved_amount) / SUM(p.premium_amount), 2) AS loss_ratio
FROM fact_claims c
JOIN fact_policies p ON c.policy_id = p.policy_id;

SELECT * FROM analytics.overall_loss_ratio

----

CREATE VIEW analytics.policy_loss_ratio AS
SELECT 
    pt.policy_type_name,
    SUM(c.approved_amount) AS total_claims,
    SUM(p.premium_amount) AS total_premiums,
    ROUND(SUM(c.approved_amount) / SUM(p.premium_amount), 2) AS loss_ratio
FROM fact_claims c
JOIN fact_policies p ON c.policy_id = p.policy_id
JOIN dim_policy_type pt ON p.policy_type_id = pt.policy_type_id
GROUP BY pt.policy_type_name
ORDER BY loss_ratio DESC;

SELECT * FROM analytics.policy_loss_ratio

----
-- CLAIM FREQUENCY = Number of Claims / Number of /​ Policies

CREATE VIEW analytics.claim_frequency AS
SELECT 
    COUNT(DISTINCT c.claim_id) AS total_claims,
    COUNT(DISTINCT p.policy_id) AS total_policies,
    ROUND(
        COUNT(DISTINCT c.claim_id)::numeric / COUNT(DISTINCT p.policy_id),
        2
    ) AS claim_frequency
FROM fact_claims c
JOIN fact_policies p ON c.policy_id = p.policy_id;

SELECT * FROM analytics.claim_frequency

----

CREATE VIEW analytics.claim_settlement_time AS
SELECT 
    AVG(settlement_date - claim_date) AS avg_settlement_days
FROM fact_claims
WHERE settlement_date IS NOT NULL;

SELECT * FROM analytics.claim_settlement_time

----

CREATE VIEW analytics.policy_claim_settlement_time AS

SELECT 
    pt.policy_type_name,
    AVG(c.settlement_date - c.claim_date) AS avg_days
FROM fact_claims c
JOIN fact_policies p ON c.policy_id = p.policy_id
JOIN dim_policy_type pt ON p.policy_type_id = pt.policy_type_id
WHERE c.settlement_date IS NOT NULL
GROUP BY pt.policy_type_name;

SELECT * FROM analytics.policy_claim_settlement_time

----


CREATE VIEW analytics.claims_trend AS
SELECT 
    DATE_TRUNC('month', claim_date) AS month,
    COUNT(claim_id) AS total_claims,
    SUM(approved_amount) AS total_paid
FROM fact_claims
GROUP BY month
ORDER BY month;

SELECT * FROM analytics.claims_trend

----

CREATE VIEW analytics.insurer_performance AS
SELECT 
    i.insurer_name,
    COUNT(c.claim_id) AS total_claims,
    SUM(c.approved_amount) AS total_paid,
    ROUND(AVG(c.approved_amount), 0) AS avg_claim_size
FROM fact_claims c
JOIN fact_policies p ON c.policy_id = p.policy_id
JOIN dim_insurers i ON p.insurer_id = i.insurer_id
GROUP BY i.insurer_name
ORDER BY total_paid DESC;

SELECT * FROM analytics.insurer_performance

----

CREATE VIEW analytics.coverage_risk_exposure AS
SELECT 
    ct.coverage_name,
    COUNT(c.claim_id) AS claim_count,
    SUM(c.approved_amount) AS total_claims
FROM fact_claims c
JOIN fact_policies p ON c.policy_id = p.policy_id
JOIN dim_coverage_type ct ON p.coverage_type_id = ct.coverage_type_id
GROUP BY ct.coverage_name
ORDER BY total_claims DESC;

SELECT * FROM analytics.coverage_risk_exposure

----

CREATE VIEW analytics.premium_collection_status AS
SELECT 
    payment_status,
    SUM(amount_paid) AS total_amount
FROM fact_premiums
GROUP BY payment_status;

SELECT * FROM analytics.premium_collection_status

----

