USE `adashi_staging`;
-- Explore All Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES; 

-- Explore All columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;


/* ================================================================================================
 Q1: Identify customers with at least one funded savings plan AND one funded investment plan 
=================================================================================================== 
 I start by creating a CTE to group and count plans for all users */
WITH CusPlanCounts AS (
	SELECT
        p.owner_id,
        COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_plan_count,
        COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_plan_count
    FROM
        plans_plan p
    GROUP BY
        p.owner_id
),
  /* Filter users who have both plan types */
Userswitheach AS (
       
SELECT
  cpc.owner_id,
  cpc.savings_plan_count,
  cpc.investment_plan_count
FROM
  CusPlanCounts cpc
  WHERE
   cpc.savings_plan_count >= 1 AND cpc.investment_plan_count >= 1
),
  /*  Calculate total deposits for all users
    This is calculated independently of the plan counts for simplicity, 
    then summing all deposits for each user. */
UserTotalDeposits AS (
      SELECT
        sa.owner_id,
        SUM(sa.confirmed_amount) AS total_deposits
    FROM
        savings_savingsaccount sa
    GROUP BY
        sa.owner_id
)
/* Joining Users with at least One investment plan and One saving plan
with their details and total deposits */

SELECT
	us.owner_id,
    CONCAT (uc.first_name,' ', uc.last_name) as name,
    us.savings_plan_count AS savings_count, 
    us.investment_plan_count AS investment_count, -- Renaming
    ROUND(COALESCE(utd.total_deposits, 0), 2) AS total_deposits
FROM Userswitheach us
JOIN users_customuser uc ON us.owner_id = uc.id
LEFT JOIN UserTotalDeposits utd ON us.owner_id = utd.owner_id
ORDER BY total_deposits DESC;

-- Renaming the columns
-- creating the full name by concatinating the first and last name
-- Using LEFT JOIN in case a userswitheach has plans but no deposits