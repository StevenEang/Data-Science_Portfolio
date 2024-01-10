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
-- Key Observations:
-- The results display a wide range of loan amounts, from as low as $500 to as high as $35,000.
-- Certain loan amounts appear more frequently, suggesting standard loan sizes (e.g., $1000, $5000, $10000).
-- The variability in loan counts across different amounts indicates diverse borrowing needs and preferences.
-- This analysis can help in understanding borrowing trends and designing targeted credit products.

-- Funded Amount Analysis
SELECT 
    COUNT(*) AS TotalCount,
    MIN(CAST(funded_amnt AS FLOAT)) AS MinFundedAmount, 
    MAX(CAST(funded_amnt AS FLOAT)) AS MaxFundedAmount, 
    AVG(CAST(funded_amnt AS FLOAT)) AS AvgFundedAmount,
    STDEV(CAST(funded_amnt AS FLOAT)) AS StdDevFundedAmount
FROM [dbo].[Credit Risk];

TotalCount	MinFundedAmount	MaxFundedAmount	AvgFundedAmount	StdDevFundedAmount
855969	    500	            35000	        14732.3783045881	8419.47165331976

-- Interest Rate Distribution
SELECT 
    int_rate,
    COUNT(*) AS NumberOfLoans
FROM [dbo].[Credit Risk]
GROUP BY int_rate
ORDER BY int_rate;

-- Key Observations:
-- A wide range of interest rates are observed, from as low as 5.32% to as high as 28.99%.
-- Some interest rates appear much more frequently (e.g., 10.99%, 11.53%, 12.69%) indicating common rates offered by the lender.
-- The varied distribution of interest rates suggests loans are tailored to diverse credit profiles and risk assessments.
-- High-frequency rates like 10.99% and 12.69% might represent standard rates for specific loan products or credit tiers.
-- Lower and higher extremes in interest rates could reflect special loan categories or exceptional credit situations.

-- Borrow Demographics
-- Analyze basic statistics of annual income to understand income distribution among borrowers.
SELECT 
    COUNT(*) AS TotalCount,
    MIN(CAST(annual_inc AS FLOAT)) AS MinAnnualIncomeAmount, 
    MAX(CAST(annual_inc AS FLOAT)) AS MaxAnnualIncomeAmount, 
    AVG(CAST(annual_inc AS FLOAT)) AS AvgAnnualIncomeAmount,
    STDEV(CAST(annual_inc AS FLOAT)) AS StdDevAnnualIncomeAmount
FROM [dbo].[Credit Risk];

TotalCount	MinAnnualIncomeAmount	MaxAnnualIncomeAmount	AvgAnnualIncomeAmount	StdDevAnnualIncomeAmount
855969	    0	                    9500000	                75071.1859626809	    64264.4698134632

-- Home Ownership Status
SELECT 
    home_ownership,
    COUNT(*) AS TotalCount,
    AVG(CAST(annual_inc AS FLOAT)) AS AverageIncome,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM [dbo].[Credit Risk]
GROUP BY home_ownership;

home_ownership	TotalCount	AverageIncome	Defaults
RENT	342535	64007.3515424409	21922
ANY	3	63726.6666666667	0
OTHER	144	68374.1805555556	27
MORTGAGE	429106	85109.5053911854	20376
NONE	45	63552.2444444444	7
OWN	84136	68935.455492417	4135

-- Employment Length
SELECT 
    emp_length,
    COUNT(*) AS TotalCount,
    AVG(CAST(annual_inc AS FLOAT)) AS AverageIncome,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM [dbo].[Credit Risk]
GROUP BY emp_length;

emp_length	TotalCount	AverageIncome	Defaults
< 1 year	67597	70475.9182036185	3942
1 year	54855	70905.9427386747	3059
10+ years	282090	82152.6349241377	13508
2 years	75986	72577.2826042955	4119
3 years	67392	73437.968648801	3638
4 years	50643	73806.5774646052	2841
5 years	53812	74378.1250782353	3280
6 years	41446	74309.5753940067	2758
7 years	43204	74690.9651587816	2673
8 years	42421	76023.8054074633	2227
9 years	33462	75746.3612554539	1826
n/a	43061	50162.3325370985	2596

-- Loan Characteristics
-- Loan Purpose
SELECT 
    purpose,
    COUNT(*) AS NumberOfLoans,
    AVG(loan_amnt) AS AverageLoanAmount,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM Loans
GROUP BY purpose;

