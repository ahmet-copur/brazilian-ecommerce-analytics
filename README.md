\# 📊 Olist Brazilian E-Commerce Analytics Project



## 📌 Executive Summary
This repository presents an end-to-end data analytics project using the **Olist Brazilian E-Commerce Dataset** (~100k orders from 2016 to 2018). 

Leveraging **10+ years of domain experience in retail and e-commerce operations**, this analysis bridges technical SQL execution with real-world business strategy. The project translates complex transactional data into actionable insights covering customer behavior, logistics bottlenecks, revenue distribution, and retention dynamics using **Google BigQuery (SQL)** and **Power BI**.

\---


\## 🛠️ Tech Stack \& Tools

\* \*\*Database / Querying:\*\* Google BigQuery (Standard SQL)

\* \*\*Data Visualization:\*\* Power BI Desktop

\* \*\*Version Control:\*\* Git \& GitHub



\---



\## 📁 Repository Structure



├── sql/

│   ├── 01\_monthly\_sales\_performance.sql

│   ├── 02\_customer\_segmentation.sql

│   ├── 03\_category\_performance\_analytics.sql

│   ├── 04\_cohort\_retention\_analysis.sql

│   ├── 05\_delivery\_delay\_sentiment\_analysis.sql

│   ├── 06\_pareto\_customer\_value\_analysis.sql

│   └── 07\_rfm\_segmentation\_analysis.sql

├── powerbi/

│   └── ecommerce\_analytics\_report.pbix

├── docs/

│   ├── category\_performance\_risk\_matrix.png

│   ├── customer\_segmentation\_value\_analysis.png

│   └── revenue\_trend\_mom\_analysis.png

├── LICENSE

└── README.md

\---



\## 🔑 Key Business Analyses \& SQL Queries



1\. \*\*Monthly Sales Performance \& MoM Growth:\*\* Evaluates total revenue trends, Month-over-Month (MoM) growth rates, and 3-month moving averages.

2\. \*\*Customer Spending Quartiles:\*\* Categorizes customers into monetary quartiles using window functions (`NTILE`).

3\. \*\*Category Performance \& Cancellation Analysis:\*\* Identifies top revenue categories alongside delivery duration and order cancellation rates.

4\. \*\*Cohort Retention Analysis:\*\* Tracks customer acquisition cohorts and monthly repeat purchase behavior over time.

5\. \*\*Delivery Delays \& Customer Reviews:\*\* Examines the correlation between delivery delays, review scores, and review text feedback.

6\. \*\*Pareto (80/20) Customer Value Analysis:\*\* Highlights the top customer segments driving 80% of total revenue.

7\. \*\*RFM Segmentation Framework:\*\* Prepares Recency, Frequency, and Monetary scores to classify customers into actionable loyalty tiers.



\---



\## 📈 Power BI Dashboard Previews



\### 1. Revenue Trend \& MoM Analysis

!\[Revenue Trend \& MoM Analysis](docs/revenue\_trend\_mom\_analysis.png)



\### 2. Customer Segmentation \& Value Analysis

!\[Customer Segmentation \& Value Analysis](docs/customer\_segmentation\_value\_analysis.png)



\### 3. Category Performance \& Risk Matrix

!\[Category Performance \& Risk Matrix](docs/category\_performance\_risk\_matrix.png)



\---



\## 🎯 Key Insights \& Recommendations

\* \*\*Delivery Impact:\*\* Orders delivered past the estimated date show a significant drop in customer satisfaction (review scores dropping below 2.0).

\* \*\*Revenue Concentration:\*\* The Pareto analysis reveals high revenue dependency on top-tier buyers, signaling an opportunity for targeted VIP retention programs.



