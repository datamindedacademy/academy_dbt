select *
from {{ source("tpch", "orders") }}
where o_orderdate
    between date '{{ var("report_interval_start") }}'
    and date '{{ var("report_interval_end") }}'
