create or replace view ${destination}.sa_tpch_int_customers as
with customers as (
    select cast(c_custkey as bigint) as customer_id,
           cast(c_name as string) as customer_name,
           cast(c_nationkey as bigint) as nation_id
    from samples.tpch.customer
)
select customer_id, customer_name, nation_id from customers
union all
select customer_id, customer_name, nation_id from customers
where ${inject_duplicate_customer}
  and customer_id = (select min(customer_id) from customers);
