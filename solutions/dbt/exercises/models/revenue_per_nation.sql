select
    nation_key,
    nation,
    count(distinct o_custkey) as customers,
    count(*) as orders,
    sum(o_totalprice) as revenue
from {{ ref('int_orders_with_nation') }}
group by nation_key, nation
