# Maternal Mortality Case Identification Using SQL Server

## 1. Project Overview

This project demonstrates a SQL Server solution for identifying potential maternal mortality cases by integrating multiple vital records datasets. It was developed using **synthetic data** to simulate real-world public health data quality workflows while protecting confidential information.

The workflow begins with death records and identifies potential maternal mortality cases by applying multiple matching strategies, including pregnancy indicators, ICD-10 pregnancy-related diagnosis codes, cause-of-death keywords, and record linkage with Birth and Fetal Death records.

The objective is to demonstrate how SQL can support public health surveillance, data quality improvement, and maternal mortality case identification.

---

### Matching Criteria

Potential maternal mortality cases are identified using multiple complementary matching strategies.

### Pregnancy Indicators

* Pregnancy status recorded on the death certificate

 ### Record Linkage

* Match to Birth Records using Social Security Number (SSN)
* Match to Fetal Death Records using Social Security Number (SSN)
* Match using Mother's Name and Date of Birth
* Match using Mother's Maiden Name and Date of Birth

 ### Clinical Indicators

* Pregnancy-related ICD-10 O-codes
* Pregnancy-related cause-of-death keywords

Matched records from each strategy are consolidated into a temporary table and returned as a final list of potential maternal mortality cases for further review.

---

### Objectives

* Design a relational SQL Server database for maternal mortality analysis.
* Demonstrate advanced SQL querying and multi-step record matching.
* Simulate a real-world public health data quality workflow.
* Develop a reusable SQL process for maternal mortality case identification and validation.

---

## Technologies Used

* Microsoft SQL Server
* Transact-SQL (T-SQL)
* Temporary Tables
* SQL Joins
* CASE Expressions
* Conditional Logic
* Record Matching Techniques

---

## Project Highlights

* Multi-source record matching
* Multiple matching strategies to improve case identification
* Pregnancy status validation
* ICD-10 O-code identification
* Cause-of-death keyword analysis
* Temporary table workflow
* Clean, modular, and well-documented SQL scripts

---

## Disclaimer

This project uses **synthetic data** created exclusively for portfolio and educational purposes.

Although the workflow is inspired by public health data quality processes used in vital records management, **no production data, confidential information, or personally identifiable information (PII) is included**.

The project is intended solely to demonstrate SQL development, record linkage techniques, and data quality methodologies.

