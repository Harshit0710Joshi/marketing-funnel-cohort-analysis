import os
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine(
    "postgresql+psycopg2://postgres:root@localhost:5432/marketing_funnel"
)

query = "SELECT * FROM funnel_cohort_data"
df = pd.read_sql(query, engine)

df["timestamp"] = pd.to_datetime(df["timestamp"])

print("Data loaded successfully")
print(df.head())
print(df.shape)

# -------------------------------
# FIX: Ensure output directory exists
# -------------------------------
output_dir = "04_Python"
os.makedirs(output_dir, exist_ok=True)

output_path = os.path.join(output_dir, "funnel_cohort_data.csv")
df.to_csv(output_path, index=False)

print(f"Data saved to {output_path}")
