--- DATA Cleaning

-- Removed missing values in person_emp_length and loan_int_rate columns
DELETE
FROM credit_risk
WHERE person_emp_length IS NULL 
OR loan_int_rate IS NULL;

-- Remove person age over 65 years
DELETE 
FROM credit_risk
WHERE person_age > 65

-- Delete data on customers who have worked for too long compared to the average retirement age of 65 years
DELETE
FROM credit_risk
WHERE person_emp_length > 47

--- Exploratory Data Analytics

-- What is the performance distribution of the loan portfolio, in terms of repayment and default?
SELECT 
	CASE 
	    WHEN loan_status = '1' THEN 'default'
	    WHEN loan_status = '0' THEN 'non-default'
	END AS customer_history,
	COUNT(*) AS total_loans,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS presentase
FROM credit_risk
GROUP BY customer_history
ORDER BY total_loans;

-- Which age group is most likely to default on their loans?
SELECT 
    CASE 
        WHEN person_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN person_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN person_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN person_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN person_age BETWEEN 56 AND 65 THEN '56-65' 
    END AS age_group,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS default_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / 
	COUNT(loan_status), 2) AS default_rate
FROM credit_risk
GROUP BY age_group
ORDER BY age_group;

-- In which income group is the probability of loan default the greatest ?
SELECT 
    CASE
        WHEN person_income < 20000 THEN 'Low Income'
        WHEN person_income BETWEEN 20000 AND 50000 THEN 'Middle Income'
        WHEN person_income > 50000 THEN 'High Income'
    END AS income_group,
    COUNT(*) AS customer_history,
    SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) AS total_default,
    ROUND(SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) * 100.0 /
	COUNT(*), 2) AS persentase_default
FROM credit_risk
GROUP BY income_group
ORDER BY persentase_default DESC;

-- How does homeownership status impact the likelihood of loan default?
WITH CTE AS (
    SELECT 
        person_home_ownership,
        COUNT(*) AS customer_history,
        SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) AS total_default
    FROM credit_risk
    GROUP BY person_home_ownership
)
SELECT 
	person_home_ownership,
    ROUND(total_default * 100.0 / customer_history, 2) AS default_rate
FROM CTE
ORDER BY default_rate DESC;

-- What is the percentage of loan defaults for each loan category ?
SELECT 
    loan_intent,
    COUNT(*) AS customer_history,
    SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) AS total_default,
    ROUND(SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) * 100.0 / 
	COUNT(*), 2) AS persentase_default
FROM credit_risk
GROUP BY loan_intent
ORDER BY persentase_default DESC;

-- What is the correlation between interest rates and the probability of loan defaults?
SELECT 
    CASE 
       WHEN loan_int_rate < 10 THEN 'Low Interest (5.42% -10.00%)'
       WHEN loan_int_rate BETWEEN 10 AND 15 THEN 'Medium Interest (10.00% - 15.00%)'
       WHEN loan_int_rate > 15 THEN 'High Interest (15.00% -23.22%)'
    END AS interest_rate_group,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) AS total_default,
    ROUND(SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) * 100.0 /
	COUNT(*), 2) AS persentase_default
FROM credit_risk
WHERE loan_int_rate BETWEEN 5.42 AND 23.22
GROUP BY interest_rate_group
ORDER BY persentase_default DESC;

-- Does length of employment affect the borrower's ability to repay the loan?
SELECT 
    CASE 
        WHEN person_emp_length <= 5 THEN '0-5 Years'
        WHEN person_emp_length BETWEEN 6 AND 10 THEN '6-10 Years'
        ELSE '>10 Years'
    END AS employment_length_group,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN loan_status = '1' THEN 1 ELSE 0 END) * 100.0 / 
	COUNT(*), 2) AS default_rate
FROM credit_risk
GROUP BY employment_length_group
ORDER BY default_rate DESC;

-- How likely is a customer with a history of default to default again?
SELECT 
	CASE 
	    WHEN cb_person_default_on_file = 'Y' THEN 'default'
	    WHEN cb_person_default_on_file = 'N' THEN 'non-default'
	END AS customer_history,
	COUNT(*) AS total_loans,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS presentase
FROM credit_risk
GROUP BY customer_history
ORDER BY total_loans DESC;



