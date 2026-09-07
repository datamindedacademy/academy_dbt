select nation_key, revenue
from {{ ref('revenue_per_nation') }}
where revenue < 0
