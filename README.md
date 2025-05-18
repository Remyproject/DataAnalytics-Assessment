# DataAnalytics-Assessment

# For assesment_Q1

I was asked to identify users with at least one funded savings plan and one funded investment plan, along with their total deposits. My approach started with exploring the database using INFORMATION_SCHEMA to understand the structure and relationships between tables. I created a step-by-step strategy to break the question into smaller, manageable parts: first, count the number of savings and investment plans each user has; second, filter only users who had at least one of each; third, calculate the total confirmed deposits per user; and finally, join the results with the user details for a complete view.

The main challenge I faced was understanding how the data was organized. There were no clear labels, so I had to carefully check the values inside the plans_plan and savings_savingsaccount tables to figure out which fields indicated a savings plan, an investment plan, and a confirmed deposit. I also had to think which best way I to join the tables efficiently without overcomplicating the logic. For simplicity and readability I decided to use CTEs (Common Table Expressions) to separate each step.



# For Assesment_Q2

I needed to calculate how often each customer transacts to segment them into frequency categories: High, Medium, or Low. Since I already understood the data well, I went straight into counting how many transactions each customer had per month. I then calculated the average number of monthly transactions for each customer using their monthly totals. After that, I applied a CASE statement to group customers into frequency buckets based on their average: High (>= 10), Medium (3–9), and Low (<=2 or fewer).

The main challenge here was the categorization. At first, my conditions didn’t give me the expected results. Some users were showing up in the wrong category. I realized the issue was with how the CASE conditions. Adjusting the CASE structure to clearly separate each range fixed the problem and gave me the right output.



# To answer Assesment_Q3

I started by identifying all active accounts from the plans_plan table. An account is considered active if it is either a regular savings or investment plan. I selected the plan_id, owner_id, and the type of account (savings or investment).

Next, I moved to the savings_savingsaccount table to find the latest inflow transaction date for each plan using the MAX(created_on) function. This step helped determine the last time money was deposited into each active plan.

I then used a LEFT JOIN to combine both datasets—this was key. Some active accounts may have never had a transaction, so without the left join, those accounts would be excluded. After the join, I filtered for:

Accounts where the last inflow transaction was more than 365 days ago, 
Or accounts with no transaction history at all (where the last transaction date is NULL)

Finally, I calculated how many days each account has been inactive by subtracting the last transaction date from the current date.


The only challenge was dealing with accounts that had no transaction history at all. If I didn’t handle NULL values properly in the filtering step, I would’ve missed them entirely. Adding the IS NULL condition made sure such accounts were included in the result.


# To answer Assesment_Q4

To estimate Customer Lifetime Value (CLV), I focused on three components: how long a customer has been active (tenure), how many transactions they’ve made, and the assumed profit per transaction (set at 0.1% of the transaction value). 

First, I calculated account tenure by checking each customer's signup date from the users_customuser table. I used PERIOD_DIFF to measure the number of months between the signup date and today. For cases where a customer signed up recently and the result was zero or negative, I defaulted tenure to one month. This helped avoid division by zero errors during later calculations.

Next, I summarized transaction activity using the savings_savingsaccount table. For every customer, I counted how many transactions they had and summed up the total deposit value. I grouped this data by customer ID to prepare for the CLV calculation.

Then, I combined the tenure and transaction summaries using a left join. This step was important because some customers had no transactions at all. Without the left join, they would be excluded from the final results. I used COALESCE to handle missing values by replacing them with zero. For customers with transactions, I calculated the average profit per transaction as 0.1% of their average deposit. For those with no transactions, the average profit was set to zero.

Finally, I applied the CLV formula:
(total transactions / tenure in months) * 12 * average profit per transaction.
This projected their yearly value based on their current behavior. I made sure the calculation worked even when tenure was low or transactions were zero. The final result included each customer’s ID, name, tenure, total transactions, and estimated CLV. I ordered the output by CLV from highest to lowest.

One of the main challenges was handling customers with no transaction history. These users still had valid accounts but hadn't made any deposits. Without care, they could break the logic or be excluded from insights. By using left joins and default values, I ensured these edge cases were included while keeping the CLV estimation meaningful.

