create or replace view ${destination}.ca_sales_int_orders_enriched as
select o.order_id, o.customer_id, n.nation_id, n.nation_name, o.order_date, o.order_amount
from ${destination}.sa_tpch_ext_orders as o
join ${destination}.sa_tpch_ext_customers as c on o.customer_id = c.customer_id
join ${destination}.sa_tpch_ext_nations as n on c.nation_id = n.nation_id
where o.order_date >= date '${start_date}'
  and o.order_date < date '${end_date}';
