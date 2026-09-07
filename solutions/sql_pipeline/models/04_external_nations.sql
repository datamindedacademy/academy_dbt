create or replace table ${destination}.sa_tpch_ext_nations using delta as
select nation_id, nation_name from ${destination}.sa_tpch_int_nations;
