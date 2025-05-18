USE `adashi_staging`;
/*
Q3: Find all active accounts (savings or investments) with no inflow transactions 
in the last 1 year (365 days).
============================================================================================== */
  -- Need toLet identify all active plans and their type (Investment and Savings)
  
WITH AllActivePlans AS (
SELECT
  p.id AS plan_id,
  p.owner_id,
CASE
   WHEN p.is_regular_savings = 1 THEN 'Savings'
   WHEN p.is_a_fund = 1 THEN 'Investment'
   ELSE 'Unknown'
END AS type
FROM
    plans_plan p
    WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1 
    
   
),
--  need to find the lastest inflow transaction date for each plan
LastestInflowTransaction AS (
SELECT
  plan_id,
  MAX(created_on) AS lastest_transaction_date 
FROM
  savings_savingsaccount
GROUP BY
	plan_id
)
-- Then join active plans with their lastest transaction date and filter for inactivity
SELECT
  aap.plan_id,
  aap.owner_id,
  aap.type,
  lt.lastest_transaction_date,
  DATEDIFF(CURRENT_DATE, DATE(lt.lastest_transaction_date)) as inactive_days  
FROM
  AllActivePlans aap
LEFT JOIN 
  LastestInflowTransaction lt ON aap.plan_id = lt.plan_id
WHERE
    lit.lastest_transaction_date IS NULL OR
    lit.lastest_transaction_date < DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY)
ORDER BY
    inactive_days DESC, aap.plan_id;
    
    
 /* -- LEFT JOINs AllActivePlans with LastInflowTransaction. Why because some customers
  might have never had any transactions, in which case lastest_transaction_date would be NULL.
 -- last_transaction_date IS NULL (meaning no inflow transactions ever for this plan), OR
-- last_transaction_date is older than 365 days from the current date.
    */