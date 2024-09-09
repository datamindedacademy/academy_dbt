select *
from {{ ref("customer_stats") }}
where total_amount_spent < 0
