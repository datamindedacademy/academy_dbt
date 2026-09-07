create or replace view ${destination}.sa_tpch_int_nations as
select cast(n_nationkey as bigint) as nation_id, cast(n_name as string) as nation_name
from samples.tpch.nation;
