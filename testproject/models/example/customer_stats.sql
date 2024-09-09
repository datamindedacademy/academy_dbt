select
    c_custkey as custkey,
    coalesce(sum(orders.o_totalprice), 0) as total_amount_spent
from {{ ref("customer") }}
left join {{ ref("orders") }}
    on customer.c_custkey = orders.o_custkey
group by c_custkey