purpose	            NumberOfLoans	AverageLoanAmount	Defaults
renewable_energy	549	            9925.136612        	54
credit_card	        200144	        15327.447113	    8059
debt_consolidation	505392	        15414.932765	    28389
house	            3513	        14895.032735	    293
medical	            8193	        9012.159770    	584
car	                8593	        8849.394856	    458
wedding	            2280	        10528.750000	265
other	            40949	        9888.036337	    3001
major_purchase    	16587	        11552.602942	888
vacation	        4542	        6228.164905	    278
moving	            5160	        7850.397286    	436
small_business	    9785	        15404.803270	1390
home_improvement	49956	        14283.275282	2316
educational	        326	            6796.319018	    56

-- Grade and Subgrade
SELECT 
    grade,
    sub_grade,
    COUNT(*) AS NumberOfLoans,
    AVG(CAST(REPLACE(int_rate, '%', '') AS FLOAT)) AS AverageInterestRate,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults
FROM [dbo].[Credit Risk]
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- Key Observations:
-- 1. As sub-grade worsens from A1 to G5, average interest rate increases, indicating higher risk.
-- 2. Loan defaults increase with worsening sub-grade, suggesting a correlation between sub-grade and default risk.
-- 3. Distribution of loans is uneven across grades, with more loans in lower-risk grades (A, B).
-- 4. Highest risk categories (G grades) have high interest rates and a significant number of defaults, despite fewer loans.
-- 5. Peak defaults are in middle grades (C1 to D5), not in the highest risk categories.
-- 6. Anomaly in Grade A: A5 has a higher default rate than B1, despite lower interest rate.
-- 7. The trend in interest rates and defaults from A to G grades implies accuracy in risk assessment.

-- Average loan amount by grade
SELECT grade, AVG(loan_amnt) AS AvgLoanAmount
FROM [dbo].[Credit Risk]
GROUP BY grade
ORDER BY grade;

grade	AvgLoanAmount
A	    14035.090962
B	    13647.737884
C	    14470.968208
D	    15467.901838
E	    18058.759104
F	    19193.104135
G	    20872.214241

-- Default Analysis
-- Correlation with DTI(Debt-to-Income)
SELECT 
    CAST(dti AS FLOAT) AS DTI,
    COUNT(*) AS TotalLoans,
    AVG(CAST(default_ind AS FLOAT)) AS DefaultRate
FROM [dbo].[Credit Risk]
GROUP BY dti
ORDER BY DTI;

-- Key Observations:
-- 1. No consistent correlation between DTI and default rate. 
-- 2. Default rate varies significantly across different DTI levels.
-- 3. The lack of clear and consistent trend suggests that while DIT is an important factor, the default rate is likely influenced by multiple variables and factors.

-- Correlation with Loan Amount
SELECT 
    loan_amnt,
    COUNT(*) AS TotalLoans,
    AVG(CASE WHEN default_ind = 1 THEN 1.0 ELSE 0 END) AS DefaultRate
FROM [dbo].[Credit Risk]
GROUP BY loan_amnt
ORDER BY loan_amnt;

-- Key Observations:
-- Certain loan amounts, such as $10,000, $15,000, $20,000, and $35,000, show a notably high frequency suggesting these amounts are common choices among borrowers.
-- There's no clear trend in default rates as loan amounts increase, there are pockets where default rates peak. This indicates that default risk doesn't necessarily increase with loan amount linearly.

-- Correlation Between Loan Amount and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN loan_amnt ELSE NULL END) AS AvgDefaultLoanAmount,
       AVG(CASE WHEN default_ind = 0 THEN loan_amnt ELSE NULL END) AS AvgNonDefaultLoanAmount
FROM [dbo].[Credit Risk];

AvgDefaultLoanAmount	AvgNonDefaultLoanAmount
14573.018486	        14755.476206

-- Correlation Between Interest Rate and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN int_rate ELSE NULL END) AS AvgDefaultInterestRate,
       AVG(CASE WHEN default_ind = 0 THEN int_rate ELSE NULL END) AS AvgNonDefaultInterestRate
FROM Loans;

AvgDefaultInterestRate	AvgNonDefaultInterestRate
16.0190922590224	    13.0300573191907

-- Correlation Between Employment Length and Default Risk
SELECT 
    emp_length, 
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END AS FLOAT)) AS DefaultRate
FROM [dbo].[Credit Risk]
GROUP BY emp_length
ORDER BY emp_length;

