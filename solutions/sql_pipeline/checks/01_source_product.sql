-- Each row is one check. A nonzero failure count stops the runner.
select 'nations_nation_id_not_null' as check_name, count(*) as failures
from (
select nation_id from ${destination}.sa_tpch_ext_nations where nation_id is null
) as failing_rows
union all
select 'nations_nation_name_not_null' as check_name, count(*) as failures
from (
select nation_name from ${destination}.sa_tpch_ext_nations where nation_name is null
) as failing_rows
union all
select 'nations_nation_id_unique' as check_name, count(*) as failures
from (
select nation_id from ${destination}.sa_tpch_ext_nations where nation_id is not null group by nation_id having count(*) > 1
) as failing_rows
union all
select 'customers_customer_id_not_null' as check_name, count(*) as failures
from (
select customer_id from ${destination}.sa_tpch_ext_customers where customer_id is null
) as failing_rows
union all
select 'customers_customer_name_not_null' as check_name, count(*) as failures
from (
select customer_name from ${destination}.sa_tpch_ext_customers where customer_name is null
) as failing_rows
union all
select 'customers_nation_id_not_null' as check_name, count(*) as failures
from (
select nation_id from ${destination}.sa_tpch_ext_customers where nation_id is null
) as failing_rows
union all
select 'customers_customer_id_unique' as check_name, count(*) as failures
from (
select customer_id from ${destination}.sa_tpch_ext_customers where customer_id is not null group by customer_id having count(*) > 1
) as failing_rows
union all
select 'orders_order_id_not_null' as check_name, count(*) as failures
from (
select order_id from ${destination}.sa_tpch_ext_orders where order_id is null
) as failing_rows
union all
select 'orders_customer_id_not_null' as check_name, count(*) as failures
from (
select customer_id from ${destination}.sa_tpch_ext_orders where customer_id is null
) as failing_rows
union all
select 'orders_order_date_not_null' as check_name, count(*) as failures
from (
select order_date from ${destination}.sa_tpch_ext_orders where order_date is null
) as failing_rows
union all
select 'orders_order_status_not_null' as check_name, count(*) as failures
from (
select order_status from ${destination}.sa_tpch_ext_orders where order_status is null
) as failing_rows
union all
select 'orders_order_amount_not_null' as check_name, count(*) as failures
from (
select order_amount from ${destination}.sa_tpch_ext_orders where order_amount is null
) as failing_rows
union all
select 'orders_order_id_unique' as check_name, count(*) as failures
from (
select order_id from ${destination}.sa_tpch_ext_orders where order_id is not null group by order_id having count(*) > 1
) as failing_rows
union all
select 'customers_nation_exists' as check_name, count(*) as failures
from (
select c.nation_id from ${destination}.sa_tpch_ext_customers c
left join ${destination}.sa_tpch_ext_nations n on c.nation_id = n.nation_id
where c.nation_id is not null and n.nation_id is null
) as failing_rows
union all
select 'orders_customer_exists' as check_name, count(*) as failures
from (
select o.customer_id from ${destination}.sa_tpch_ext_orders o
left join ${destination}.sa_tpch_ext_customers c on o.customer_id = c.customer_id
where o.customer_id is not null and c.customer_id is null
) as failing_rows
union all
select 'order_status_accepted' as check_name, count(*) as failures
from (
select order_status from ${destination}.sa_tpch_ext_orders where order_status not in ('O', 'P', 'F')
) as failing_rows
union all
select 'order_amount_nonnegative' as check_name, count(*) as failures
from (
select order_id from ${destination}.sa_tpch_ext_orders where order_amount < 0
) as failing_rows;
