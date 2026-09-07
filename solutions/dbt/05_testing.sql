-- Solutions: dbt exercise 5 — Testing
-- A singular test selects the WRONG rows: 0 rows returned = test passed.
-- Compiled form below. In the project, {{ ref('customer_stats') }} replaces
-- the CTE.

-- tests/customer_stats_no_negative_spending.sql
WITH customer_stats AS (
    SELECT
        c.c_custkey,
        SUM(o.o_totalprice) AS total_spent
    FROM samples.tpch.customer AS c
    INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
    GROUP BY c.c_custkey
)
SELECT *
FROM customer_stats
WHERE total_spent < 0;

-- tests/customer_stats_not_empty.sql
-- Filtering an empty table also gives 0 rows, so assert non-emptiness
-- explicitly with count(*):
WITH customer_stats AS (
    SELECT
        c.c_custkey,
        SUM(o.o_totalprice) AS total_spent
    FROM samples.tpch.customer AS c
    INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
    GROUP BY c.c_custkey
)
SELECT COUNT(*) AS n
FROM customer_stats
HAVING COUNT(*) = 0;

-- Generic tests go in models/schema.yml (not runnable as plain SQL):
--   models:
--     - name: customer_stats
--       columns:
--         - name: c_custkey
--           data_tests:
--             - unique
--             - not_null
--         - name: total_spent
--           data_tests:
--             - not_null
