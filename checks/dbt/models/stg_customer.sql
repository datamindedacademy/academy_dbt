SELECT * FROM {{ source('tpch', 'customer') }} WHERE c_custkey <= 100
