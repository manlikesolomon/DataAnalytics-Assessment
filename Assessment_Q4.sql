with customer_info_ as ( -- get required customer info in a CTE
select 
	id,
	TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE()) tenure_months,
	concat(first_name, ' ', last_name) name
from users_customuser
	),
transaction_info_ as ( -- get transaction info in a CTE
select 
	owner_id,
	count(id) as total_transactions,
	(0.1 * sum(confirmed_amount)) / 100 profit
from savings_savingsaccount
where transaction_status = 'success'
group by owner_id
),
final_ as ( -- join ctes and compute details needed for CLV
select 
	id as customer_id,
	name,
	tenure_months,
	total_transactions,
	(total_transactions / tenure_months) as transaction_per_tenure,
	(profit / total_transactions) as avg_profit_per_transaction
from customer_info_ c
inner join transaction_info_ t
on c.id = t.owner_id
)
select 
	customer_id,
	name,
	tenure_months,
	total_transactions,
	round((transaction_per_tenure * 12 * avg_profit_per_transaction), 2) as estimated_clv
from final_