select * from savings_savingsaccount
limit 100;
/* =========================================================================================================
  Q4: Estimate Customer Lifetime Value (CLV) based on account tenure and transaction volume.
========================================================================================================
-- Calculate account tenure in months for each customer */

WITH CustomerTenure AS (
SELECT
	uc.id AS customer_id,
    CONCAT(uc.first_name,' ', uc.last_name ) AS name,
    uc.date_joined AS signup_date,
	PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM CURRENT_DATE), EXTRACT(YEAR_MONTH FROM uc.date_joined)) AS tenure_months    
FROM
     users_customuser uc
),
 -- Calculate total transactions and total deposit value per customer
CustomerTransactionSummary AS (
SELECT
  ssa.owner_id AS customer_id,
  COUNT(ssa.id) AS total_transactions,
  SUM(ssa.confirmed_amount) AS total_deposit_value 
FROM
	savings_savingsaccount ssa
    GROUP BY
        ssa.owner_id
), 
-- Combine tenure, transaction summary, and calculate CLV components
CLVCalculation AS (     
SELECT
	ct.customer_id,
    ct.name,
CASE WHEN ct.tenure_months <= 0 THEN 1 ELSE ct.tenure_months END AS tenure_months, 
    COALESCE(cts.total_transactions, 0) AS total_transactions,
	COALESCE(cts.total_deposit_value, 0) AS total_deposit_value,
        -- Avg profit per transaction: 0.1% of the transaction value.
        -- If total_transactions is 0, avg_profit_per_transaction is 0.
CASE WHEN 
	COALESCE(cts.total_transactions, 0) > 0
    THEN (0.001 * (COALESCE(cts.total_deposit_value, 0) / cts.total_transactions))
	ELSE 0
END AS avg_profit_per_transaction
    FROM
        CustomerTenure ct
    LEFT JOIN
        CustomerTransactionSummary cts ON ct.customer_id = cts.customer_id
)
-- Calculate Estimated CLV and order
SELECT
    cc.customer_id,
    cc.name,
    cc.tenure_months,
    cc.total_transactions,
CASE WHEN cc.tenure_months > 0
	THEN ROUND(((cc.total_transactions * 1.0 / cc.tenure_months) * 12 * cc.avg_profit_per_transaction), 2)
    ELSE 0
END AS estimated_clv
FROM
    CLVCalculation cc
ORDER BY
    estimated_clv DESC;


-- COALESCE to set their totals and averages to zero and still include them in the results.
-- Avoid division by zero or negative tenure
-- I selected dated_joined as the sign_up since created_on is similiar