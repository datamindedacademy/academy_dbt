select nation_id, nation_name
from {{ ref('sa_tpch_int_nations') }}
