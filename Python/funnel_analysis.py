import pandas as pd

df = pd.read_csv("04_Python/funnel_cohort_data.csv")

funnel_df = (
    df.groupby(["funnel_step", "event_type"])["session_id"]
    .nunique()
    .reset_index(name="sessions")
    .sort_values("funnel_step")
)

funnel_df["conversion_rate_pct"] = (
    funnel_df["sessions"] / funnel_df["sessions"].shift(1) * 100
)

funnel_df["dropoff_rate_pct"] = 100 - funnel_df["conversion_rate_pct"]

print("Funnel Analysis")
print(funnel_df)
