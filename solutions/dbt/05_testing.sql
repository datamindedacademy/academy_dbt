-- Solution: dbt exercise 5. A SQL test passes when it returns zero rows.
-- Run the completed dbt answer in the Codespace terminal, from the repository root:
-- dbt build --project-dir solutions/dbt/exercises --select +customer_stats my_first_dbt_model my_second_dbt_model
-- dbt test --project-dir solutions/dbt/exercises --select customer_stats my_first_dbt_model my_second_dbt_model
-- These commands use solutions/dbt/exercises. They do not execute this snippet file.
-- The completed models already contain the null fix; these tests should pass.

-- First fix models/example/my_first_dbt_model.sql to return only id = 1.
-- Run dbt build to replace its data and run the starter tests.
--
-- Extend models/customer_stats.yml with these tests on c_custkey:
--   data_tests: [unique, not_null]
--
-- tests/customer_stats_nonnegative.sql:
--   SELECT c_custkey, total_spent
--   FROM {{ ref('customer_stats') }}
--   WHERE total_spent < 0
--
-- Plain SQL equivalent:
WITH customer_stats AS (
    SELECT c.c_custkey, SUM(o.o_totalprice) AS total_spent
    FROM samples.tpch.customer AS c
    LEFT JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
    GROUP BY c.c_custkey
)
SELECT c_custkey, total_spent
FROM customer_stats
WHERE total_spent < 0;
