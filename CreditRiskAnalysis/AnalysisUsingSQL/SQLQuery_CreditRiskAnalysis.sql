CREATE DATABASE CreditRiskAnalysis;

USE CreditRiskAnalysis;

CREATE TABLE Loans (
    id INT,
    member_id INT,
    loan_amnt INT,
    funded_amnt INT,
    funded_amnt_inv FLOAT,
    term NVARCHAR(100),
    int_rate FLOAT,
    installment FLOAT,
    grade NVARCHAR(10),
    sub_grade NVARCHAR(10),
    emp_length NVARCHAR(50),
    home_ownership NVARCHAR(50),
    annual_inc FLOAT,
    verification_status NVARCHAR(100),
    issue_d DATE,
    pymnt_plan NVARCHAR(10),
    purpose NVARCHAR(255),
    title NVARCHAR(255),
    zip_code NVARCHAR(20),
    addr_state NVARCHAR(10),
    dti FLOAT,
    delinq_2yrs INT,
    earliest_cr_line DATE,
    inq_last_6mths INT,
    mths_since_last_delinq FLOAT,
    mths_since_last_record FLOAT,
    open_acc INT,
    pub_rec INT,
    revol_bal INT,
    revol_util FLOAT,
    total_acc INT,
    initial_list_status NVARCHAR(10),
    out_prncp FLOAT,
    out_prncp_inv FLOAT,
    total_pymnt FLOAT,
    total_pymnt_inv FLOAT,
    total_rec_prncp FLOAT,
    total_rec_int FLOAT,
    total_rec_late_fee FLOAT,
    recoveries FLOAT,
    collection_recovery_fee FLOAT,
    last_pymnt_d DATE,
    last_pymnt_amnt FLOAT,
    next_pymnt_d DATE,
    last_credit_pull_d DATE,
    collections_12_mths_ex_med FLOAT,
    mths_since_last_major_derog FLOAT,
    policy_code INT,
    application_type NVARCHAR(100),
    annual_inc_joint FLOAT,
    dti_joint FLOAT,
    verification_status_joint NVARCHAR(100),
    acc_now_delinq INT,
    tot_coll_amt FLOAT,
    tot_cur_bal FLOAT,
    open_acc_6m FLOAT,
    open_il_6m FLOAT,
    open_il_12m FLOAT,
    open_il_24m FLOAT,
    mths_since_rcnt_il FLOAT,
    total_bal_il FLOAT,
    il_util FLOAT,
    open_rv_12m FLOAT,
    open_rv_24m FLOAT,
    max_bal_bc FLOAT,
    all_util FLOAT,
    total_rev_hi_lim FLOAT,
    inq_fi FLOAT,
    total_cu_tl FLOAT,
    inq_last_12m FLOAT,
    default_ind INT
);

ALTER TABLE [dbo].[Credit Risk]
ALTER COLUMN loan_amnt DECIMAL(18,2);

-- DATA CLEANING
-- Set missing values (NULL) to a default value in a column
UPDATE Loans
SET emp_length = '0 years'
WHERE emp_length IS NULL;

-- Removing rows where 'mths_since_last_delinq' is NULL (consider the impact)
DELETE FROM Loans
WHERE mths_since_last_delinq IS NULL;

-- Remove rows with missing values in a certain column
DELETE FROM Loans
WHERE emp_length IS NULL;

-- Delete duplicate rows based on a unique column (e.g., id)
DELETE FROM Loans
WHERE id NOT IN (
    SELECT MIN(id)
    FROM Loans
    GROUP BY id
);

-- Standardize text to uppercase for state abbreviations
UPDATE Loans
SET addr_state = UPPER(addr_state);

-- Data Exploration
-- Basic Overview for Numeric Columns
-- Top 10 data for all columns
SELECT COUNT(*) FROM [dbo].[Credit Risk];

SELECT TOP 10 * FROM [dbo].[Credit Risk];

-- Loan Amount Analysis
SELECT 
    COUNT(*) AS TotalLoans, -- The total number of loans in the dataset.
    MIN(loan_amnt) AS MinLoanAmount, -- The smallest loan amount granted.
    MAX(loan_amnt) AS MaxLoanAmount, -- The largest loan amount granted.
    AVG(loan_amnt) AS AvgLoanAmount, -- The average loan amount across all loans.
    STDEV(loan_amnt) AS StdDevLoanAmount -- The standard deviation of loan amounts, indicating variability.
FROM [dbo].[Credit Risk];

TotalLoans	MinLoanAmount	MaxLoanAmount	AvgLoanAmount	StdDevLoanAmount
855969	500.00	35000.00	14745.571334	8425.3400050053

-- Loan Amount Distribution Analysis
-- This query is designed to understand the frequency of each loan amount, providing a granular view of our loan distribution.
SELECT 
    loan_amnt,
    COUNT(*) AS NumberOfLoans
