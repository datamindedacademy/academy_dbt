# Exercise 1 — Selecting and filtering rows

## Goal

Write `SELECT` queries that pick specific columns, filter rows with `WHERE`,
remove duplicates with `DISTINCT`, and match text patterns with `LIKE`.

## Why this matters

Filtering is the single most common thing you do with a database. Nearly every
question ("which orders...", "all customers that...") starts with selecting the
right rows.

## Concepts

**Selecting columns.** Instead of `SELECT *`, list the columns you want:

```sql
SELECT c_name, c_mktsegment
FROM tpch.customer;
```

**Filtering rows.** The `WHERE` clause keeps only rows that match a condition.
Combine conditions with `AND`, `OR`, `NOT`, and parentheses:

```sql
SELECT o_orderkey, o_totalprice
FROM tpch.orders
WHERE o_orderstatus = 'F' AND (o_totalprice > 50000 OR o_orderpriority = '1-URGENT');
```

**Transforming values.** You can compute new columns in the `SELECT` list:

```sql
SELECT
  CASE
    WHEN o_totalprice > 100000 THEN 'big'
    ELSE 'small'
  END AS order_size,              -- if-then-else logic
  COALESCE(o_comment, 'no comment') AS comment_filled,  -- fallback for NULL
  CAST(o_orderdate AS varchar) AS orderdate_text        -- change data type
FROM tpch.orders;
```

## Exercise

Write one query per question:

1. Give me all the customers where the marketing segment is `'MACHINERY'`.
2. Give me all the orders where the order priority is `'3-MEDIUM'`, the total
   price is above 100 000 euros, and the status is not `'F'`.
3. Which order priority levels do we use?
   > Tip: return only unique rows with `SELECT DISTINCT column1, column2, ... FROM ...`
4. For each order, give me the order key and the total price multiplied by the
   order's priority (the leading digit of `o_orderpriority`).
5. Give me all the orders where the order comment contains the word "express".
   > Tip: pattern matching works with `WHERE column LIKE '%abc%'`
   > (`%` matches any sequence of characters).

## Tips

- Column names are prefixed per table: customers use `c_`, orders use `o_`.
- For question 4: the priority is text like `'3-MEDIUM'`. You need its first
  character as a number. Look at `SUBSTRING` and `CAST`.
