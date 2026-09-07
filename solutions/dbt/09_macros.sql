-- Solutions: dbt exercise 9 — Macros
-- Run the completed dbt answer in the Codespace terminal, from the repository root:
-- dbt run --project-dir solutions/dbt/exercises --select +orders
-- dbt test --project-dir solutions/dbt/exercises --select orders
-- dbt show --project-dir solutions/dbt/exercises --select orders --limit 10
-- These commands use solutions/dbt/exercises. They do not execute this snippet file.

-- Compiled form (runnable directly). The dbt/Jinja original is in comments.

-- macros/is_in_reporting_interval.sql:
--   {% macro is_in_reporting_interval(date_column) %}
--       {{ date_column }}
--         BETWEEN date '{{ var("report_interval_start") }}'
--         AND date '{{ var("report_interval_end") }}'
--   {% endmacro %}

-- Usage in models/orders.sql:
--   SELECT *
--   FROM {{ ref('stg_orders') }}
--   WHERE {{ is_in_reporting_interval('o_orderdate') }}
--
-- ...which compiles to:
SELECT *
FROM samples.tpch.orders
WHERE o_orderdate
  BETWEEN DATE '1995-01-01'
  AND DATE '1995-03-31';
