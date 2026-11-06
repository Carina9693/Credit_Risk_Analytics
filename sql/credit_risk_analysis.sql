SELECT COUNT(*) AS Total_Loans
FROM loans;

SELECT COUNT(*) AS Total_Defaulters
FROM loans
WHERE Default = 1;

SELECT
    COUNT(*) AS Total_Loans,
    SUM(Default) AS Total_Defaulters,
    ROUND(
        100.0 * SUM(Default) / COUNT(*), 2
    ) AS Default_Rate_Percentage
FROM loans;


SELECT
    EmploymentType,
    COUNT(*) AS Total_Borrowers,
    SUM("Default") AS Total_Defaulters,
    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate
FROM loans
GROUP BY EmploymentType
ORDER BY Default_Rate DESC;


SELECT
    CASE
        WHEN CreditScore < 500 THEN 'Below 500'
        WHEN CreditScore BETWEEN 500 AND 599 THEN '500-599'
        WHEN CreditScore BETWEEN 600 AND 699 THEN '600-699'
        WHEN CreditScore BETWEEN 700 AND 799 THEN '700-799'
        ELSE '800 and above'
    END AS Credit_Score_Group,

    COUNT(*) AS Total_Borrowers,
    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY Credit_Score_Group

ORDER BY Default_Rate DESC;


SELECT
    CASE
        WHEN Income < 30000 THEN 'Low Income'
        WHEN Income BETWEEN 30000 AND 60000 THEN 'Lower-Middle Income'
        WHEN Income BETWEEN 60001 AND 90000 THEN 'Middle Income'
        WHEN Income BETWEEN 90001 AND 120000 THEN 'Upper-Middle Income'
        ELSE 'High Income'
    END AS Income_Group,

    COUNT(*) AS Total_Borrowers,
    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY Income_Group

ORDER BY Default_Rate DESC;

SELECT
    LoanPurpose,
    COUNT(*) AS Total_Loans,
    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate,

    ROUND(
        100.0 * SUM("Default") /
        (SELECT SUM("Default") FROM loans), 2
    ) AS Share_of_Total_Defaulters

FROM loans

GROUP BY LoanPurpose

ORDER BY Default_Rate DESC;


SELECT
    CASE
        WHEN CreditScore < 500
             AND Income < 30000
             AND DTIRatio > 0.5
        THEN 'High Risk'

        WHEN CreditScore < 600
             AND Income < 60000
        THEN 'Medium Risk'

        ELSE 'Lower Risk'
    END AS Risk_Category,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY Risk_Category

ORDER BY Default_Rate DESC;

WITH Risk_Summary AS (

    SELECT
        CASE
            WHEN CreditScore < 500
                 AND Income < 30000
                 AND DTIRatio > 0.5
            THEN 'High Risk'

            WHEN CreditScore < 600
                 AND Income < 60000
            THEN 'Medium Risk'

            ELSE 'Lower Risk'
        END AS Risk_Category,

        COUNT(*) AS Total_Borrowers,
        SUM("Default") AS Total_Defaulters

    FROM loans
    GROUP BY Risk_Category
),

Portfolio_Summary AS (

    SELECT
        100.0 * SUM("Default") / COUNT(*) AS Overall_Default_Rate
    FROM loans

)

SELECT
    r.Risk_Category,
    r.Total_Borrowers,
    r.Total_Defaulters,

    ROUND(
        100.0 * r.Total_Defaulters / r.Total_Borrowers, 2
    ) AS Default_Rate,

    ROUND(
        p.Overall_Default_Rate, 2
    ) AS Overall_Default_Rate

FROM Risk_Summary r
CROSS JOIN Portfolio_Summary p

WHERE
    100.0 * r.Total_Defaulters / r.Total_Borrowers
    > p.Overall_Default_Rate

ORDER BY Default_Rate DESC;

SELECT
    EmploymentType,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate,

    RANK() OVER (
        ORDER BY
        1.0 * SUM("Default") / COUNT(*) DESC
    ) AS Risk_Rank

FROM loans

GROUP BY EmploymentType;

SELECT
    EmploymentType,
    COUNT(*) AS Total_Borrowers,
    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate,

    RANK() OVER (
        ORDER BY
        1.0 * SUM("Default") / COUNT(*) DESC
    ) AS Risk_Rank

FROM loans
GROUP BY EmploymentType;

SELECT
    EmploymentType,
    LoanPurpose,
    COUNT(*) AS Total_Loans,
    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate,

    DENSE_RANK() OVER (
        PARTITION BY EmploymentType
        ORDER BY
        1.0 * SUM("Default") / COUNT(*) DESC
    ) AS Purpose_Rank

FROM loans

GROUP BY
    EmploymentType,
    LoanPurpose

