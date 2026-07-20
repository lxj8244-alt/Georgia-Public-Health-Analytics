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

---

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
    Note["Logical Relationship<br>(No Physical Foreign Keys)"]
    
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
```

---

## 8. SQL Matching Workflow
```mermaid
flowchart TD
    %% 1단계: Starting Dataset
    Start["<div style='padding: 5px 10px;'><b>DeathRecord</b><br><span style='font-size: 12px; color: #64748b;'>(Starting Dataset)</span></div>"]

    %% 2단계: 가로로 나란히 배치되는 3개의 박스
    MatchBirth["<div style='padding: 10px; line-height: 1.6;'><b>Match Birth Records</b><div style='border-top: 1px solid #bbf7d0; margin: 6px 0;'></div><span style='font-size: 13px; color: #334155;'>1. SSN<br>2. First + Last + DOB<br>3. First + Maiden + DOB</span></div>"]

    Filter["<div style='padding: 10px; line-height: 1.6;'><b>Filter Potential Cases</b><div style='border-top: 1px solid #cbd5e1; margin: 6px 0;'></div><span style='font-size: 13px; color: #334155;'>• Pregnancy Status<br>• ICD-10 O Codes<br>• Cause of Death Keywords</span></div>"]
    
    MatchFetal["<div style='padding: 10px; line-height: 1.6;'><b>Match Fetal Death Records</b><div style='border-top: 1px solid #e9d5ff; margin: 6px 0;'></div><span style='font-size: 13px; color: #334155;'>1. SSN<br>2. First + Last + DOB<br>3. First + Maiden + DOB</span></div>"]

    %% 3단계: 매칭 결과 합쳐짐
    Matches["<div style='padding: 8px 15px;'><b>#MM_Matches</b><br><span style='font-size: 12px; color: #c2410c;'>(Matched Candidate Cases)</span></div>"]

    %% 4단계: 최종 결과
    Final["<div style='padding: 10px 20px; font-weight: bold; letter-spacing: 0.5px;'>Potential Maternal<br>Mortality Cases</div>"]

    %% 위에서 세 갈래로 연결 (Death Record -> 3개 박스)
    Start --> MatchBirth
    Start --> Filter
    Start --> MatchFetal

    %% 아래에서 하나로 취합 (3개 박스 -> #MM_Matches)
    MatchBirth --> Matches
    Filter --> Matches
    MatchFetal --> Matches

    %% #MM_Matches -> 최종 결과
    Matches --> Final

    %% 스타일링
    style Start fill:#eff6ff,stroke:#bfdbfe,stroke-width:1.5px
    
    style MatchBirth fill:#f0fdf4,stroke:#bbf7d0,stroke-width:1.5px,text-align:left
    style Filter fill:#f8fafc,stroke:#cbd5e1,stroke-width:1.5px,text-align:left
    style MatchFetal fill:#faf5ff,stroke:#e9d5ff,stroke-width:1.5px,text-align:left
    
    style Matches fill:#fff7ed,stroke:#ffedd5,stroke-width:1.5px
    style Final fill:#1e293b,stroke:#0f172a,stroke-width:1.5px,color:#fff
```

---

## 9. SQL Script

This project includes a complete SQL Server implementation for maternal mortality case identification.

The SQL script demonstrates:

- Defining the reporting period
- Creating temporary matching tables
- Matching Birth Records by SSN
- Matching Fetal Death Records by SSN
- Matching by Mother's Name and Date of Birth
- Matching by Maiden Name and Date of Birth
- Identifying pregnancy-related ICD-10 O-codes
- Searching pregnancy-related cause-of-death keywords
- Returning consolidated potential maternal mortality cases

### SQL Source Code

➡️ **[MaternalMortalityCaseIdentification.sql](MaternalMortalityCaseIdentification.sql)**

The SQL script is fully documented with step-by-step comments to demonstrate the complete matching workflow and data quality process.

---

## 10. Sample SQL Output

The SQL script demonstrates the maternal mortality case identification workflow using a synthetic **2025** dataset.

The sample output below illustrates how death records are matched to birth records through the multi-step matching process.

| Death SFN | Date of Death | First Name | Last Name | ICD-10 | Cause of Death | Race | County |
|-----------|---------------|------------|-----------|--------|----------------|------|--------|
| 2025GA000617 | 01/04/2025 | David | Thomas | C34 | Cancer | Black | Bartow |
| 2025GA000579 | 01/22/2025 | Joseph | Wilson | J44 | ectopic | Other | Coweta |
| 2025GA000575 | 01/24/2025 | William | Garcia | J44 | eclampsia | Asian | Effingham |
| 2025GA000588 | 01/30/2025 | Robert | Anderson | O96 | Cancer | White | Gordon |
| 2025GA000581 | 02/06/2025 | John | Jones | I21 | abruptio | Asian | Fulton |
| 2025GA000580 | 04/01/2025 | Joseph | Garcia | I50 | uterine rupture | White | Fulton |

### Complete Sample Dataset

The complete sample dataset is available below.

➡️ **[MaternalMortalityOutput2025.csv](MaternalMortalityOutput2025.csv)**

> **Note:** All records shown are synthetic and are intended solely for demonstrating SQL-based record linkage and maternal mortality case identification techniques.

---

## 11. Tableau Dashboard

The SQL output generated in this project serves as the data source for an interactive Tableau dashboard.

The dashboard will include:

## Dashboard Preview

![Georgia Maternal Mortality Dashboard](Georgia_Maternal_Mortality_Dashboard.png)

- Maternal Mortality Rate (per 100,000 live births)
- Maternal Deaths by Race
- County-level geographic analysis
- Top counties by race
- Interactive filters

### Interactive Dashboard

[View on Tableau Public](https://public.tableau.com/views/YourDashboardName)

## Methodology

- Maternal death records were generated using synthetic data.
- Live birth totals (2021–2025) were obtained from the Georgia OASIS database.
- Maternal Mortality Rate was calculated as:

  **(Maternal Deaths ÷ Live Births) × 100,000**

> **Note:** This dashboard uses synthetic maternal mortality data for portfolio purposes and does not represent official Georgia public health statistics.

---

## 12. Future Enhancements

Future enhancements may include:

- Additional statistical analyses using R.
- Advanced data visualizations with ggplot2.
- Expanded public health trend analysis using Georgia OASIS data.

### Example R Analysis

**R Source Code:** [Birth_Trend_Analysis.R](Birth_Trend_Analysis.R)

![R Visualization](R_Birth_Trend.png)
