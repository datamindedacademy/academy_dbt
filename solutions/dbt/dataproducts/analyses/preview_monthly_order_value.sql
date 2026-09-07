select nation_id, nation_name, order_month, order_count, customer_count, order_value
from {{ ref('ca_sales_ext_monthly_order_value') }}
order by nation_id, order_month