emp_length	DefaultRate
< 1 year	0.0583161974643845
1 year	    0.0557651991614256
10+ years	0.0478854266368889
2 years	    0.0542073539862606
3 years    	0.0539826685660019
4 years	    0.0560985723594574
5 years	    0.0609529472980004
6 years	    0.0665444192443179
7 years	    0.0618692713637626
8 years	    0.0524975837439004
9 years	    0.05456936226167
n/a	        0.0602865702143471

-- Correlation Between Home Ownership and Default Risk
SELECT 
    home_ownership, 
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END AS FLOAT)) AS DefaultRate
FROM [dbo].[Credit Risk]
GROUP BY home_ownership;

home_ownership	DefaultRate
RENT	        0.0639992993416731
ANY    	        0
OTHER	        0.1875
NONE	        0.155555555555556
MORTGAGE	    0.0474847706627267
OWN	            0.0491466197584863

-- Correlation Between Annual Income and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN CAST(annual_inc AS FLOAT) ELSE NULL END) AS AvgDefaultAnnualInc,
       AVG(CASE WHEN default_ind = 0 THEN CAST(annual_inc AS FLOAT) ELSE NULL END) AS AvgNonDefaultAnnualInc
FROM [dbo].[Credit Risk];

AvgDefaultAnnualInc	AvgNonDefaultAnnualInc
65128.9165536833	75641.8916961169

-- Correlation Between Debt-to-Income Ratio (DTI) and Default Risk
SELECT AVG(CASE WHEN default_ind = 1 THEN CAST(dti AS FLOAT) ELSE NULL END) AS AvgDefaultDTI,
       AVG(CASE WHEN default_ind = 0 THEN CAST(dti AS FLOAT) ELSE NULL END) AS AvgNonDefaultDTI
FROM [dbo].[Credit Risk];

AvgDefaultDTI	    AvgNonDefaultDTI
18.4442344029096	18.1036773967205

-- Correlation Between Credit History Length and Default Risk
WITH CreditHistory AS (
    SELECT 
        DATEDIFF(month, CONVERT(DATE, earliest_cr_line, 103), '2011-12-01') AS CreditHistoryLengthMonths,
        default_ind
    FROM [dbo].[Credit Risk]
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
FROM [dbo].[Credit Risk]
GROUP BY grade;

grade	AvgDefaultLoanAmount	AvgNonDefaultLoanAmount
D	    14587.370346	        15545.833538
G	    21190.663390	        20808.351810
A	    11927.486861	        14074.354025
C	    13521.862021	        14526.094914
E	    17733.464932	        18093.783443
F	    19417.125788	        19156.250341
B	    12531.697025	        13693.249566

-- Debt-to-Income Ratio (DTI) vs. Default Risk
SELECT 
    DTI_bin,
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1.0 ELSE 0.0 END AS FLOAT)) * 100.0 AS DefaultRate
FROM (
    SELECT 
        CAST(dti AS FLOAT) AS dti_numeric,
        default_ind,
        CASE 
            WHEN CAST(dti AS FLOAT) <= 10 THEN '0-10'
            WHEN CAST(dti AS FLOAT) > 10 AND CAST(dti AS FLOAT) <= 20 THEN '11-20'
            WHEN CAST(dti AS FLOAT) > 20 AND CAST(dti AS FLOAT) <= 30 THEN '21-30'
            ELSE '30+' 
        END AS DTI_bin,
        CASE 
            WHEN CAST(dti AS FLOAT) <= 10 THEN 1
            WHEN CAST(dti AS FLOAT) > 10 AND CAST(dti AS FLOAT) <= 20 THEN 2
            WHEN CAST(dti AS FLOAT) > 20 AND CAST(dti AS FLOAT) <= 30 THEN 3
            ELSE 4 
        END AS SortOrder 
    FROM [dbo].[Credit Risk]
) AS DTI_Categories
GROUP BY DTI_bin, SortOrder 
ORDER BY SortOrder;

DTI_bin	DefaultRate
0-10	4.78766143414271
11-20	5.31962917290584
21-30	6.15723071409235
30+	    4.73776110715902

-- Home Ownership, Employment Length vs. Default Risk
SELECT 
    home_ownership,
    emp_length,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM [dbo].[Credit Risk]
GROUP BY home_ownership, emp_length;

