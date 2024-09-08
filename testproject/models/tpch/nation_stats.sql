select
  n_nationkey,
  nation.n_name as nation,
  min(customer.c_acctbal) as min_balance,
  max(customer.c_acctbal) as max_balance,
  avg(customer.c_acctbal) as avg_balance,

  {% for marketsegment in var("marketsegments") %}
    avg(case when customer.c_mktsegment = '{{ marketsegment }}' then customer.c_acctbal else 0 end) as avg_balance_{{ marketsegment }}
    {% if not loop.last %},{% endif %}
  {% endfor %}
from {{ ref('nation') }} nation
join {{ ref('customer') }} customer on nation.n_nationkey = customer.c_nationkey
group by 1, 2
