-- Solutions: dbt exercise 8 — Jinja for loops
-- Compiled form (runnable directly). The dbt/Jinja original is in comments.

-- models/customer_stats.sql:
--   SELECT
--       c.c_custkey,
--       c.c_name,
--       SUM(o.o_totalprice) AS total_spent,
--       {% for status in var('order_statuses', ['O', 'P', 'F']) %}
--       SUM(CASE WHEN o.o_orderstatus = '{{ status }}' THEN 1 ELSE 0 END)
--           AS num_orders_with_status_{{ status | lower }}
--       {% if not loop.last %},{% endif %}
--       {% endfor %}
--   FROM {{ ref('stg_customer') }} AS c
--   INNER JOIN {{ ref('stg_orders') }} AS o ON o.o_custkey = c.c_custkey
--   GROUP BY c.c_custkey, c.c_name
--
-- (Optional) the variable in dbt_project.yml:
--   vars:
--     order_statuses: ['O', 'P', 'F']
SELECT
    c.c_custkey,
    c.c_name,
    SUM(o.o_totalprice) AS total_spent,
    SUM(CASE WHEN o.o_orderstatus = 'O' THEN 1 ELSE 0 END) AS num_orders_with_status_o,
    SUM(CASE WHEN o.o_orderstatus = 'P' THEN 1 ELSE 0 END) AS num_orders_with_status_p,
    SUM(CASE WHEN o.o_orderstatus = 'F' THEN 1 ELSE 0 END) AS num_orders_with_status_f
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
GROUP BY c.c_custkey, c.c_name;
