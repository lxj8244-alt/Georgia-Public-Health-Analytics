SET NOCOUNT ON;

/* =========================================
   Step 1 - Define Reporting Period
========================================= */

DECLARE @DoDYear int = 2025;                   -- Reporting year for death records  
DECLARE @StartYear int = @DoDYear - 1;         -- Previous birth year included      
DECLARE @EndYear int = @DoDYear;               -- Current birth year included       


/* =========================================
   Step 2 - Create Temporary Match Table

   Store matched Birth and Fetal Death records
   linked to Death records during the matching process.
========================================= */


IF OBJECT_ID('tempdb..#MM_Matches') IS NOT NULL DROP TABLE #MM_Matches;

CREATE TABLE #MM_Matches (
    BirthStateFileNumber varchar(15),
    DeathStateFileNumber varchar(15),
    RecordType char(1) -- B = Birth, F = Fetus
);

/* =========================================
   Step 3 - Match Birth Records by
   Mother's Social Security Number
========================================= */

INSERT INTO #MM_Matches
SELECT DISTINCT
    b.StateFileNumber,
    d.StateFileNumber,
    'B'
FROM DeathRecord d
JOIN BirthRecord b ON b.MotherSSN = d.SSN

WHERE d.nDoDYear = @DoDYear
  AND d.Sex = 'F'
  AND ISNULL(d.SSN,'') NOT IN ('','?','999-99-9999','000-00-0000','888-88-8888')
  AND b.nDoBYear BETWEEN @StartYear AND @EndYear
  AND DATEDIFF(day, b.ChildsDateOfBirth, d.dDateOfDeath) BETWEEN 0 AND 365
  AND b.bSearchable = 1
  AND ISNULL(b.bVoid,0) = 0
  AND ISNULL(d.bVoid,0) = 0;

/* =========================================
   Step 4 - Link Death Records to Fetal Death Records
   Using Mother's Social Security Number
========================================= */

INSERT INTO #MM_Matches
SELECT DISTINCT
    f.StateFileNumber,
    d.StateFileNumber,
    'F'
FROM DeathRecord d
JOIN FetalDeathRecord f ON f.MotherSSN = d.SSN
WHERE d.nDoDYear = @DoDYear
  AND d.Sex = 'F'
  AND ISNULL(d.SSN,'') NOT IN ('','?','999-99-9999','000-00-0000','888-88-8888')
  AND f.nDoBYear BETWEEN @StartYear AND @EndYear
  AND DATEDIFF(day, f.dChildsDateOfBirth, d.dDateOfDeath) BETWEEN 0 AND 365
  AND f.bSearchable = 1
  AND ISNULL(f.bVoid,0) = 0
  AND ISNULL(d.bVoid,0) = 0;

/* =========================================
   Step 5 - Match Birth Records by
   Mother's Name and Date of Birth
========================================= */

INSERT INTO #MM_Matches
SELECT DISTINCT
    b.StateFileNumber,
    d.StateFileNumber,
    'B'
