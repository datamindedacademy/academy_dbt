select 'report_nation_id_not_null' as check_name, count(*) as failures
from (
select nation_id from ${destination}.ca_sales_ext_monthly_order_value where nation_id is null
) as failing_rows
union all
select 'report_nation_name_not_null' as check_name, count(*) as failures
from (
select nation_name from ${destination}.ca_sales_ext_monthly_order_value where nation_name is null
) as failing_rows
union all
select 'report_order_month_not_null' as check_name, count(*) as failures
from (
select order_month from ${destination}.ca_sales_ext_monthly_order_value where order_month is null
) as failing_rows
union all
select 'report_order_count_not_null' as check_name, count(*) as failures
from (
select order_count from ${destination}.ca_sales_ext_monthly_order_value where order_count is null
) as failing_rows
union all
select 'report_customer_count_not_null' as check_name, count(*) as failures
from (
select customer_count from ${destination}.ca_sales_ext_monthly_order_value where customer_count is null
) as failing_rows
union all
select 'report_order_value_not_null' as check_name, count(*) as failures
from (
select order_value from ${destination}.ca_sales_ext_monthly_order_value where order_value is null
) as failing_rows
union all
select 'country_month_unique' as check_name, count(*) as failures
from (
select nation_id, order_month from ${destination}.ca_sales_ext_monthly_order_value group by nation_id, order_month having count(*) > 1
) as failing_rows
union all
select 'report_not_empty' as check_name, count(*) as failures
from (
select count(*) from ${destination}.ca_sales_ext_monthly_order_value having count(*) = 0
) as failing_rows
union all
select 'order_totals_preserved' as check_name, count(*) as failures
from (
with original as (
    select count(*) as order_count, sum(o_totalprice) as order_value
    from samples.tpch.orders
    where o_orderdate >= date '${start_date}' and o_orderdate < date '${end_date}'
), report as (
    select sum(order_count) as order_count, sum(order_value) as order_value
    from ${destination}.ca_sales_ext_monthly_order_value
)
select * from original cross join report
where not (original.order_count <=> report.order_count)
   or not (original.order_value <=> report.order_value)
) as failing_rows;
