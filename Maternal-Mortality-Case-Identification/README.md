# Maternal Mortality Case Identification Using SQL Server

## 1. Project Overview

This project demonstrates a SQL Server solution for identifying potential maternal mortality cases by integrating multiple vital records datasets. It was developed using **synthetic data** to simulate real-world public health data quality workflows while protecting confidential information.

The workflow begins with death records and identifies potential maternal mortality cases by applying multiple matching strategies, including pregnancy indicators, ICD-10 pregnancy-related diagnosis codes, cause-of-death keywords, and record linkage with Birth and Fetal Death records.

The objective is to demonstrate how SQL can support public health surveillance, data quality improvement, and maternal mortality case identification.

---

## 2. Matching Criteria

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

## 3. Objectives

* Design a relational SQL Server database for maternal mortality analysis.
* Demonstrate advanced SQL querying and multi-step record matching.
* Simulate a real-world public health data quality workflow.
* Develop a reusable SQL process for maternal mortality case identification and validation.

---

## 4. Technologies Used

* Microsoft SQL Server
* Transact-SQL (T-SQL)
* Temporary Tables
* SQL Joins
* CASE Expressions
* Conditional Logic
* Record Matching Techniques

---

## 5. Project Highlights

* Multi-source record matching
* Multiple matching strategies to improve case identification
* Pregnancy status validation
* ICD-10 O-code identification
* Cause-of-death keyword analysis
* Temporary table workflow
* Clean, modular, and well-documented SQL scripts

---

## 6. Disclaimer

This project uses **synthetic data** created exclusively for portfolio and educational purposes.

Although the workflow is inspired by public health data quality processes used in vital records management, **no production data, confidential information, or personally identifiable information (PII) is included**.

The project is intended solely to demonstrate SQL development, record linkage techniques, and data quality methodologies.

## 7. Database ERD
```mermaid
flowchart TD
    %% 최상단 루트 노드
    DB["MaternalMortalityDB"]

    %% 세 갈래 분기 처리
    DB --> DeathRecord
    DB --> BirthRecord
    DB --> FetalDeathRecord

    %% DeathRecord 테이블
    subgraph DeathRecord ["DeathRecord"]
        D_Fields["PK DeathSFN<br>SSN<br>FirstName<br>LastName<br>DOB<br>DateOfDeath<br>PregnancyStatus<br>ICD10<br>CauseOfDeath<br>County<br>Race"]
    end

    %% BirthRecord 테이블
    subgraph BirthRecord ["BirthRecord"]
        B_Fields["PK BirthSFN<br>MotherSSN<br>MotherFirstName<br>MotherLastName<br>MaidenName<br>MotherDOB<br>ChildDOB<br>County"]
    end

    %% FetalDeathRecord 테이블
    subgraph FetalDeathRecord ["FetalDeathRecord"]
        F_Fields["PK FetalDeathSFN<br>MotherSSN<br>MotherFirstName<br>MotherLastName<br>MaidenName<br>MotherDOB<br>FetalDOB<br>County"]
    end

    %% 하단 설명문 (테두리와 배경 없는 투명 텍스트로 처리)
    Note["Logical Relationship (No Physical Foreign Keys)"]
    
    %% 가상의 선을 연결하되 선은 안 보이게 처리하여 하단 중앙에 배치
    BirthRecord ~~~ Note

    %% 상단 DB 타이틀 및 하단 설명문 스타일링
    style DB fill:#1e293b,stroke:#0f172a,stroke-width:2px,color:#fff,font-weight:bold
    style Note fill:none,stroke:none,color:#475569,font-weight:bold,font-size:14px
    
    %% 각 박스 스타일링 (배경색 및 테두리 색상 지정)
    style D_Fields fill:#eff6ff,stroke:#bfdbfe,stroke-width:1px,text-align:left
    style B_Fields fill:#f0fdf4,stroke:#bbf7d0,stroke-width:1px,text-align:left
    style F_Fields fill:#faf5ff,stroke:#e9d5ff,stroke-width:1px,text-align:left

    %% 서브그래프 테두리 연하게 처리
    style DeathRecord fill:none,stroke:#94a3b8,stroke-dasharray: 5 5
    style BirthRecord fill:none,stroke:#94a3b8,stroke-dasharray: 5 5
    style FetalDeathRecord fill:none,stroke:#94a3b8,stroke-dasharray: 5 5

## 8. SQL Matching Workflow

