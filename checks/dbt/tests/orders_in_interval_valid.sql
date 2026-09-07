SELECT * FROM {{ ref('orders_in_interval') }}
WHERE NOT ({{ is_in_reporting_interval('o_orderdate') }})
