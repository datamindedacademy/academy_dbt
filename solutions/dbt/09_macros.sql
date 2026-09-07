-- Solutions: dbt exercise 9 — Macros
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
