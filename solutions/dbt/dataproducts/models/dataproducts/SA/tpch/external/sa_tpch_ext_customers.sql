select customer_id, customer_name, nation_id
from {{ ref('sa_tpch_int_customers') }}
