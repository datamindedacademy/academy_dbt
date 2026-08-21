# Exercise 2 — Joining tables

## Goal

Combine data from multiple tables with `INNER JOIN` and `LEFT JOIN`, including
joins across more than two tables.

## Why this matters

Real data is spread over many tables: customers in one, orders in another,
countries in a third. Joins glue tables together "horizontally" so you can answer
questions that span them.

## Concepts

A join matches rows from two tables on a condition, usually a shared key:

```sql
SELECT o.o_orderkey, c.c_name, o.o_orderstatus
FROM tpch.orders AS o
INNER JOIN tpch.customer AS c ON o.o_custkey = c.c_custkey;
```

There are four join types. They differ in what happens to rows *without* a match:

| Join type | Keeps |
|---|---|
| `INNER JOIN` | only rows that match in **both** tables |
| `LEFT JOIN` | **all** rows of the left (first) table + matches from the right |
| `RIGHT JOIN` | **all** rows of the right (second) table + matches from the left |
| `FULL JOIN` | all rows of **both** tables |

When a row has no match, the columns of the other table are filled with `NULL`.
That is useful: to find customers *without* orders, `LEFT JOIN` orders onto
customers and keep the rows where the order key `IS NULL`.

You can chain joins: `FROM a JOIN b ON ... JOIN c ON ...` — each join adds one
more table to the result.

## Exercise

Write one query per question:

1. Show me all the customer names, together with their nation.
2. Show me all the customer names, together with their nation and in which
   continent (= region) this nation is.
3. Give me all the unique customer names that bought a product with a discount
   higher than 9%.
4. Show me all customers that have never placed an order.
5. Give me all unique African supplier names that supply parts of the brand
   `'Brand#43'`.

## Tips

- The relationship diagram in [`../README.md`](../README.md) shows which keys
  connect which tables.
- Question 3 needs three tables: `customer` → `orders` → `lineitem`
  (the discount is `l_discount`, stored as a fraction: 9% = `0.09`).
- Question 4 is the classic `LEFT JOIN` + `IS NULL` pattern.
- Question 5 chains `region` → `nation` → `supplier` → `partsupp` → `part`.
