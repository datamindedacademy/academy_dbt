select
    c_custkey as custkey,
    coalesce(sum(orders.o_totalprice), 0) as total_amount_spent,
    {% for orderstatus in var("order_statuses") %}
        count(case when orders.o_orderstatus = '{{ orderstatus }}' then 1 end) as num_orders_with_status_{{ orderstatus }}
        {% if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref("customer") }}
left join {{ ref("orders") }}
    on customer.c_custkey = orders.o_custkey
group by c_custkey
