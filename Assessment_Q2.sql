USE `adashi_staging`;
/*
-- Q2: Calculate the average number of transactions per customer per month and categorize them.
===================================================================================================== */
	-- Need to count transactions per customer for each month
WITH MonthlyTransactionsPerCustomer AS (
SELECT
  sa.owner_id,
  EXTRACT(MONTH FROM sa.created_on) AS transaction_month,
  COUNT(sa.id) AS TransactionsCount 
FROM
   savings_savingsaccount sa
GROUP BY
    sa.owner_id,
    EXTRACT(MONTH FROM sa.created_on)
),
 -- Calculate the average monthly transactions for each customer
AvgMonthlyTransactionsPerCustomer AS (
SELECT
   owner_id,
   AVG(TransactionsCount) AS avg_monthly_trans
FROM MonthlyTransactionsPerCustomer
GROUP BY owner_id
),
-- Categorizing customers based on their average monthly transactions
FrequencyCategory AS (
SELECT
  owner_id,
  avg_monthly_trans,
CASE
   WHEN avg_monthly_trans >= 10 THEN 'High Frequency'
   WHEN avg_monthly_trans >= 3 AND avg_monthly_trans < 10 THEN 'Medium Frequency' 
   WHEN avg_monthly_trans < 3 THEN 'Low Frequency' 
   ELSE 'Null' 
END AS frequency_category
FROM
  AvgMonthlyTransactionsPerCustomer
)
-- Aggregate results by frequency category
SELECT
	fc.frequency_category,
	COUNT(DISTINCT fc.owner_id) AS customer_count,
	ROUND(AVG(fc.avg_monthly_trans), 1) AS avg_transactions_per_month 
FROM FrequencyCategory fc
WHERE fc.frequency_category != 'Null' 
GROUP BY fc.frequency_category 
ORDER BY
        CASE fc.frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
        ELSE 4
    END;
/*
-- Remove Null for the final result
-- Rounded up the answer to 2 decimal places
-- Adjusted the CASE condition for perfect result */
