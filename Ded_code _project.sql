--## Data Cleaning ##--

--- Delete null datas---
DELETE Deduction
WHERE Batch_ID is null;

--- Remove entries other than QP---
DELETE FROM Deduction
WHERE Batch_ID NOT LIKE '%QP%';

---- Each cheque should have a unique batch ID---
SELECT *,
       COUNT(Batch_id) OVER(PARTITION BY batch_id) AS batch_count
FROM Deduction;



--- Detect Duplicate FILE_NO or EE_ID Entries

SELECT 
    EE_ID,
    FILE_NO,
    Employee_Name,
    COUNT(*) OVER (PARTITION BY FILE_NO) AS File_No_Duplicates,
    COUNT(*) OVER (PARTITION BY EE_ID) AS EE_ID_Duplicates
FROM deduction;


---- ### SQL Queries ###---


--1. Full List of All Mistaken Records (both error types)

SELECT *
FROM Deduction
WHERE 
    (Ded_Code = 'ACH' AND Batch_ID LIKE 'OFF%')    -- Error Type 1: ACH used for OFF batch
    OR 
    (Ded_Code IN ('X', '2') AND Batch_ID LIKE 'ACH%'); -- Error Type 2: X or 2 used for ACH batch


-- 2. Find Batch_Id,Deduction Code Where X or 2 Deduction Code Was Mistakenly Used for ACH Batch

SELECT Batch_ID,Ded_Code
FROM Deduction
WHERE Ded_Code = 'ACH'
  AND Batch_ID LIKE 'OFF%';


-- 3. Find Batch_Id,Deduction Code Where ACH Was Mistakenly Used for OFF Batch

SELECT Batch_ID,Ded_Code
FROM Deduction
WHERE Ded_Code IN ('X', '2')
  AND Batch_ID LIKE 'ACH%';


-- 4.  write the sql query to find out processor names who processed ACH deduction code in OFF batch ID

SELECT Processor_Id,Batch_ID,Ded_Code
FROM Deduction
WHERE Ded_Code = 'ACH'
  AND Batch_ID LIKE 'OFF%'


-- 5. Write the sql query to find out processor names who processed deduction code('X','2') in ACH batch ID

SELECT Batch_ID,Ded_Code,Processor_Id
FROM Deduction
WHERE Ded_Code IN ('X', '2')
  AND Batch_ID LIKE 'ACH%';


-- 6. Count the processor names who processed ACH deduction code in OFF batch ID

SELECT COUNT(DISTINCT Processor_Id) AS ACH_in_OFF_Processor_Count
FROM Deduction
WHERE 
  Ded_Code = 'ACH'
  AND Batch_ID LIKE 'OFF%';


--7. Count the processor names who processed (X,2) deduction code in ACH batch ID

SELECT COUNT(DISTINCT Processor_Id) AS X_2_in_ACH_Processor_Count
FROM Deduction
WHERE 
  Ded_Code IN ('X', '2')
  AND Batch_ID LIKE 'ACH%';


--8. Find name of Employee,Designation,PG and File number who is receiving highest net amount

SELECT Top 1 Employee_Name,Department,PG,FILE_NO,AMT AS Net_Amount
FROM deduction
ORDER BY AMT DESC;

--9. Find the top 3 highest Net pay earners across the whole table

SELECT * FROM deduction
WHERE AMT IN (
SELECT TOP 3 AMT FROM deduction
GROUP BY AMT
ORDER BY AMT DESC);

-- 10.  Add a derived error flag column (for audit reports)

SELECT 
    *, 
    CASE 
        WHEN Ded_Code = 'ACH' AND Batch_ID LIKE 'OFF%' THEN 'Error: Should be X or 2'
        WHEN Ded_Code IN ('X', '2') AND Batch_ID LIKE 'ACH%' THEN 'Error: Should be ACH'
        ELSE 'OK'
    END AS Processing_Error_Flag
FROM 
    Deduction;

-- 11. Suggest the Correct Code Using a CASE Statement

SELECT 
    EE_ID,
    FILE_NO,
    PG,
    STATE,
    Employee_Name,
    Department,
    Batch_ID,
    Ded_Code AS Current_Ded_Code,
    
    -- Suggested corrected Ded_Code
    CASE 
        WHEN Batch_ID LIKE 'ACH%' THEN 'X'
        WHEN Batch_ID LIKE 'OFF%' THEN 'ACH'
        ELSE Ded_Code
    END AS Suggested_Ded_Code,
    
    AMT,
    Processor_Id

FROM deduction;

























