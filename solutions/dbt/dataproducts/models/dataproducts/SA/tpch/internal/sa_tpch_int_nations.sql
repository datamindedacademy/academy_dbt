select
    cast(n_nationkey as bigint) as nation_id,
    cast(n_name as string) as nation_name
from {{ source('tpch', 'nation') }}
