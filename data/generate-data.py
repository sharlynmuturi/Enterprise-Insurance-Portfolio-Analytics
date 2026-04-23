# generate-data.py

from faker import Faker
import pandas as pd
import random
from datetime import timedelta

fake = Faker()

employees = []

for i in range(1000):
    employees.append({
        "employee_id": i + 1,
        "staff_number": f"KEN{10000 + i}",
        "employee_name": fake.name(),
        "employee_type": random.choice(["Staff", "Manager", "Director", "Ex-Staff"]),
        "department": random.choice(["Operations", "Engineering", "Finance", "HR", "ICT"]),
        "status": random.choice(["Active", "Retired", "Resigned"]),
        "hire_date": fake.date_between(start_date='-15y', end_date='-1y')
    })

pd.DataFrame(employees).to_csv("dim_employees.csv", index=False)

employee_df = pd.read_csv("dim_employees.csv")
employee_ids = employee_df["employee_id"].tolist()

insurers = list(range(1,7))
policy_types = list(range(1,13))
coverage_types = list(range(1,8))

policies = []

for i in range(5000):

    start = fake.date_between(start_date='-4y', end_date='today')
    end = start + timedelta(days=365)

    policy_type = random.choice(policy_types)

    # REALISTIC PREMIUM LOGIC
    if policy_type in [1, 2]:  # Group Life / GPA
        premium = random.randint(2000, 8000) * random.randint(100, 500)
    elif policy_type in [3]:  # Motor
        premium = random.randint(80000, 150000) * random.randint(10, 200)
    elif policy_type in [4,5]:  # Fire policies
        premium = random.randint(5000000, 20000000)
    else:  # Engineering / others
        premium = random.randint(2000000, 15000000)

    policies.append({
        "policy_id": i + 1,
        "insurer_id": random.choice(insurers),
        "policy_type_id": policy_type,
        "coverage_type_id": random.choice(coverage_types),
        "policy_year": random.randint(2022, 2025),
        "start_date": start,
        "end_date": end,
        "premium_amount": premium,
        "policy_status": random.choice(["Active", "Expired", "Renewed"])
    })

pd.DataFrame(policies).to_csv("fact_policies.csv", index=False)


claims = []

for i in range(8000):

    policy_id = random.randint(1, 5000)

    claim_amount = random.randint(50000, 10000000)

    approved_ratio = random.choices(
        [0, 0.3, 0.7, 1],
        weights=[0.2, 0.2, 0.4, 0.2]
    )[0]

    approved = int(claim_amount * approved_ratio)

    claims.append({
        "policy_id": policy_id,
        "employee_id": random.choice(employee_ids),

        "claim_date": fake.date_between(start_date='-4y', end_date='today'),
        "claim_amount": claim_amount,
        "approved_amount": approved,

        "settlement_date": fake.date_between(start_date='-3y', end_date='today') if approved > 0 else None,

        "claim_status": "Approved" if approved > 0 else "Rejected",

        "department_id": random.choice([1,2,3])
    })

pd.DataFrame(claims).to_csv("fact_claims.csv", index=False)