select *
from {{ source("tpch", "orders") }}
where {{ is_in_reporting_interval("o_orderdate") }}
