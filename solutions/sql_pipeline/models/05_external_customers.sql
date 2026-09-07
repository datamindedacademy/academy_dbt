create or replace table ${destination}.sa_tpch_ext_customers using delta as
select customer_id, customer_name, nation_id from ${destination}.sa_tpch_int_customers;
