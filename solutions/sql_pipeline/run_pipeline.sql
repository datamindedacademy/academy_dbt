-- SQL pipeline: run directly in the Databricks SQL editor.
-- Select your SQL warehouse. Run sections in order.
-- Inspect section 3 before section 4. Stop if any failures value exceeds zero.
-- Run all statements repeats the pipeline, but check failures do not stop it automatically.
-- Destination: workspace.dbt_sql_dataproducts. Source: samples.tpch.
-- Period: 1995-01-01 inclusive to 1995-04-01 exclusive.
-- This script replaces eight demo objects. It keeps other objects in the schema.

-- 1. Create the destination schema
create schema if not exists workspace.dbt_sql_dataproducts;

-- 2. Build the source product
create or replace view workspace.dbt_sql_dataproducts.sa_tpch_int_nations as
select cast(n_nationkey as bigint) as nation_id, cast(n_name as string) as nation_name
from samples.tpch.nation;

create or replace view workspace.dbt_sql_dataproducts.sa_tpch_int_customers as
select cast(c_custkey as bigint) as customer_id,
       cast(c_name as string) as customer_name,
       cast(c_nationkey as bigint) as nation_id
from samples.tpch.customer;

create or replace view workspace.dbt_sql_dataproducts.sa_tpch_int_orders as
select cast(o_orderkey as bigint) as order_id,
       cast(o_custkey as bigint) as customer_id,
       cast(o_orderdate as date) as order_date,
       cast(o_orderstatus as string) as order_status,
       cast(o_totalprice as decimal(18, 2)) as order_amount
from samples.tpch.orders;

create or replace table workspace.dbt_sql_dataproducts.sa_tpch_ext_nations using delta as
select nation_id, nation_name from workspace.dbt_sql_dataproducts.sa_tpch_int_nations;

create or replace table workspace.dbt_sql_dataproducts.sa_tpch_ext_customers using delta as
select customer_id, customer_name, nation_id from workspace.dbt_sql_dataproducts.sa_tpch_int_customers;

create or replace table workspace.dbt_sql_dataproducts.sa_tpch_ext_orders using delta as
select order_id, customer_id, order_date, order_status, order_amount
from workspace.dbt_sql_dataproducts.sa_tpch_int_orders;

-- 3. Check the source product: 17 rows, all failures = 0
-- Each row is one check. Every failures value must be zero.
-- These SELECT statements report failures. You decide whether to continue.
select 'nations_nation_id_not_null' as check_name, count(*) as failures
from (
select nation_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_nations where nation_id is null
) as failing_rows
union all
select 'nations_nation_name_not_null' as check_name, count(*) as failures
from (
select nation_name from workspace.dbt_sql_dataproducts.sa_tpch_ext_nations where nation_name is null
) as failing_rows
union all
select 'nations_nation_id_unique' as check_name, count(*) as failures
from (
select nation_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_nations where nation_id is not null group by nation_id having count(*) > 1
) as failing_rows
union all
select 'customers_customer_id_not_null' as check_name, count(*) as failures
from (
select customer_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_customers where customer_id is null
) as failing_rows
union all
select 'customers_customer_name_not_null' as check_name, count(*) as failures
from (
select customer_name from workspace.dbt_sql_dataproducts.sa_tpch_ext_customers where customer_name is null
) as failing_rows
union all
select 'customers_nation_id_not_null' as check_name, count(*) as failures
from (
select nation_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_customers where nation_id is null
) as failing_rows
union all
select 'customers_customer_id_unique' as check_name, count(*) as failures
from (
select customer_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_customers where customer_id is not null group by customer_id having count(*) > 1
) as failing_rows
union all
select 'orders_order_id_not_null' as check_name, count(*) as failures
from (
select order_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where order_id is null
) as failing_rows
union all
select 'orders_customer_id_not_null' as check_name, count(*) as failures
from (
select customer_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where customer_id is null
) as failing_rows
union all
select 'orders_order_date_not_null' as check_name, count(*) as failures
from (
select order_date from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where order_date is null
) as failing_rows
union all
select 'orders_order_status_not_null' as check_name, count(*) as failures
from (
select order_status from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where order_status is null
) as failing_rows
union all
select 'orders_order_amount_not_null' as check_name, count(*) as failures
from (
select order_amount from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where order_amount is null
) as failing_rows
union all
select 'orders_order_id_unique' as check_name, count(*) as failures
from (
select order_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where order_id is not null group by order_id having count(*) > 1
) as failing_rows
union all
select 'customers_nation_exists' as check_name, count(*) as failures
from (
select c.nation_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_customers c
left join workspace.dbt_sql_dataproducts.sa_tpch_ext_nations n on c.nation_id = n.nation_id
where c.nation_id is not null and n.nation_id is null
) as failing_rows
union all
select 'orders_customer_exists' as check_name, count(*) as failures
from (
select o.customer_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders o
left join workspace.dbt_sql_dataproducts.sa_tpch_ext_customers c on o.customer_id = c.customer_id
where o.customer_id is not null and c.customer_id is null
) as failing_rows
union all
select 'order_status_accepted' as check_name, count(*) as failures
from (
select order_status from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where order_status not in ('O', 'P', 'F')
) as failing_rows
union all
select 'order_amount_nonnegative' as check_name, count(*) as failures
from (
select order_id from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders where order_amount < 0
) as failing_rows;

