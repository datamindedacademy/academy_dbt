-- Optional failure demonstration. First run the normal SQL pipeline.
-- Run this INSERT once. It changes only the published SQL demo table.
insert into workspace.dbt_sql_dataproducts.sa_tpch_ext_customers
select customer_id, customer_name, nation_id
from workspace.dbt_sql_dataproducts.sa_tpch_int_customers
where customer_id = (
    select min(customer_id)
    from workspace.dbt_sql_dataproducts.sa_tpch_int_customers
);

-- Expected: failures = 1 (one duplicate key group).
select 'customers_customer_id_unique' as check_name, count(*) as failures
from (
    select customer_id
    from workspace.dbt_sql_dataproducts.sa_tpch_ext_customers
    group by customer_id
    having count(*) > 1
) as duplicate_keys;

-- Stop here. The source check reports a problem; it does not block later SQL.
-- To recover, rerun run_pipeline.sql from section 1 and inspect all checks.
