select order_id, customer_id, order_date, order_status, order_amount
from {{ ref('sa_tpch_int_orders') }}
