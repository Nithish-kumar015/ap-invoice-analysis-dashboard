# AP Invoice Analysis Dashboard

A SQL Server and Power BI portfolio project exploring Accounts Payable invoice processing, SLA performance, late payments, and exceptions.

> **Dataset note:** This project uses generated, deterministic demonstration data. It does not contain records from a real company, and its findings should not be presented as real operational results.

## Business question

How can an AP team monitor invoice processing and payment performance, identify exceptions, and decide which areas to investigate?

## What I built

A two-page Power BI report supported by T-SQL analysis and validation queries:

- **Overview:** invoice volume and value, processing time, SLA performance, payment delays, and exceptions.
- **Vendor Analysis:** the top 10 vendors by late-payment count, with a vendor-region slicer.

The report uses DAX measures for its KPI cards and chart calculations.

## Results shown in the report

- **1,200 invoices** with a total value of **INR 46.43 million**.
- **4.57 days** average processing time from receipt to Ready for Payment.
- **1,028 invoices met** the five-day SLA; **172 breached** it (**85.67% compliance**).
- **360 invoices were paid late** (**30%**), with an average delay of **2.83 days**.
- **240 invoices had an exception** (**20%**); the generated data has 60 exceptions in each of four categories.

## How to interpret these results

The SQL scripts generate 100 vendors with 12 invoices each and create exception rows using fixed rules. Equal monthly invoice volumes and balanced exception-category counts are part of the data-generation design. Department and vendor patterns demonstrate report interactions; they do not establish real-world causes or prove that a particular team or supplier is responsible for delays.

In a live AP environment, the same checks could help prioritize follow-up. The team should validate trends against production data, invoice volumes, and business context before taking action.

## Files

- **01_SQL/** — database setup, dimension and fact-table creation, generated data, analysis, and Power BI validation queries.
- **03_PowerBI/** — the Power BI report and its exported PDF.
- **04_Documentation/** — analytical questions.
- **05_Project_demo/** — note about the separate walkthrough demo folder.

[Open the exported two-page report](03_PowerBI/Ap_invoice_analysis_BI_report.pdf).

## Reproducing the project

The SQL files use Microsoft SQL Server T-SQL. Run the setup scripts on a clean database in this order:

1. 01_database.sql
2. 02_dim_tables.sql
3. 03_data_reference.sql
4. 05_fact_table.sql — run once to generate the fact data
5. 04_verification.sql
6. 06.final_analysis.sql
7. 07_BI_validation.sql

## Tools

SQL Server (T-SQL) · Power BI Desktop · DAX
