# SQL exercise 4: Use CTEs

Calculate revenue per Asian nation from orders supplied within that same nation.

1. Join the customer, order, order-line, supplier, nation, and region tables in `samples.tpch`.
2. Keep rows where the customer and supplier belong to the same nation in Asia.
3. Calculate `sum(l_extendedprice * (1 - l_discount))` per nation.
4. Use one or more common table expressions (`CTEs`) for intermediate results.

A CTE gives a name to a query result within one SQL statement:

```sql
with example as (
    select * from samples.tpch.nation
)
select * from example;
```
