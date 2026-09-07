-- Solution: dbt exercise 11. Compare with workspace.dbt.revenue_per_nation.
-- Run the completed dbt answer in the Codespace terminal, from the repository root:
-- dbt build --project-dir solutions/dbt/exercises --select +revenue_per_nation
-- dbt show --project-dir solutions/dbt/exercises --select revenue_per_nation --limit 10
-- dbt show --project-dir solutions/dbt/exercises --select compare_country_report
-- dbt docs generate --project-dir solutions/dbt/exercises
-- These commands use solutions/dbt/exercises. They do not execute this snippet file.

select
    n.n_nationkey as nation_key,
    n.n_name as nation,
    count(distinct c.c_custkey) as customers,
    count(*) as orders,
    sum(o.o_totalprice) as revenue
from samples.tpch.orders as o
join samples.tpch.customer as c on c.c_custkey = o.o_custkey
join samples.tpch.nation as n on n.n_nationkey = c.c_nationkey
where o.o_orderdate between date '1995-01-01' and date '1995-03-31'
group by n.n_nationkey, n.n_name
order by revenue desc;
