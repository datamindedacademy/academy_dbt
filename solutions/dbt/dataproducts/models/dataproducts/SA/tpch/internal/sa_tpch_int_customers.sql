with customers as (
    select
        cast(c_custkey as bigint) as customer_id,
        cast(c_name as string) as customer_name,
        cast(c_nationkey as bigint) as nation_id
    from {{ source('tpch', 'customer') }}
)

select customer_id, customer_name, nation_id
from customers

{% if var('inject_duplicate_customer', false) %}
-- Optional failure demonstration. The sample source remains unchanged.
union all
select customer_id, customer_name, nation_id
from customers
where customer_id = (select min(customer_id) from customers)
{% endif %}
