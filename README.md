# Insurance Portfolio Analytics Platform


This project delivers a **full-stack insurance analytics platform** that evaluates **portfolio profitability, risk exposure, and claims behavior**.

Built using a **Medallion Architecture (Bronze - Silver - Gold)**, the solution transforms raw insurance data into **decision-ready insights** for underwriting, finance, and risk teams.

## Business Problem

Insurance organizations must continuously answer:

- Is our portfolio profitable?
- Which policies are driving losses?
- Where is risk concentrated?
- How efficient is our claims process?
- Which customer segments are high-risk?

This project simulates a real-world corporate insurance portfolio and provides **data-driven answers to these questions**.

## Key Features

* Synthetic data generation using realistic insurance logic
* End-to-end data pipeline (ingestion - transformation - analytics)
* KPI-driven analytics (Loss Ratio, Claim Frequency, Severity)
* Business-ready views for dashboards (Power BI / Tableau)
* Risk segmentation across policy, employee, and coverage levels
* Operational efficiency analysis (claims settlement time)


## Architecture

### Medallion Data Model

Raw Data (CSV)  
   ↓  
Bronze Layer (PostgreSQL)  
   ↓  
Silver Layer (Cleaned + Feature Engineering)  
   ↓  
Gold Layer (Star Schema + Analytics Views)

### Data Layers

#### Bronze Layer

- Raw ingestion from CSV files
- No transformations
- Tables: `employees`, `policies`, `claims`

#### Silver Layer

* Data cleaning and validation
* Feature engineering:
    * Policy duration
    * Daily premium
    * Claim approval ratio
    * Rejection flags
    * Employee tenure

#### Gold Layer

*   Star schema model:
    *   Fact tables: `fact_policies`, `fact_claims`, `fact_premiums`
    *   Dimension tables: employees, insurers, policy types, coverage, date
*   Analytics views for reporting:
    *   `loss_ratio`
    *   `claim_frequency`
    *   `policy_profitability`
    *   `claims_trend`
    *   `employee_risk`
    *   `coverage_risk_exposure`

## Key Metrics (KPIs)

*   **Total Premiums**
*   **Total Claims Paid**
*   **Loss Ratio** _(Profitability Indicator)_
*   **Claim Frequency** _(Risk Indicator)_
*   **Claim Severity** _(Financial Exposure)_
*   **Average Settlement Time** _(Operational Efficiency)_


## Sample Insights

*   Certain policy types exhibit **high loss ratios**, indicating pricing or underwriting issues
*   Asset-heavy coverage (e.g. machinery, buildings) drives **majority of claims cost**
*   Claims frequency varies significantly across employee groups
*   Settlement time differs by policy complexity, highlighting **operational inefficiencies**
*   A small subset of policies contributes disproportionately to total risk (**Pareto effect**)


## Tech Stack

*   **Python** (Faker, Pandas) → Data generation
*   **PostgreSQL** → Data warehouse
*   **SQL** → Data transformation & analytics
*   **Star Schema Modeling** → Dimensional design
*   **Medallion Architecture** → Data pipeline design
*   **Power BI / Tableau (Optional)** → Visualization layer



## How to Run the Project

### 1. Generate Data

``` bash
python data/generate-data.py
```
### 2. Load into PostgreSQL

Run in order:

``` bash
01_bronze.sql  
02_silver.sql  
03_dim_tables.sql  
04_fact_tables.sql  
05_analytics.sql
```
### 3. Connect BI Tool

* Power BI / Tableau - connect to PostgreSQL
* Use `analytics` schema for dashboards


## Dashboards

* KPI Overview Dashboard
* Loss Ratio by Policy Type
* Claims Trend Over Time
* Coverage Risk Exposure
* Employee Risk Segmentation
* Claims Settlement Efficiency


## Business Impact

This solution enables:

* Identification of loss-making insurance products
* Early detection of high-risk segments
* Improved pricing and underwriting decisions
* Optimization of claims processing workflows
* Executive-level visibility into portfolio performance

## Future Improvements

* Add **real-time data ingestion (streaming)**
* Implement **machine learning for claim prediction**
* Build **API layer for analytics access**