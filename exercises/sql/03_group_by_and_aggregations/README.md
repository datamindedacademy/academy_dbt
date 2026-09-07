# Exercise 3 — Group by and aggregations

## Goal

Summarize many rows into one with aggregate functions (`COUNT`, `SUM`, `AVG`,
`MIN`, `MAX`), group results with `GROUP BY`, sort them with `ORDER BY`, and
filter groups with `HAVING`.

## Why this matters

Most business questions are about totals and averages, not individual rows:
"how many customers per country?", "who are our best customers?". Aggregation is
how raw rows become answers.

## Concepts

**Aggregate functions** collapse a set of rows into a single value:

```sql
SELECT COUNT(*), AVG(o_totalprice), MAX(o_totalprice)
FROM tpch.orders;
```

**GROUP BY** splits the rows into groups first, then aggregates each group
separately — one result row per group:

```sql
SELECT o_orderstatus, COUNT(*) AS num_orders, AVG(o_totalprice) AS avg_price
FROM tpch.orders
GROUP BY o_orderstatus;
```

**ORDER BY** sorts the result. Default is ascending; add `DESC` to reverse:

```sql
ORDER BY num_orders DESC
```

**HAVING** filters *groups* the way `WHERE` filters *rows*. `WHERE` runs before
grouping (on individual rows); `HAVING` runs after (on aggregated results):

```sql
SELECT o_custkey, COUNT(*)
FROM tpch.orders
WHERE o_totalprice < 100000   -- filters individual orders
GROUP BY o_custkey
HAVING COUNT(*) > 5;          -- filters customer groups
```

**Order of evaluation.** A SQL query is *not* processed top-to-bottom:

1. `FROM` / `JOIN` — choose and join tables
2. `WHERE` — filter rows
3. `GROUP BY` — form groups
4. `HAVING` — filter groups
5. `SELECT` — compute the output columns
6. `DISTINCT` — deduplicate
7. `ORDER BY` — sort
8. `LIMIT` — cut off

This explains, for example, why you cannot use a `SELECT` alias inside `WHERE`.

## Exercise

### Aggregations

1. What is the highest total price of any order we've ever received?
2. How many customers do we have from Germany?
3. What is the average total order price for orders from German customers?
4. Show me the amount of customers per country; list the countries with the most
   customers first.
5. What is the total amount spent and the average amount spent per customer?
   Show our best customers (= most-paying) first.

### Having

6. Show me all the customers that have placed more than 25 orders.
7. Show me the customers that have placed more than 15 orders above
   100 000 euros.

## Tips

- Questions 2–3 need a join with `nation` (`n_name = 'GERMANY'`).
- The sample database is small. If questions 6–7 return zero rows, lower the
  thresholds to verify that your query logic works.
