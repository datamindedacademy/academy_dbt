create or replace view ${destination}.sa_tpch_int_orders as
select cast(o_orderkey as bigint) as order_id,
       cast(o_custkey as bigint) as customer_id,
       cast(o_orderdate as date) as order_date,
       cast(o_orderstatus as string) as order_status,
       cast(o_totalprice as decimal(18, 2)) as order_amount
from samples.tpch.orders;
