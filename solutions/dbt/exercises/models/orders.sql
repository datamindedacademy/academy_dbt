select *
from {{ ref('stg_orders') }}
where {{ is_in_reporting_interval('o_orderdate') }}