ORDER BY
    EmploymentType,
    Purpose_Rank;

    SELECT
    EmploymentType,
    LoanPurpose,
    COUNT(*) AS Total_Loans,
    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate,

    DENSE_RANK() OVER (
        PARTITION BY EmploymentType
        ORDER BY
        1.0 * SUM("Default") / COUNT(*) DESC
    ) AS Purpose_Rank

FROM loans

GROUP BY
    EmploymentType,
    LoanPurpose

ORDER BY
    EmploymentType,
    Purpose_Rank;

SELECT
    CASE
        WHEN CreditScore < 500
             AND Income < 30000
             AND DTIRatio > 0.5
        THEN 'High Risk'

        WHEN CreditScore < 600
             AND Income < 60000
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS Risk_Category,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY Risk_Category

ORDER BY Default_Rate DESC;


SELECT
    EmploymentType,

    COUNT(*) AS Total_Borrowers,

    SUM(CASE
        WHEN "Default" = 1 THEN 1
        ELSE 0
    END) AS Total_Defaulters,

    SUM(CASE
        WHEN "Default" = 0 THEN 1
        ELSE 0
    END) AS Non_Defaulters,

    ROUND(
        100.0 * SUM(CASE WHEN "Default" = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY EmploymentType

ORDER BY Default_Rate DESC;

SELECT
    LoanPurpose,

    COUNT(*) AS Total_Loans,

    ROUND(AVG(LoanAmount), 2) AS Average_Loan_Amount,

    ROUND(MIN(LoanAmount), 2) AS Minimum_Loan_Amount,

    ROUND(MAX(LoanAmount), 2) AS Maximum_Loan_Amount,

    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY LoanPurpose

ORDER BY Average_Loan_Amount DESC;

SELECT
    CASE
        WHEN Age < 25 THEN 'Below 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55 and Above'
    END AS Age_Group,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(AVG(Income), 2) AS Average_Income,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY Age_Group

ORDER BY
    CASE Age_Group
        WHEN 'Below 25' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        ELSE 5
    END;

    SELECT
    CASE
        WHEN Age < 25 THEN 'Below 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55 and Above'
    END AS Age_Group,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(AVG(Income), 2) AS Average_Income,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY Age_Group

ORDER BY
    CASE Age_Group
        WHEN 'Below 25' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        ELSE 5
    END;

    SELECT
    CASE
        WHEN InterestRate < 5 THEN 'Below 5%'
        WHEN InterestRate BETWEEN 5 AND 10 THEN '5-10%'
        WHEN InterestRate BETWEEN 10 AND 15 THEN '10-15%'
        WHEN InterestRate BETWEEN 15 AND 20 THEN '15-20%'
        ELSE 'Above 20%'
    END AS Interest_Rate_Group,

    COUNT(*) AS Total_Loans,

    SUM("Default") AS Total_Defaulters,

    ROUND(AVG(LoanAmount), 2) AS Average_Loan_Amount,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY Interest_Rate_Group

ORDER BY
    CASE Interest_Rate_Group
        WHEN 'Below 5%' THEN 1
        WHEN '5-10%' THEN 2
        WHEN '10-15%' THEN 3
        WHEN '15-20%' THEN 4
        ELSE 5
    END;

   SELECT
    LoanTerm,

    COUNT(*) AS Total_Loans,

    SUM("Default") AS Total_Defaulters,

    ROUND(AVG(LoanAmount), 2) AS Average_Loan_Amount,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY LoanTerm

ORDER BY LoanTerm;


SELECT
    CASE
        WHEN DTIRatio < 0.2 THEN 'Very Low DTI'
        WHEN DTIRatio BETWEEN 0.2 AND 0.39 THEN 'Low DTI'
        WHEN DTIRatio BETWEEN 0.4 AND 0.59 THEN 'Medium DTI'
        ELSE 'High DTI'
    END AS DTI_Category,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(AVG(Income), 2) AS Average_Income,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY DTI_Category

ORDER BY
    CASE DTI_Category
        WHEN 'Very Low DTI' THEN 1
        WHEN 'Low DTI' THEN 2
        WHEN 'Medium DTI' THEN 3
        ELSE 4
    END;


    SELECT
    MaritalStatus,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(AVG(Income), 2) AS Average_Income,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY MaritalStatus

ORDER BY Default_Rate DESC;


SELECT
    MaritalStatus,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(AVG(Income), 2) AS Average_Income,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY MaritalStatus

ORDER BY Default_Rate DESC;

SELECT
    HasMortgage,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY HasMortgage

ORDER BY Default_Rate DESC;

SELECT
    HasMortgage,

    COUNT(*) AS Total_Borrowers,

    SUM("Default") AS Total_Defaulters,

    ROUND(
        100.0 * SUM("Default") / COUNT(*), 2
    ) AS Default_Rate

FROM loans

GROUP BY HasMortgage

ORDER BY Default_Rate DESC;