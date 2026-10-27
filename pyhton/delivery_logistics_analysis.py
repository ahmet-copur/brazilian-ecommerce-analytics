import numpy as np
import pandas as pd

# These paths match the folders used in the RFM script.
data_folder = r"C:......\brazilian-ecommerce"
rfm_file = r"C:..........\rfm_summary.csv"
output_file = r"............\delivery_rfm_comparison.csv"
customer_output_file = r"C...........\customer_logistics_summary.csv"

# 1. Load orders, customers, and the RFM result
df_orders = pd.read_csv(data_folder + r"\olist_orders_dataset.csv")
df_customers = pd.read_csv(data_folder + r"\olist_customers_dataset.csv")
df_summary = pd.read_csv(rfm_file, index_col=0)

# 2. Convert delivery dates and add each customer's unique ID to their orders
df_orders["order_estimated_delivery_date"] = pd.to_datetime(
    df_orders["order_estimated_delivery_date"]
)
df_orders["order_delivered_customer_date"] = pd.to_datetime(
    df_orders["order_delivered_customer_date"]
)
df_orders_customers = pd.merge(
    df_orders, df_customers, on="customer_id", how="inner"
)

# Only delivered orders can be checked for late delivery.
df_delivered = df_orders_customers[
    df_orders_customers["order_status"] == "delivered"
].copy()

# 3. Calculate how many days late each order was.
# Missing delivery dates remain unknown instead of being treated as on time.
df_delivered["delay_days"] = (
    df_delivered["order_delivered_customer_date"]
    - df_delivered["order_estimated_delivery_date"]
).dt.days
df_delivered["late_days"] = df_delivered["delay_days"].where(
    df_delivered["delay_days"] > 0
)
df_delivered["deliver_check"] = np.select(
    [
        df_delivered["delay_days"].isna(),
        df_delivered["delay_days"] > 0,
    ],
    ["unknown", "late"],
    default="on time or early",
)

# 4. Summarize late deliveries for each customer
df_customer_logistics = df_delivered.groupby("customer_unique_id").agg(
    delivered_orders=("order_id", "nunique"),
    delayed_orders=("late_days", "count"),
    avg_delay_days=("late_days", "mean"),
    unknown_delivery_dates=("deliver_check", lambda values: (values == "unknown").sum()),
).reset_index()
df_customer_logistics["has_delayed"] = df_customer_logistics["delayed_orders"] > 0

# 5. Join the logistics results to the RFM customer table.
# Keep every RFM customer, including customers without a matched logistics row.
df_final = pd.merge(
    df_summary,
    df_customer_logistics,
    on="customer_unique_id",
    how="left",
)
df_final["delayed_orders"] = df_final["delayed_orders"].fillna(0)
df_final["has_delayed"] = df_final["has_delayed"].fillna(False)

# 6. Compare RFM customers with and without at least one late delivery
comparison = df_final.groupby("has_delayed").agg(
    Customer_Count=("Frequency", "count"),
    Avg_Frequency=("Frequency", "mean"),
    Avg_Monetary=("Monetary", "mean"),
    Avg_Delayed_Orders=("delayed_orders", "mean"),
    Avg_Delay_Days=("avg_delay_days", "mean"),
).round(2)

print("--- RFM comparison by late-delivery history ---")
print(comparison)

# 7. Save the comparison and customer-level logistics data
df_final.to_csv(customer_output_file, index=False)
comparison.to_csv(output_file)
print("\nComparison saved to:", output_file)
print("Customer logistics details saved to:", customer_output_file)
