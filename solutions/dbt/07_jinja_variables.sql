-- Solutions: dbt exercise 7 — Jinja variables
-- Compiled form (runnable directly). The dbt/Jinja original is in comments.

-- In dbt_project.yml:
--   vars:
--     report_interval_start: '1995-01-01'
--     report_interval_end: '1995-03-31'

-- models/orders.sql:
--   SELECT *
--   FROM {{ ref('stg_orders') }}
--   WHERE o_orderdate
--     BETWEEN date '{{ var("report_interval_start") }}'
--     AND date '{{ var("report_interval_end") }}'
SELECT *
FROM samples.tpch.orders
WHERE o_orderdate
  BETWEEN DATE '1995-01-01'
  AND DATE '1995-03-31';

-- The test (tests/orders_date_in_range.sql): select the orders OUTSIDE the
-- interval. 0 rows = pass. Compiled form:
WITH orders_in_interval AS (
    SELECT *
    FROM samples.tpch.orders
    WHERE o_orderdate
      BETWEEN DATE '1995-01-01'
      AND DATE '1995-03-31'
)
SELECT *
FROM orders_in_interval
WHERE o_orderdate < DATE '1995-01-01'
   OR o_orderdate > DATE '1995-03-31';
