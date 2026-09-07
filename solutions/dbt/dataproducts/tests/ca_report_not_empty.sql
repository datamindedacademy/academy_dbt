select count(*) as report_rows
from {{ ref('ca_sales_ext_monthly_order_value') }}
having count(*) = 0
