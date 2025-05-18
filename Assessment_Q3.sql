with transaction_rank as ( -- rank transactions to get last transaction with relevant details
select 
	plan_id,
	owner_id,
	transaction_date,
	row_number() over( partition by owner_id order by transaction_date desc) as rn
from savings_savingsaccount
    where transaction_status = 'success' 
),
last_transactions as ( -- get last transaction details in a CTE
select 
	plan_id,
	owner_id,
	date(transaction_date) as last_transaction_date
from transaction_rank
where rn = 1
),
plan_details as ( -- get plan details in a cte
select 
	id as plan_id,
    owner_id,
    case 
    	when is_regular_savings = true then 'Savings'
        else 'Investment'
        end as type
from plans_plan
where is_deleted = false
),
merged_ as ( -- combine details in the final cte
select 
	p.plan_id,
	p.owner_id,
	`type`,
	last_transaction_date,
	DATEDIFF(CURRENT_DATE(), last_transaction_date) as inactivity_days
from last_transactions l, plan_details p
where l.plan_id = p.plan_id and l.owner_id = p.owner_id
and DATEDIFF(CURRENT_DATE(), last_transaction_date) >= 365
)
select * from merged_