FROM DeathRecord d
JOIN BirthRecord b ON
    b.nDoBYear BETWEEN @StartYear AND @EndYear
    AND REPLACE(REPLACE(REPLACE(b.MotherFirstName,'''',''),'-',''),' ','')
      = REPLACE(REPLACE(REPLACE(d.DecedentFirstName,'''',''),'-',''),' ','')
    AND REPLACE(REPLACE(REPLACE(b.MotherLastName,'''',''),'-',''),' ','')
      = REPLACE(REPLACE(REPLACE(d.DecedentLastName,'''',''),'-',''),' ','')
    AND b.MotherDOB = d.DOB
    AND DATEDIFF(day, b.ChildsDateOfBirth, d.dDateOfDeath) <= 365
    AND b.bSearchable = 1
    AND ISNULL(b.bVoid,0) = 0
WHERE d.nDoDYear = @EndYear
  AND d.Sex = 'F'
  --AND d.Age BETWEEN 5 AND 75
  --AND d.AgeUnitsDesc = 'years'
  AND ISNULL(d.bVoid,0) = 0
  AND NOT EXISTS (
      SELECT 1 FROM #MM_Matches m
      WHERE m.DeathStateFileNumber = d.StateFileNumber
  );

/* =========================================
   Step 6 - Link Death Records to Birth Records
   Using Mother's First Name, Maiden Name,
   and Date of Birth
========================================= */

INSERT INTO #MM_Matches
SELECT DISTINCT
    b.StateFileNumber,
    d.StateFileNumber,
    'B'
FROM DeathRecord d
JOIN BirthRecord b ON
    b.nDoBYear BETWEEN @StartYear AND @EndYear
    AND REPLACE(REPLACE(REPLACE(b.MotherFirstName,'''',''),'-',''),' ','')
      = REPLACE(REPLACE(REPLACE(d.DecedentFirstName,'''',''),'-',''),' ','')
    AND REPLACE(REPLACE(REPLACE(b.MotherMaidenLastName,'''',''),'-',''),' ','')
      = REPLACE(REPLACE(REPLACE(d.DecedentMaidenLastName,'''',''),'-',''),' ','')
    AND b.MotherDOB = d.DOB
    AND DATEDIFF(day, b.ChildsDateOfBirth, d.dDateOfDeath) <= 365
    AND b.bSearchable = 1
    AND ISNULL(b.bVoid,0) = 0
WHERE d.nDoDYear = @EndYear
  AND d.Sex = 'F'
  --AND d.nAge BETWEEN 5 AND 75
  --AND d.cAgeUnitsDesc = 'years'
  AND ISNULL(d.bVoid,0) = 0
  AND NOT EXISTS (
      SELECT 1 FROM #MM_Matches m
      WHERE m.DeathStateFileNumber = d.StateFileNumber
  );

/* =========================================
   Step 7 - Link Death Records to Fetal Death Records
   Using Mother's Last or Maiden Name
   and Date of Birth
========================================= */

INSERT INTO #MM_Matches
SELECT DISTINCT
    f.StateFileNumber,
    d.StateFileNumber,
    'F' -- Fetus Type
FROM DeathRecord d

JOIN FetalDeathRecord f ON
    f.nDoBYear BETWEEN @StartYear AND @EndYear
    
    AND REPLACE(REPLACE(REPLACE(f.MotherFirstName,'''',''),'-',''),' ','')
      = REPLACE(REPLACE(REPLACE(d.DecedentFirstName,'''',''),'-',''),' ','')
    AND (
        REPLACE(REPLACE(REPLACE(f.MotherLastName,'''',''),'-',''),' ','')
          = REPLACE(REPLACE(REPLACE(d.DecedentLastName,'''',''),'-',''),' ','')
        OR 
        REPLACE(REPLACE(REPLACE(f.MotherMaidenLastName,'''',''),'-',''),' ','')
          = REPLACE(REPLACE(REPLACE(d.DecedentMaidenLastName,'''',''),'-',''),' ','')
    )
    AND f.MotherDOB = d.DOB -- Mother's Date of Birth matches
    AND DATEDIFF(day, f.dChildsDateOfBirth, d.dDateOfDeath) BETWEEN 0 AND 365
    AND f.bSearchable = 1
    AND ISNULL(f.bVoid,0) = 0
WHERE d.nDoDYear = @EndYear
  AND d.Sex = 'F'
  AND ISNULL(d.bVoid,0) = 0
  AND NOT EXISTS (
      SELECT 1 FROM #MM_Matches m
      WHERE m.DeathStateFileNumber = d.StateFileNumber
  );

/* =========================================
   Step 8 - Return Final Potential
   Maternal Mortality Cases
========================================= */
SELECT
     ISNULL(d.StateFileNumber,'') 'DeathStateFileNumber'
	, d.dDateOfDeath
	, ISNULL(d.DecedentFirstName,'') cDecedentFirstName
	, ISNULL(d.DecedentLastName,'') cDecedentLastName
	, ISNULL(d.DecedentMaidenLastName,'') cDecedentMaidenLastName
	, d.DOB
	--, d.nAge 'Age'
	, ISNULL(d.SSN,'') SSN

	, CASE mm.RecordType 
		WHEN 'B' THEN b.StateFileNumber
		WHEN 'F' THEN f.StateFileNumber
		else '' end 'BirthStateFileNumber'
	, ISNULL(CASE mm.RecordType 
		WHEN 'B' THEN b.MotherSSN
		WHEN 'F' THEN f.MotherSSN
		else '' end,'') 'cMothersSSN'
	, CASE mm.RecordType 
		WHEN 'B' THEN b.ChildsDateOfBirth
		WHEN 'F' THEN f.dChildsDateOfBirth
		else '' end 'BirthChildDateOfBirth'
	, ISNULL(mm.RecordType,'') 'BirthMatchType'
	,ISNULL(d.ICDCode1, '') AS ICDCode1
    ,ISNULL(d.ICDCode2, '') AS ICDCode2
	, isnull(d.CauseOfDeathA ,'') cCauseOfDeathA 
	, isnull(d.CauseOfDeathB ,'')	cCauseOfDeathB 
	, isnull(d.SignificantConditions,'')	SignificantConditions
	, isnull(d.Race,'') Race
	, isnull(d.countyName,'') County

FROM DeathRecord d

	LEFT JOIN #MM_Matches mm on mm.DeathStateFileNumber = d.StateFileNumber
	LEFT JOIN BirthRecord b on b.StateFileNumber = mm.BirthStateFileNumber and mm.RecordType = 'B' and b.bSearchable = 1
	LEFT JOIN FetalDeathRecord f on f.StateFileNumber = mm.BirthStateFileNumber and mm.RecordType = 'F' and f.bSearchable = 1
WHERE
    d.nDoDYear = @DoDYear
  --AND d.nAge BETWEEN 5 AND 75
    AND d.Sex = 'F'
    AND ISNULL(d.bVoid, 0) = 0
    AND (
	  -- 1. Pregnancy status indicates a current or recent pregnancy
      -- (cPregnant: 1 = Not Pregnant, 2-4 = Current or Recent Pregnancy)
        d.cPregnant IN (2, 3, 4)
       
        -- 2. Already linked to a Birth or Fetal Death record
        OR d.StateFileNumber IN (SELECT DeathStateFileNumber FROM #MM_Matches)
        
        -- 3. ICD-10 O-codes indicating pregnancy-related conditions
        OR d.ICDCode1 LIKE 'O%' 
        OR d.ICDCode2 LIKE 'O%'
        
        -- 4. Cause of death contains pregnancy-related keywords

OR (
    (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%amniotic%'      
    OR (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%eclampsia%'     
    OR (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%HELLP%'         
    OR (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%postpartum%'    
    OR (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%peripartum%'    
    OR (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%ectopic%'       
    OR (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%uterine rupture%' 
    OR (ISNULL(d.CauseOfDeathA,'')+ISNULL(d.CauseOfDeathB,'')+ISNULL(d.SignificantConditions,'')) LIKE '%abruptio%'      
)
    )

AND ISNULL(d.bAbandon,0) = 0 -- Treat NULL as 0 because untouched records remain NULL in GAVERS.

ORDER BY d.dDateOfDeath;

/* =========================================
   Step 9 - Clean Up Temporary Objects
========================================= */

DROP TABLE #MM_Matches;

