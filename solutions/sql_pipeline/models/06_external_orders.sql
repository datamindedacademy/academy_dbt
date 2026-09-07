create or replace table ${destination}.sa_tpch_ext_orders using delta as
select order_id, customer_id, order_date, order_status, order_amount
from ${destination}.sa_tpch_int_orders;
