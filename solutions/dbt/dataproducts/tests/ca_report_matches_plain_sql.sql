-- Independent source query: compare every value, including extra or missing rows.
with expected as (
    select
        n.n_nationkey as nation_id,
        n.n_name as nation_name,
        cast(date_trunc('MONTH', o.o_orderdate) as date) as order_month,
        count(*) as order_count,
        count(distinct c.c_custkey) as customer_count,
        sum(o.o_totalprice) as order_value
    from {{ source('tpch', 'orders') }} as o
    join {{ source('tpch', 'customer') }} as c on o.o_custkey = c.c_custkey
    join {{ source('tpch', 'nation') }} as n on c.c_nationkey = n.n_nationkey
    where o.o_orderdate >= cast('{{ var("report_interval_start") }}' as date)
      and o.o_orderdate < cast('{{ var("report_interval_end") }}' as date)
    group by n.n_nationkey, n.n_name, cast(date_trunc('MONTH', o.o_orderdate) as date)
), actual as (
    select nation_id, nation_name, order_month, order_count, customer_count, order_value
    from {{ ref('ca_sales_ext_monthly_order_value') }}
), missing_or_changed as (
    select * from expected
    except all
    select * from actual
), extra_or_changed as (
    select * from actual
    except all
    select * from expected
)
select 'missing_or_changed' as difference, * from missing_or_changed
union all
select 'extra_or_changed' as difference, * from extra_or_changed
