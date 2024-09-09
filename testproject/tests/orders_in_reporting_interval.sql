select *
from {{ ref("orders") }}
where o_orderdate < date '{{ var("report_interval_start")}}'
or o_orderdate > date '{{ var("report_interval_end")}}'
