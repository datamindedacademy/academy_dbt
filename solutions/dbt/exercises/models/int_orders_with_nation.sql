select
    o.o_orderkey,
    o.o_custkey,
    o.o_orderdate,
    o.o_totalprice,
    n.n_nationkey as nation_key,
    n.n_name as nation
from {{ ref('stg_orders') }} as o
join {{ ref('stg_customer') }} as c on c.c_custkey = o.o_custkey
join {{ ref('stg_nation') }} as n on n.n_nationkey = c.c_nationkey
where {{ is_in_reporting_interval('o.o_orderdate') }}
