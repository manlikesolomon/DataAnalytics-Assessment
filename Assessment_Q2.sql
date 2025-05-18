with transactions_per_user_month as ( -- get number of transactions per month, per user
    select
        owner_id,
        date_format(transaction_date, '%Y-%m') as txn_month,
        count(*) as txn_count
    from savings_savingsaccount s
    where s.transaction_status = 'success'
    group by s.owner_id, txn_month
),
avg_txns_per_user as ( -- get average transactions per month, per user
    select
        owner_id,
        round(avg(txn_count), 2) as avg_txn_per_month
    from transactions_per_user_month
    group by owner_id
),
categorized_users as ( -- categorize users based on average transaction count
    select
        case 
            when avg_txn_per_month >= 10 then 'High Frequency'
            when avg_txn_per_month >= 3 then 'Medium Frequency'
            else 'Low Frequency'
        end as frequency_category,
        avg_txn_per_month
    from avg_txns_per_user
),
final_aggregation as ( -- get aggregates on frequency categories
    select
        frequency_category,
        count(*) as customer_count,
        round(avg(avg_txn_per_month), 1) as avg_transactions_per_month
    from categorized_users
    group by frequency_category
)
select * 
from final_aggregation;