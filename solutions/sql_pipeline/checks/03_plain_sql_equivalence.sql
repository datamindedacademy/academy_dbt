with expected as (
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
where o.o_orderdate >= date '${start_date}'
  and o.o_orderdate < date '${end_date}'
group by n.n_nationkey, n.n_name, cast(date_trunc('MONTH', o.o_orderdate) as date)
), actual as (
    select nation_id, nation_name, order_month, order_count, customer_count, order_value
    from ${destination}.ca_sales_ext_monthly_order_value
), missing as (
    select * from expected except all select * from actual
), extra as (
    select * from actual except all select * from expected
)
select 'plain_sql_equivalence' as check_name,
       (select count(*) from missing) + (select count(*) from extra) as failures;
