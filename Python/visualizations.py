import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_style("whitegrid")

# Funnel plot
df = pd.read_csv("04_Python/funnel_cohort_data.csv")

funnel_plot = (
    df.groupby(["funnel_step", "event_type"])["session_id"]
    .nunique()
    .reset_index(name="sessions")
    .sort_values("funnel_step")
)

plt.figure(figsize=(8,5))
sns.barplot(x="event_type", y="sessions", data=funnel_plot)
plt.title("Funnel Stage Sessions")
plt.xlabel("Funnel Stage")
plt.ylabel("Sessions")
plt.show()

# Cohort heatmap
retention = pd.read_csv("04_Python/cohort_retention_matrix.csv", index_col=0)

plt.figure(figsize=(12,6))
sns.heatmap(retention, annot=True, fmt=".1f", cmap="Blues")
plt.title("Cohort Retention Heatmap (%)")
plt.xlabel("Activity Month")
plt.ylabel("Cohort Month")
plt.show()
