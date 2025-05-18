# DataAnalytics-Assessment

1. ### Assessment_Q1 – High-Value Customers with Multiple Products

**Goal:**  
Identify customers who have both funded savings and funded investment plans, to support cross-selling strategies.

**Approach:**

- **Step 1: Customer Info**
  - Extracted `id` and full name from `users_customuser` and stored it in a CTE (`customer_info`).

- **Step 2: Savings Plans**
  - Filtered the `savings_savingsaccount` table to include only successful transactions (`transaction_status = 'success'`).
  - Joined with the `plans_plan` table to identify savings plans using the flag `is_regular_savings = 1`.
  - Aggregated savings plan count and total deposits per customer in a CTE (`savings_plans`).

- **Step 3: Investment Plans**
  - Similar to savings, filtered `savings_savingsaccount` for successful transactions.
  - Joined with `plans_plan` and filtered for investment plans using `is_a_fund = 1`.
  - Aggregated investment plan count and total deposits per customer in a CTE (`investment_plans`).

- **Step 4: Final Join & Output**
  - Performed an inner join across all three CTEs to include only customers who have:
    - At least one funded savings plan
    - At least one funded investment plan
  - Calculated the total deposits (savings + investment).
  - Sorted the result by total deposit amount in descending order.

**Note:**  
Only customers with both plan types and confirmed deposits are included in the final result, ensuring accuracy in targeting for cross-sell opportunities.

2. ### Assessment_Q2 – Transaction Frequency Analysis

**Goal:**  
Segment customers into transaction frequency categories (High, Medium, Low) based on how often they transact each month.

**Approach:**

- **Step 1: Monthly Transaction Count**
  - Queried the `savings_savingsaccount` table to count successful transactions per user, grouped by month using `date_format(transaction_date, '%Y-%m')`.
  - Stored this in the `transactions_per_user_month` CTE.

- **Step 2: Average Monthly Transactions**
  - Calculated the average number of monthly transactions for each user using the `avg()` function.
  - Rounded the result to 2 decimal places in `avg_txns_per_user`.

- **Step 3: Frequency Categorization**
  - Categorized users based on their average transaction volume:
    - `High Frequency`: ≥ 10 transactions/month
    - `Medium Frequency`: 3–9 transactions/month
    - `Low Frequency`: ≤ 2 transactions/month
  - Stored this in `categorized_users`.

- **Step 4: Final Aggregation**
  - Aggregated the total number of users per category and computed the average transaction count within each group.
  - Final output includes: `frequency_category`, `customer_count`, and `avg_transactions_per_month`.

**Note:**  
Only successful transactions (`transaction_status = 'success'`) were considered to ensure accurate frequency segmentation.

3. ### Assessment_Q3 – Account Inactivity Alert

**Goal:**  
Identify active plans (either savings or investments) that have not received any inflow transactions in the past 365 days.

**Approach:**

- **Step 1: Rank Transactions**
  - Queried the `savings_savingsaccount` table for successful transactions.
  - Used `row_number()` to rank transactions by `transaction_date` (descending) per user to identify the latest transaction.
  - Stored this in the `transaction_rank` CTE.

- **Step 2: Get Last Transaction Per User**
  - Filtered only the most recent transaction (`rn = 1`) per user and returned the `plan_id`, `owner_id`, and `last_transaction_date`.
  - Stored this in the `last_transactions` CTE.

- **Step 3: Retrieve Plan Details**
  - Queried `plans_plan` for all active (non-deleted) plans.
  - Classified each plan as either `'Savings'` or `'Investment'` based on the `is_regular_savings` flag.
  - Stored this in the `plan_details` CTE.

- **Step 4: Merge and Filter**
  - Joined `last_transactions` and `plan_details` using `plan_id` and `owner_id`.
  - Calculated `inactivity_days` as the difference between the current date and the last transaction date.
  - Filtered only those records where `inactivity_days` ≥ 365.

**Final Output:**  
Returns:
- `plan_id`
- `owner_id`
- `type` (Savings or Investment)
- `last_transaction_date`
- `inactivity_days`  
for plans that have been inactive for over one year.

**Note:**  
This logic ensures that only active, funded plans with no inflows in the past 365 days are returned for alerting.

4. ### Assessment_Q4 – Customer Lifetime Value (CLV) Estimation

**Goal:**  
Estimate the Customer Lifetime Value (CLV) based on historical transaction behavior and tenure.

**Approach:**

- **Step 1: Get Customer Info**
  - Queried the `users_customuser` table to get:
    - `id` (as unique customer identifier),
    - Full name (concatenation of first and last names),
    - `tenure_months` calculated as the number of months since `date_joined`.
  - Stored this in the `customer_info_` CTE.

- **Step 2: Get Transaction Info**
  - Queried `savings_savingsaccount` for all successful transactions.
  - Grouped by `owner_id` to calculate:
    - `total_transactions` (count of successful deposits),
    - Estimated `profit`, using a proxy formula: `0.1%` of total confirmed amount.
  - Stored this in the `transaction_info_` CTE.

- **Step 3: Compute CLV Metrics**
  - Joined both CTEs on `owner_id`.
  - Computed:
    - `transaction_per_tenure` = total transactions ÷ months of tenure,
    - `avg_profit_per_transaction` = total profit ÷ total transactions.
  - Stored this in the `final_` CTE.

- **Step 4: Calculate Estimated CLV**
  - Applied the CLV formula:  
    `Estimated CLV = (transactions/month × 12) × average profit per transaction`
  - Rounded to 2 decimal places for readability.

**Final Output:**  
Returns:
- `customer_id`
- `name`
- `tenure_months`
- `total_transactions`
- `estimated_clv`  

This output helps prioritize customers with the highest potential long-term value.

**Note:**  
The profit margin of 0.1% is an assumed placeholder to simulate real-world profitability metrics.