-- 4. Build the consumer product
create or replace view workspace.dbt_sql_dataproducts.ca_sales_int_orders_enriched as
select o.order_id, o.customer_id, n.nation_id, n.nation_name, o.order_date, o.order_amount
from workspace.dbt_sql_dataproducts.sa_tpch_ext_orders as o
join workspace.dbt_sql_dataproducts.sa_tpch_ext_customers as c on o.customer_id = c.customer_id
join workspace.dbt_sql_dataproducts.sa_tpch_ext_nations as n on c.nation_id = n.nation_id
where o.order_date >= date '1995-01-01'
  and o.order_date < date '1995-04-01';

create or replace table workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value using delta as
select nation_id, nation_name,
       cast(date_trunc('MONTH', order_date) as date) as order_month,
       count(*) as order_count,
       count(distinct customer_id) as customer_count,
       cast(sum(order_amount) as decimal(28, 2)) as order_value
from workspace.dbt_sql_dataproducts.ca_sales_int_orders_enriched
group by nation_id, nation_name, cast(date_trunc('MONTH', order_date) as date);

-- 5. Check the consumer product: 9 rows, all failures = 0
select 'report_nation_id_not_null' as check_name, count(*) as failures
from (
select nation_id from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value where nation_id is null
) as failing_rows
union all
select 'report_nation_name_not_null' as check_name, count(*) as failures
from (
select nation_name from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value where nation_name is null
) as failing_rows
union all
select 'report_order_month_not_null' as check_name, count(*) as failures
from (
select order_month from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value where order_month is null
) as failing_rows
union all
select 'report_order_count_not_null' as check_name, count(*) as failures
from (
select order_count from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value where order_count is null
) as failing_rows
union all
select 'report_customer_count_not_null' as check_name, count(*) as failures
from (
select customer_count from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value where customer_count is null
) as failing_rows
union all
select 'report_order_value_not_null' as check_name, count(*) as failures
from (
select order_value from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value where order_value is null
) as failing_rows
union all
select 'country_month_unique' as check_name, count(*) as failures
from (
select nation_id, order_month from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value group by nation_id, order_month having count(*) > 1
) as failing_rows
union all
select 'report_not_empty' as check_name, count(*) as failures
from (
select count(*) from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value having count(*) = 0
) as failing_rows
union all
select 'order_totals_preserved' as check_name, count(*) as failures
from (
with original as (
    select count(*) as order_count, sum(o_totalprice) as order_value
    from samples.tpch.orders
    where o_orderdate >= date '1995-01-01' and o_orderdate < date '1995-04-01'
), report as (
    select sum(order_count) as order_count, sum(order_value) as order_value
    from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value
)
select * from original cross join report
where not (original.order_count <=> report.order_count)
   or not (original.order_value <=> report.order_value)
) as failing_rows;

-- 6. Compare with the original SQL: 1 row, failures = 0
with expected as (
select
    n.n_nationkey as nation_id,
    n.n_name as nation_name,
    cast(date_trunc('MONTH', o.o_orderdate) as date) as order_month,
    count(*) as order_count,
    count(distinct c.c_custkey) as customer_count,
    sum(o.o_totalprice) as order_value
from samples.tpch.orders as o
join samples.tpch.customer as c on o.o_custkey = c.c_custkey
join samples.tpch.nation as n on c.c_nationkey = n.n_nationkey
where o.o_orderdate >= date '1995-01-01'
  and o.o_orderdate < date '1995-04-01'
group by n.n_nationkey, n.n_name, cast(date_trunc('MONTH', o.o_orderdate) as date)
), actual as (
    select nation_id, nation_name, order_month, order_count, customer_count, order_value
    from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value
), missing as (
    select * from expected except all select * from actual
), extra as (
    select * from actual except all select * from expected
)
select 'plain_sql_equivalence' as check_name,
       (select count(*) from missing) + (select count(*) from extra) as failures;

-- 7. Show the report and totals
select *
from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value
order by nation_id, order_month
limit 10;

select count(*) as report_rows,
       sum(order_count) as orders,
       sum(order_value) as order_value
from workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value;
