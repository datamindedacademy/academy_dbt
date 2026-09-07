# SQL exercise 1: Select and filter

Use `samples.tpch`. Write one query per task.

1. Select customers whose `c_mktsegment` is `'MACHINERY'`.
2. Select orders with priority `'3-MEDIUM'`, total price above `100000`, and status other than `'F'`.
3. List the distinct order priorities.
4. Return each order key and its total price multiplied by the first digit of its priority.
5. Select orders whose comment contains `'express'`.

Use `SELECT DISTINCT` for unique values and `LIKE '%express%'` for the text match.
Cast the first priority character to an integer before multiplication.
