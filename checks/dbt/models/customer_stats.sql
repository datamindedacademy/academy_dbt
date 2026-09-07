{{ config(materialized='table', tags=['daily']) }}
SELECT
    c.c_custkey,
    SUM(o.o_totalprice) AS total_spent,
    {% for status in ['O', 'P', 'F'] %}
    SUM(CASE WHEN o.o_orderstatus = '{{ status }}' THEN 1 ELSE 0 END)
        AS num_orders_with_status_{{ status | lower }}
    {% if not loop.last %},{% endif %}
    {% endfor %}
FROM {{ ref('stg_customer') }} AS c
JOIN {{ ref('stg_orders') }} AS o ON o.o_custkey = c.c_custkey
GROUP BY c.c_custkey
