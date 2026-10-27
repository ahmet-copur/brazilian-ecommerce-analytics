import numpy as np
import pandas as pd

# Change this folder if you save the downloaded CSV files somewhere else.
data_folder = r"C:.................\brazilian-ecommerce"
output_file = r"C:..................\rfm_summary.csv"

# 1. Load the CSV files
df_orders = pd.read_csv(data_folder + r"\olist_orders_dataset.csv")
df_items = pd.read_csv(data_folder + r"\olist_order_items_dataset.csv")
df_customers = pd.read_csv(data_folder + r"\olist_customers_dataset.csv")

# 2. Join orders to items and customer IDs
df_order_items = pd.merge(df_orders, df_items, on="order_id", how="inner")
df_merged = pd.merge(
    df_order_items, df_customers, on="customer_id", how="inner"
)

# 3. Convert the order date and keep delivered orders
df_merged["order_purchase_timestamp"] = pd.to_datetime(
    df_merged["order_purchase_timestamp"]
)
df_delivered = df_merged[df_merged["order_status"] == "delivered"].copy()

# Use the day after the latest purchase as the RFM reference date.
reference_date = df_delivered["order_purchase_timestamp"].max().normalize() + pd.Timedelta(
    days=1
)

# 4. Calculate Recency, Frequency, and Monetary value per customer
df_summary = df_delivered.groupby("customer_unique_id").agg(
    Monetary=("price", "sum"),
    Frequency=("order_id", "nunique"),
    first_order_date=("order_purchase_timestamp", "min"),
    last_order_date=("order_purchase_timestamp", "max"),
)
df_summary["Recency"] = (
    reference_date - df_summary["last_order_date"].dt.normalize()
).dt.days

# 5. Give each customer a score from 1 (low) to 5 (high).
# Ranking first lets qcut handle customers with identical values.
df_summary["R_score"] = pd.qcut(
    df_summary["Recency"].rank(method="first", ascending=False),
    q=5,
    labels=[1, 2, 3, 4, 5],
).astype(int)
df_summary["F_Score"] = pd.qcut(
    df_summary["Frequency"].rank(method="first"),
    q=5,
    labels=[1, 2, 3, 4, 5],
).astype(int)
df_summary["M_Score"] = pd.qcut(
    df_summary["Monetary"].rank(method="first"),
    q=5,
    labels=[1, 2, 3, 4, 5],
).astype(int)

# 6. Assign a customer segment using Recency and Frequency scores.
segment_conditions = [
    (df_summary["R_score"] >= 4)
    & (df_summary["F_Score"] >= 4)
    & (df_summary["M_Score"] >= 4),
    (df_summary["R_score"] == 1)
    & (df_summary["F_Score"] >= 4)
    & (df_summary["M_Score"] >= 4),
    (df_summary["R_score"] >= 3) & (df_summary["F_Score"] >= 4),
    (df_summary["R_score"] >= 4) & (df_summary["F_Score"].between(2, 3)),
    (df_summary["R_score"] == 5) & (df_summary["F_Score"] == 1),
    (df_summary["R_score"] == 4) & (df_summary["F_Score"] == 1),
    (df_summary["R_score"] == 3) & (df_summary["F_Score"] <= 3),
    (df_summary["R_score"] == 2) & (df_summary["F_Score"] <= 2),
    (df_summary["R_score"] <= 2) & (df_summary["F_Score"] >= 3),
    (df_summary["R_score"] == 1) & (df_summary["F_Score"] <= 2),
]

# These names match the conditions above in the same order.
segment_names = [
    "Champions",
    "Cannot Lose Them",
    "Loyal Customers",
    "Potential Loyalists",
    "New Customers",
    "Promising",
    "Needs Attention",
    "About to Sleep",
    "At Risk",
    "Hibernating",
]

df_summary["Segment"] = np.select(
    segment_conditions,
    segment_names,
    default="Others",
)
df_summary["RFM_Score"] = (
    df_summary["R_score"].astype(str)
    + df_summary["F_Score"].astype(str)
    + df_summary["M_Score"].astype(str)
)
df_summary["Monetary"] = df_summary["Monetary"].round(2)

# 7. Show example rows and customer counts by segment
print(
    df_summary[
        ["Recency", "Frequency", "Monetary", "R_score", "F_Score", "M_Score", "Segment"]
    ].head(10)
)
print("\nCustomer count by segment:")
print(df_summary["Segment"].value_counts())

# 8. Save the customer-level RFM table for the logistics script
df_summary.to_csv(output_file)
print("\nRFM result saved to:", output_file)