FROM [dbo].[Credit Risk]
GROUP BY loan_amnt
ORDER BY loan_amnt;

-- Funded Amount Analysis
SELECT 
    COUNT(*) AS TotalCount,
    MIN(CAST(funded_amnt AS FLOAT)) AS MinFundedAmount, 
    MAX(CAST(funded_amnt AS FLOAT)) AS MaxFundedAmount, 
    AVG(CAST(funded_amnt AS FLOAT)) AS AvgFundedAmount,
    STDEV(CAST(funded_amnt AS FLOAT)) AS StdDevFundedAmount
FROM [dbo].[Credit Risk];

-- Interest Rate Distribution
SELECT 
    int_rate,
    COUNT(*) AS NumberOfLoans
FROM [dbo].[Credit Risk]
GROUP BY int_rate
ORDER BY int_rate;

-- Borrow Demographics
-- Analyze basic statistics of annual income to understand income distribution among borrowers.
SELECT 
    COUNT(*) AS TotalCount,
    MIN(CAST(annual_inc AS FLOAT)) AS MinAnnualIncomeAmount, 
    MAX(CAST(annual_inc AS FLOAT)) AS MaxAnnualIncomeAmount, 
    AVG(CAST(annual_inc AS FLOAT)) AS AvgAnnualIncomeAmount,
    STDEV(CAST(annual_inc AS FLOAT)) AS StdDevAnnualIncomeAmount
FROM [dbo].[Credit Risk];

-- Home Ownership Status
SELECT 
    home_ownership,
    COUNT(*) AS TotalCount,
    AVG(CAST(annual_inc AS FLOAT)) AS AverageIncome,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM [dbo].[Credit Risk]
GROUP BY home_ownership;

-- Employment Length
SELECT 
    emp_length,
    COUNT(*) AS TotalCount,
    AVG(CAST(annual_inc AS FLOAT)) AS AverageIncome,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM [dbo].[Credit Risk]
GROUP BY emp_length;

-- Loan Characteristics
-- Loan Purpose
SELECT 
    purpose,
    COUNT(*) AS NumberOfLoans,
    AVG(loan_amnt) AS AverageLoanAmount,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM Loans
GROUP BY purpose;

-- Grade and Subgrade
SELECT 
    grade,
    sub_grade,
    COUNT(*) AS NumberOfLoans,
    AVG(int_rate) AS AverageInterestRate,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM Loans
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- Average loan amount by grade
SELECT grade, AVG(loan_amnt) AS AvgLoanAmount
FROM Loans
GROUP BY grade
ORDER BY grade;

-- Default Analysis
-- Correlation with DTI(Debt-to-Income)
SELECT 
    dti,
    COUNT(*) AS TotalLoans,
    AVG(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM Loans
GROUP BY dti
ORDER BY dti;

-- Correlation with Loan Amount
SELECT 
    loan_amnt,
    COUNT(*) AS TotalLoans,
    AVG(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM Loans
GROUP BY loan_amnt
ORDER BY loan_amnt;

-- Correlation Between Loan Amount and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN loan_amnt ELSE NULL END) AS AvgDefaultLoanAmount,
       AVG(CASE WHEN default_ind = 0 THEN loan_amnt ELSE NULL END) AS AvgNonDefaultLoanAmount
FROM Loans;

-- Correlation Between Interest Rate and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN int_rate ELSE NULL END) AS AvgDefaultInterestRate,
       AVG(CASE WHEN default_ind = 0 THEN int_rate ELSE NULL END) AS AvgNonDefaultInterestRate
FROM Loans;

-- Correlation Between Employment Length and Default Risk
SELECT 
    emp_length, 
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END AS FLOAT)) AS DefaultRate
FROM Loans
GROUP BY emp_length
ORDER BY emp_length;

-- Correlation Between Home Ownership and Default Risk
SELECT 
    home_ownership, 
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END AS FLOAT)) AS DefaultRate
FROM Loans
GROUP BY home_ownership;

-- Correlation Between Annual Income and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN annual_inc ELSE NULL END) AS AvgDefaultAnnualInc,
       AVG(CASE WHEN default_ind = 0 THEN annual_inc ELSE NULL END) AS AvgNonDefaultAnnualInc
FROM Loans;

-- Correlation Between Debt-to-Income Ratio (DTI) and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN dti ELSE NULL END) AS AvgDefaultDTI,
       AVG(CASE WHEN default_ind = 0 THEN dti ELSE NULL END) AS AvgNonDefaultDTI
FROM Loans;

