SELECT * FROM {{ ref('stg_orders') }}
WHERE {{ is_in_reporting_interval('o_orderdate') }}
