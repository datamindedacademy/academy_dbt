select
    nation_id,
    nation_name,
    cast(date_trunc('MONTH', order_date) as date) as order_month,
    count(*) as order_count,
    count(distinct customer_id) as customer_count,
    cast(sum(order_amount) as decimal(28, 2)) as order_value
from {{ ref('ca_sales_int_orders_enriched') }}
group by
    nation_id,
    nation_name,
    cast(date_trunc('MONTH', order_date) as date)
