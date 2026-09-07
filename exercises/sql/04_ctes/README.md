# Exercise 4 — Common Table Expressions (CTEs)

## Goal

Break a complex query into readable steps using CTEs (`WITH ... AS`).

## Why this matters

Real queries grow long. Nested subqueries become unreadable fast. CTEs let you
name intermediate results and read a query top-to-bottom as a series of steps.
This is also *the* core style used in dbt models later in this course.

## Concepts

A CTE is a named "temporary table" that exists only for the duration of one query:

```sql
WITH german_customers AS (          -- step 1: define a temporary table
    SELECT c_custkey, c_name
    FROM tpch.customer
    JOIN tpch.nation ON c_nationkey = n_nationkey
    WHERE n_name = 'GERMANY'
),

german_orders AS (                  -- step 2: may select from step 1
    SELECT o_orderkey, o_totalprice
    FROM tpch.orders
    JOIN german_customers ON o_custkey = c_custkey
)

SELECT SUM(o_totalprice)            -- final step: use any CTE like a table
FROM german_orders;
```

Each CTE can select from the ones defined before it. The final `SELECT` produces
the actual result.

## Exercise

What is the total amount of revenue per country in Asia from locally supplied
orders?

**Clarification:** for each nation in Asia, list the revenue that resulted from
transactions in which the customer (who orders parts) and the supplier (who
fills them) were both within that nation.

Revenue is defined as `SUM(l_extendedprice * (1 - l_discount))`.

Use one or more CTEs for intermediate results.

## Tips

- A line item knows its supplier (`l_suppkey`) and, via its order, its customer.
  "Locally supplied" means: the customer's nation = the supplier's nation.
- One possible decomposition: a CTE for Asian nations, a CTE joining orders +
  line items + customer nation + supplier nation, then the final aggregation.
- You need `nation` twice (once for the customer, once for the supplier). Give
  each occurrence its own alias.