home_ownership	emp_length	TotalLoans	Defaults	DefaultRate
RENT	        2 years	    39054	    2341	    5.994264351922
MORTGAGE	    4 years	    22598	    1042	    4.611027524559
RENT	        6 years	17014	1313	7.717174091924
OWN	            4 years	4563	239	5.237782160859
NONE	        6 years	4	1	25.000000000000
NONE	        9 years	4	0	0.000000000000
MORTGAGE	    5 years	25283	1341	5.303959182059
OWN	            n/a	8239	422	5.121980822915
MORTGAGE	    2 years	30375	1438	4.734156378600
RENT	        1 year	29565	1784	6.034162015897
MORTGAGE	    1 year	20524	1010	4.921068017930
OWN            	2 years	6539	337	5.153693225263
RENT	        < 1 year	38060	2404	6.316342616920
MORTGAGE	    7 years	22295	1207	5.413769903565
OWN            	7 years	3892	235	6.038026721479
RENT	        8 years	15859	956	6.028122832461
OTHER	        2 years	14	2	14.285714285714
OTHER	        1 year	17	4	23.529411764705
NONE	        7 years	2	0	0.000000000000
NONE	        10+ years	18	2	11.111111111111
ANY	            10+ years	1	0	0.000000000000
NONE	        3 years	2	1	50.000000000000
RENT	        4 years	23471	1560	6.646499936091
MORTGAGE	    6 years	20738	1207	5.820233387983
OWN	            3 years	5998	320	5.335111703901
MORTGAGE	    3 years	28772	1345	4.674683720283
OWN	            5 years	4963	273	5.500705218617
NONE	        2 years	4	1	25.000000000000
OTHER	        8 years	4	0	0.000000000000
RENT	        3 years	32607	1967	6.032447020578
RENT	        9 years	12345	787	6.375050627784
NONE	        5 years	2	0	0.000000000000
NONE	        < 1 year	4	1	25.000000000000
NONE	        1 year	2	0	0.000000000000
NONE	        8 years	1	0	0.000000000000
RENT	        10+ years	79159	4791	6.052375598479
MORTGAGE	    n/a	19981	1048	5.244982733596
OWN	            6 years	3682	235	6.382400869092
RENT	        7 years	17010	1230	7.231040564373
OTHER	        n/a	3	0	0.000000000000
ANY	            5 years	1	0	0.000000000000
MORTGAGE	    < 1 year	23822	1214	5.096129628074
OWN	            < 1 year	5688	320	5.625879043600
RENT	        n/a	14837	1125	7.582395362943
OTHER	        6 years	8	2	25.000000000000
NONE	        n/a	1	1	100.000000000000
MORTGAGE	    8 years	22729	1094	4.813234194201
MORTGAGE	    10+ years	173909	7543	4.337325842825
OTHER	        5 years	9	2	22.222222222222
OTHER	        9 years	3	0	0.000000000000
RENT	        5 years	23554	1664	7.064617474738
MORTGAGE	    9 years	18080	887	4.905973451327
OWN	            1 year	4747	261	5.498209395407
OWN	            9 years	3030	152	5.016501650165
OTHER	        10+ years	36	8	22.222222222222
OTHER        	3 years	13	5	38.461538461538
NONE	        4 years	1	0	0.000000000000
OTHER	        < 1 year	23	3	13.043478260869
ANY	            7 years	1	0	0.000000000000
OTHER        	7 years	4	1	25.000000000000
OWN	            8 years	3828	177	4.623824451410
OWN	            10+ years	28967	1164	4.018365726516
OTHER	        4 years	10	0	0.000000000000

-- Loan Purpose vs. Default Risk
SELECT 
    purpose,
    COUNT(*) AS TotalCount,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS DefaultCount,
    AVG(CAST(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END AS FLOAT)) AS DefaultRate
FROM [dbo].[Credit Risk]
GROUP BY purpose;

purpose	TotalCount	DefaultCount	DefaultRate
home_improvement	49956	2316	0.0463607975018016
educational	326	56	0.171779141104294
small_business	9785	1390	0.142054164537557
renewable_energy	549	54	0.0983606557377049
other	40949	3001	0.0732862829373123
major_purchase	16587	888	0.0535359016096943
vacation	4542	278	0.0612065169528842
car	8593	458	0.0532991970208309
moving	5160	436	0.0844961240310078
credit_card	200144	8059	0.0402660084738988
debt_consolidation	505392	28389	0.0561722385791623
medical	8193	584	0.0712803612840229
house	3513	293	0.0834044975804156
wedding	2280	265	0.116228070175439