-- Correlation Between Credit History Length and Default Risk
WITH CreditHistory AS (
    SELECT 
        DATEDIFF(month, CONVERT(DATE, earliest_cr_line, 103), '2011-12-01') AS CreditHistoryLengthMonths,
        default_ind
    FROM Loans
)
SELECT 
    CreditHistoryLengthMonths,
    AVG(CAST(default_ind AS FLOAT)) AS DefaultRate
FROM CreditHistory
GROUP BY CreditHistoryLengthMonths
ORDER BY CreditHistoryLengthMonths;

-- Average loan amount by grade for defaulted vs. non-defaulted loans
SELECT 
    grade,
    AVG(CASE WHEN default_ind = 1 THEN loan_amnt ELSE NULL END) AS AvgDefaultLoanAmount,
    AVG(CASE WHEN default_ind = 0 THEN loan_amnt ELSE NULL END) AS AvgNonDefaultLoanAmount
FROM Loans
GROUP BY grade;

-- Debt-to-Income Ratio (DTI) vs. Default Risk
SELECT 
    DTI_bin,
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1.0 ELSE 0.0 END AS FLOAT)) * 100.0 AS DefaultRate
FROM (
    SELECT 
        dti,
        default_ind,
        CASE 
            WHEN dti <= 10 THEN '0-10'
            WHEN dti > 10 AND dti <= 20 THEN '11-20'
            WHEN dti > 20 AND dti <= 30 THEN '21-30'
            ELSE '30+' 
        END AS DTI_bin,
        CASE 
            WHEN dti <= 10 THEN 1
            WHEN dti > 10 AND dti <= 20 THEN 2
            WHEN dti > 20 AND dti <= 30 THEN 3
            ELSE 4 
        END AS SortOrder 
    FROM Loans
) AS DTI_Categories
GROUP BY DTI_bin, SortOrder 
ORDER BY SortOrder;

-- Home Ownership, Employment Length vs. Default Risk
SELECT 
    home_ownership,
    emp_length,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM Loans
GROUP BY home_ownership, emp_length;

-- Loan Purpose vs. Default Risk
SELECT 
    purpose,
    COUNT(*) AS TotalCount,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS DefaultCount,
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END AS FLOAT)) AS DefaultRate
FROM Loans
GROUP BY purpose
ORDER BY DefaultRate DESC;

-- Binning Interest Rates
SELECT 
    InterestRateBin,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM (
    SELECT 
        int_rate,
        default_ind,
        CASE 
            WHEN int_rate <= 5 THEN '0-5%'
            WHEN int_rate > 5 AND int_rate <= 10 THEN '5.01-10%'
            WHEN int_rate > 10 AND int_rate <= 15 THEN '10.01-15%'
            ELSE 'Above 15%' 
        END AS InterestRateBin
    FROM Loans
) AS InterestRateCategories
GROUP BY InterestRateBin;

-- Default Rate Over Time:
SELECT 
    YEAR(issue_d) AS Year, 
    MONTH(issue_d) AS Month,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM Loans
GROUP BY YEAR(issue_d), MONTH(issue_d)
ORDER BY Year, Month;

-- Interaction Between Loan Amount and Annual Income
-- Correlation
SELECT 
    (SUM(CAST(loan_amnt AS BIGINT) * CAST(annual_inc AS BIGINT)) - SUM(CAST(loan_amnt AS BIGINT)) * SUM(CAST(annual_inc AS BIGINT)) / CAST(COUNT(*) AS BIGINT)) / 
    (SQRT(SUM(CAST(loan_amnt AS BIGINT) * CAST(loan_amnt AS BIGINT)) - SUM(CAST(loan_amnt AS BIGINT)) * SUM(CAST(loan_amnt AS BIGINT)) / CAST(COUNT(*) AS BIGINT)) * 
     SQRT(SUM(CAST(annual_inc AS BIGINT) * CAST(annual_inc AS BIGINT)) - SUM(CAST(annual_inc AS BIGINT)) * SUM(CAST(annual_inc AS BIGINT)) / CAST(COUNT(*) AS BIGINT))) 
     AS correlation_coefficient
FROM Loans;

-- Ratio
SELECT 
  loan_amnt, 
  annual_inc, 
  (loan_amnt / annual_inc) AS loan_to_income_ratio
FROM Loans
WHERE annual_inc > 0;  -- Ensure you don't divide by zero

-- Categorizing loans by risk levels based on loan amount criteria, interest rates, and DTI
SELECT 
  RiskLevel,
  COUNT(*) AS NumberOfLoans,
  AVG(default_ind) AS DefaultRate
FROM (
  SELECT 
    id,
    default_ind,
    CASE 
      WHEN int_rate < 10 THEN 'Low Risk'
      WHEN int_rate BETWEEN 10 AND 15 THEN 'Moderate Risk'
      ELSE 'High Risk' 
    END AS RiskLevel
  FROM Loans
) AS SubQuery
GROUP BY RiskLevel;

