import numpy as np
import pandas as pd

# Change this folder if you save the downloaded CSV files somewhere else.
data_folder = r"C:...........\brazilian-ecommerce"
output_file = r"C:............\category_performance_summary.csv"

# 1. Load the CSV files
df_orders = pd.read_csv(data_folder + r"\olist_orders_dataset.csv")
df_items = pd.read_csv(data_folder + r"\olist_order_items_dataset.csv")
df_products = pd.read_csv(data_folder + r"\olist_products_dataset.csv")
df_translation = pd.read_csv(
    data_folder + r"\product_category_name_translation.csv"
)

# 2. Join orders, items, product details, and English category names
df_order_items = pd.merge(df_orders, df_items, on="order_id", how="inner")
df_products_items = pd.merge(
    df_order_items, df_products, on="product_id", how="left"
)
df_merged = pd.merge(
    df_products_items,
    df_translation,
    on="product_category_name",
    how="left",
)

# Keep products with missing translations and use their original category name.
df_merged["category_name"] = (
    df_merged["product_category_name_english"]
    .fillna(df_merged["product_category_name"])
    .fillna("uncategorized")
)

# 3. Create separate values for delivered and canceled orders
df_merged["delivered_price"] = df_merged["price"].where(
    df_merged["order_status"] == "delivered", 0
)
df_merged["delivered_freight"] = df_merged["freight_value"].where(
    df_merged["order_status"] == "delivered", 0
)
df_merged["delivered_order_id"] = df_merged["order_id"].where(
    df_merged["order_status"] == "delivered"
)
df_merged["canceled_price"] = df_merged["price"].where(
    df_merged["order_status"] == "canceled", 0
)
df_merged["canceled_order_id"] = df_merged["order_id"].where(
    df_merged["order_status"] == "canceled"
)

# 4. Summarize sales and orders by category
category_analysis = df_merged.groupby("category_name").agg(
    delivered_product_revenue=("delivered_price", "sum"),
    delivered_freight=("delivered_freight", "sum"),
    delivered_orders=("delivered_order_id", "nunique"),
    canceled_product_value=("canceled_price", "sum"),
    canceled_orders=("canceled_order_id", "nunique"),
    total_orders=("order_id", "nunique"),
)

# Cancellation rate = canceled orders / all orders in the category.
category_analysis["cancellation_rate_pct"] = (
    100
    * category_analysis["canceled_orders"]
    / category_analysis["total_orders"].replace(0, np.nan)
)

# Freight ratio = delivered freight / delivered product price.
category_analysis["freight_to_product_value_pct"] = (
    100
    * category_analysis["delivered_freight"]
    / category_analysis["delivered_product_revenue"].replace(0, np.nan)
)

category_analysis = category_analysis.round(2)
category_analysis = category_analysis.sort_values(
    "delivered_product_revenue", ascending=False
)

# 5. Show the top 10 categories and save the full result
print(category_analysis.head(10))

category_analysis.to_csv(output_file)
print("\nFull result saved to:", output_file)
