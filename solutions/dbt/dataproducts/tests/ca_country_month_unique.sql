select nation_id, order_month, count(*) as row_count
from {{ ref('ca_sales_ext_monthly_order_value') }}
group by nation_id, order_month
having count(*) > 1
