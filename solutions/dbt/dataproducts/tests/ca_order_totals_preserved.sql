-- Compare the report with the original orders before any customer joins.
with original as (
    select count(*) as order_count, sum(o_totalprice) as order_value
    from {{ source('tpch', 'orders') }}
    where o_orderdate >= cast('{{ var("report_interval_start") }}' as date)
      and o_orderdate < cast('{{ var("report_interval_end") }}' as date)
), report as (
    select sum(order_count) as order_count, sum(order_value) as order_value
    from {{ ref('ca_sales_ext_monthly_order_value') }}
)
select original.order_count as original_count, report.order_count as report_count,
       original.order_value as original_value, report.order_value as report_value
from original cross join report
where not (original.order_count <=> report.order_count)
   or not (original.order_value <=> report.order_value)
