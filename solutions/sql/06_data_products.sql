-- Plain SQL equivalent of the data-product report. Run this query as supplied.
-- The country is the customer's country. Include all order statuses.
select
    n.n_nationkey as nation_id,
    n.n_name as nation_name,
    cast(date_trunc('MONTH', o.o_orderdate) as date) as order_month,
    count(*) as order_count,
    count(distinct c.c_custkey) as customer_count,
    sum(o.o_totalprice) as order_value
from samples.tpch.orders as o
join samples.tpch.customer as c on o.o_custkey = c.c_custkey
join samples.tpch.nation as n on c.c_nationkey = n.n_nationkey
where o.o_orderdate >= date '1995-01-01'
  and o.o_orderdate < date '1995-04-01'
group by n.n_nationkey, n.n_name, cast(date_trunc('MONTH', o.o_orderdate) as date)
order by nation_id, order_month;
