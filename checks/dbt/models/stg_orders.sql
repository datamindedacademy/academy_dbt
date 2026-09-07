SELECT * FROM {{ source('tpch', 'orders') }} WHERE o_custkey <= 100
