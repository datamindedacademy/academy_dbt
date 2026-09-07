-- Solutions: dbt exercise 2 — Sources, staging models, customer_stats
-- Compiled form (runnable directly). The dbt/Jinja original is in comments.

-- models/stg_customer.sql:
--   SELECT * FROM {{ source('tpch', 'customer') }}
SELECT * FROM samples.tpch.customer;

-- models/stg_orders.sql:
--   SELECT * FROM {{ source('tpch', 'orders') }}
SELECT * FROM samples.tpch.orders;

-- models/customer_stats.sql:
--   SELECT
--       c.c_custkey,
--       c.c_name,
--       SUM(o.o_totalprice) AS total_spent
--   FROM {{ ref('stg_customer') }} AS c
--   LEFT JOIN {{ ref('stg_orders') }} AS o ON o.o_custkey = c.c_custkey
--   GROUP BY c.c_custkey, c.c_name
SELECT
    c.c_custkey,
    c.c_name,
    SUM(o.o_totalprice) AS total_spent
FROM samples.tpch.customer AS c
LEFT JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
GROUP BY c.c_custkey, c.c_name;

-- models/sources.yml:
--   version: 2
--   sources:
--     - name: tpch
--       database: samples
--       schema: tpch
--       tables:
--         - name: customer
--         - name: orders
