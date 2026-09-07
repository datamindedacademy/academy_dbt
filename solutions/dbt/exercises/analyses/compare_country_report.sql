with expected as (
    select
        n.n_nationkey as nation_key,
        n.n_name as nation,
        count(distinct c.c_custkey) as customers,
        count(*) as orders,
        sum(o.o_totalprice) as revenue
    from {{ source('tpch', 'orders') }} as o
    join {{ source('tpch', 'customer') }} as c on c.c_custkey = o.o_custkey
    join {{ source('tpch', 'nation') }} as n on n.n_nationkey = c.c_nationkey
    where o.o_orderdate between date '{{ var("report_interval_start") }}'
        and date '{{ var("report_interval_end") }}'
    group by n.n_nationkey, n.n_name
), actual as (
    select nation_key, nation, customers, orders, revenue
    from {{ ref('revenue_per_nation') }}
), missing as (
    select * from expected except all select * from actual
), unexpected as (
    select * from actual except all select * from expected
)
select 'missing' as difference, * from missing
union all
select 'unexpected' as difference, * from unexpected