-- Binning Interest Rates
SELECT 
    InterestRateBin,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM (
    SELECT 
        default_ind,
        CASE 
            WHEN CAST(int_rate AS FLOAT) <= 5 THEN '0-5%'
            WHEN CAST(int_rate AS FLOAT) > 5 AND CAST(int_rate AS FLOAT) <= 10 THEN '5.01-10%'
            WHEN CAST(int_rate AS FLOAT) > 10 AND CAST(int_rate AS FLOAT) <= 15 THEN '10.01-15%'
            ELSE 'Above 15%' 
        END AS InterestRateBin
    FROM [dbo].[Credit Risk]
) AS InterestRateCategories
GROUP BY InterestRateBin;

InterestRateBin	TotalLoans	Defaults	DefaultRate
5.01-10%	    230582	    3732	    1.618513153672
10.01-15%	    359382	    16239	    4.518590246589
Above 15%	    266005	    26496    	9.960715024153

-- Default Rate Over Time:
SELECT 
    YEAR(issue_d) AS Year, 
    MONTH(issue_d) AS Month,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) AS Defaults,
    SUM(CASE WHEN default_ind = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DefaultRate
FROM [dbo].[Credit Risk]
GROUP BY YEAR(issue_d), MONTH(issue_d)
ORDER BY Year, Month;

Year	Month	TotalLoans	Defaults	DefaultRate
2007	1	251	45	17.928286852589
2008	1	1562	247	15.813060179257
2009	1	4716	594	12.595419847328
2010	1	11529	1484	12.871888281724
2011	1	21636	3213	14.850249584026
2012	1	53035	8112	15.295559536155
2013	1	131678	15018	11.405094245052
2014	1	227865	14594	6.404669431461
2015	1	403697	3160	0.782765291790

-- Correlation Coefficient Between Loan Amount and Annual Income
SELECT 
    (SUM(CAST(loan_amnt AS FLOAT) * CAST(annual_inc AS FLOAT)) - SUM(CAST(loan_amnt AS FLOAT)) * SUM(CAST(annual_inc AS FLOAT)) / CAST(COUNT(*) AS FLOAT)) / 
    (SQRT(SUM(CAST(loan_amnt AS FLOAT) * CAST(loan_amnt AS FLOAT)) - SUM(CAST(loan_amnt AS FLOAT)) * SUM(CAST(loan_amnt AS FLOAT)) / CAST(COUNT(*) AS FLOAT)) * 
     SQRT(SUM(CAST(annual_inc AS FLOAT) * CAST(annual_inc AS FLOAT)) - SUM(CAST(annual_inc AS FLOAT)) * SUM(CAST(annual_inc AS FLOAT)) / CAST(COUNT(*) AS FLOAT))) 
     AS correlation_coefficient
FROM [dbo].[Credit Risk];

correlation_coefficient
0.33520914696822

-- Calculation of Loan to Income Ratios in Credit Risk Data
SELECT 
  CAST(loan_amnt AS DECIMAL(10, 2)) AS loan_amnt, 
  CAST(annual_inc AS DECIMAL(10, 2)) AS annual_inc, 
  (CAST(loan_amnt AS DECIMAL(10, 2)) / CAST(annual_inc AS DECIMAL(10, 2))) AS loan_to_income_ratio
FROM [dbo].[Credit Risk]
WHERE CAST(annual_inc AS DECIMAL(10, 2)) > 0;

-- Categorizing loans by risk levels based on loan amount criteria, interest rates, and DTI
SELECT 
  RiskLevel,
  COUNT(*) AS NumberOfLoans,
  AVG(CAST(default_ind AS FLOAT)) AS DefaultRate -- Convert to FLOAT for AVG calculation
FROM (
  SELECT 
    id,
    default_ind,
    CASE 
      WHEN CAST(int_rate AS FLOAT) < 10 THEN 'Low Risk' -- Ensure int_rate is numeric
      WHEN CAST(int_rate AS FLOAT) BETWEEN 10 AND 15 THEN 'Moderate Risk'
      ELSE 'High Risk' 
    END AS RiskLevel
  FROM [dbo].[Credit Risk]
) AS SubQuery
GROUP BY RiskLevel;

RiskLevel	    NumberOfLoans	DefaultRate
High Risk	    266005	        0.0996071502415368
Low Risk	    230332        	0.0160681103797996
Moderate Risk	359632	        0.0452406904836055


