# Hotel Booking Analytics Platform

## 1. Project Overview
This project implements an end-to-end Hotel Booking Analytics Platform using Databricks Lakeflow Spark Declarative Pipelines.

The objective is to process raw hotel booking data, clean and transform it, generate business insights, and build an interactive dashboard.

## 2. Technologies Used
- Databricks
- Lakeflow Spark Declarative Pipelines
- SQL
- Unity Catalog
- Databricks AI/BI Dashboards

## 3. Dataset
The project uses a synthetic hotel booking dataset containing 1,316 raw records and 20 columns.

The dataset includes booking details, guest information, hotel details, room types, booking channels, payment information, and booking status.

## 4. Project Architecture

The project follows a Medallion Architecture:

- **Bronze Layer:** Ingests raw CSV data into a streaming table.
- **Silver Layer:** Cleans data, removes duplicates, handles missing values, and separates rejected records.
- **Gold Layer:** Creates business-level summary tables for analysis.

## 5. Data Cleaning
The following operations were performed:
- Removed duplicate booking IDs.
- Trimmed unnecessary spaces.
- Standardized text values.
- Replaced missing city and booking channel values with Unknown.
- Calculated missing nights and total amounts where possible.
- Identified invalid dates and negative room rates.
- Separated rejected records from clean records.

## 6. Gold Tables
Four analytical tables were created:

1. gold_monthly_bookings
2. gold_hotel_summary
3. gold_room_type_summary
4. gold_channel_summary

An additional data quality table, gold_data_quality, was created for validation and reconciliation.

## 7. Data Quality Results

| Metric | Result |
|---|---:|
| Bronze Records | 1,316 |
| Clean Records | 1,269 |
| Rejected Records | 21 |
| Duplicate Records | 26 |
| Reconciliation Difference | 0 |

The reconciliation check passed successfully.

## 8. Dashboard
A Databricks AI/BI Dashboard was created with three pages:

- **Overview:** Booking trends, net revenue, and booking channel distribution.
- **Hotel & Booking Analysis:** Hotel revenue, room type bookings, and channel cancellation rates.
- **Data Quality:** Bronze, clean, rejected, duplicate, and reconciliation KPIs.

## 9. Conclusion
This project demonstrates an end-to-end data engineering workflow using Databricks. It transforms raw hotel booking data into clean, structured, and analytical datasets and presents meaningful business insights through an interactive dashboard.
