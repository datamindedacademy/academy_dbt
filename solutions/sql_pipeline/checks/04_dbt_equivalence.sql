with expected as (
select nation_id, nation_name, order_month, order_count, customer_count, order_value
from ${dbt_destination}.ca_sales_ext_monthly_order_value
), actual as (
    select nation_id, nation_name, order_month, order_count, customer_count, order_value
    from ${destination}.ca_sales_ext_monthly_order_value
), missing as (
    select * from expected except all select * from actual
), extra as (
    select * from actual except all select * from expected
)
select 'dbt_equivalence' as check_name,
       (select count(*) from missing) + (select count(*) from extra) as failures;
