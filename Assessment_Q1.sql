with 
customer_info as -- get required customer info in a CTE
(
select 
	id,
	concat(first_name, ' ', last_name) name
from adashi_staging.users_customuser
),
savings_plans as ( -- get agrregated savings plan info
    select 
        s.owner_id,
        count(distinct s.plan_id) as savings_count,
        sum(s.confirmed_amount) as savings_total
    from savings_savingsaccount s
    join plans_plan p
        on s.plan_id = p.id
    where s.transaction_status = 'success'
      and p.is_regular_savings = 1
    group by s.owner_id
),
investment_plans as (  -- get agrregated investment plan info
    select 
        s.owner_id,
        count(distinct s.plan_id) as investment_count,
        sum(s.confirmed_amount) as investment_total
    from savings_savingsaccount s
    join plans_plan p
        on s.plan_id = p.id
    where s.transaction_status = 'success'
      and p.is_a_fund = 1
    group by s.owner_id
),
combined as ( 
    select 
        c.id as owner_id,
        c.name,
        s.savings_count,
        i.investment_count,
        round((s.savings_total + i.investment_total), 2) as total_deposits
    from customer_info c
    join savings_plans s
    	on c.id = s.owner_id
    join investment_plans i
        on c.id = i.owner_id
)
select * 
from combined
order by total_deposits desc;