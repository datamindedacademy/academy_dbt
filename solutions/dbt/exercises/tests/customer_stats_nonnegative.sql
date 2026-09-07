select c_custkey, total_spent
from {{ ref('customer_stats') }}
where total_spent < 0
