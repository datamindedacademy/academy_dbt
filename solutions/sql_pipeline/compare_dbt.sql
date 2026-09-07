-- Run after both pipelines finish with the same reporting dates.
-- Expected: one row, dbt_equivalence, failures = 0.
-- Every output column and duplicate row count is compared in both directions.
with expected as (
select nation_id, nation_name, order_month, order_count, customer_count, order_value
from workspace.dbt_dataproducts.ca_sales_ext_monthly_order_value
), actual as (
    select nation_id, nation_name, order_month, order_count, customer_count, order_value
    from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value
), missing as (
    select * from expected except all select * from actual
), extra as (
    select * from actual except all select * from expected
)
select 'dbt_equivalence' as check_name,
       (select count(*) from missing) + (select count(*) from extra) as failures;
