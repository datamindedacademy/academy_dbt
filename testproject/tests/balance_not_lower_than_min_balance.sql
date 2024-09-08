select
  *
from {{ ref("customer") }} customer
join {{ ref("nation_stats") }} nation
  on customer.c_nationkey = nation.n_nationkey
where customer.c_acctbal < nation.min_balance
  or customer.c_acctbal > nation.max_balance
