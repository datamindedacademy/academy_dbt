{{ config(materialized='view') }}

select
    c.c_custkey,
    c.c_name,
    sum(o.o_totalprice) as total_spent,
    {% for status in var('order_statuses') %}
    sum(case when o.o_orderstatus = '{{ status }}' then 1 else 0 end)
        as num_orders_with_status_{{ status | lower }}{% if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('stg_customer') }} as c
left join {{ ref('stg_orders') }} as o on o.o_custkey = c.c_custkey
group by c.c_custkey, c.c_name
