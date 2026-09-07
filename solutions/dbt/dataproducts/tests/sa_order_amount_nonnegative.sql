-- A data test returns the rows that break its rule.
select order_id, order_amount
from {{ ref('sa_tpch_ext_orders') }}
where order_amount < 0
