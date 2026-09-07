# dbt exercise 11: Build the TPC-H country report

Build a dbt report that matches this SQL result:

```sql
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
```

1. Add `nation` to your TPC-H source declaration. Create `stg_nation`.
2. Create `int_orders_with_nation`. Join the staging models with `ref()`.
3. Use the macro from exercise 9 to filter the report interval.
4. Create `revenue_per_nation` to calculate the grouped result.
5. Test `nation_key` with `unique` and `not_null`. Add a SQL test for negative `revenue`.
6. Add descriptions. Run `dbt build` and `dbt docs generate`.
7. Compare the result with the SQL above. Inspect the dependency graph.

`revenue` means total order value across all statuses. The sample data specifies no currency.
Use the customer's nation. For the Postgres backup, remove the `samples.` prefixes.
