select
    o.order_id,
    o.customer_id,
    n.nation_id,
    n.nation_name,
    o.order_date,
    o.order_amount
from {{ ref('sa_tpch_ext_orders') }} as o
inner join {{ ref('sa_tpch_ext_customers') }} as c
    on o.customer_id = c.customer_id
inner join {{ ref('sa_tpch_ext_nations') }} as n
    on c.nation_id = n.nation_id
where o.order_date >= cast('{{ var("report_interval_start") }}' as date)
  and o.order_date < cast('{{ var("report_interval_end") }}' as date)
