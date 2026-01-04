import os
import pandas as pd

# Ensure output folder exists
os.makedirs("04_Python", exist_ok=True)

# Load analysis-ready data
df = pd.read_csv("04_Python/funnel_cohort_data.csv")
df["timestamp"] = pd.to_datetime(df["timestamp"])

# Activity month
df["activity_month"] = df["timestamp"].dt.to_period("M").dt.to_timestamp()

# Cohort size
cohort_size = (
    df.groupby("cohort_month")["session_id"]
    .nunique()
    .rename("cohort_size")
)

# Cohort activity
cohort_activity = (
    df.groupby(["cohort_month", "activity_month"])["session_id"]
    .nunique()
    .reset_index(name="active_sessions")
)

# Pivot table
cohort_pivot = cohort_activity.pivot_table(
    index="cohort_month",
    columns="activity_month",
    values="active_sessions"
)

# Retention %
retention = cohort_pivot.divide(cohort_size, axis=0) * 100

print("Cohort Retention Matrix (%)")
print(retention.round(2))

# Save for visualization
retention.to_csv("04_Python/cohort_retention_matrix.csv")
