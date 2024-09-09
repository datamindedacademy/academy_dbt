select count(*) num_rows
from {{ ref("customer_stats") }}
having num_rows = 0
