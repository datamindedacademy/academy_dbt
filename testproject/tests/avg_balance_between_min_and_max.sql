with min_and_max_balance as (
    select
        c_nationkey,
        min(c_acctbal) as min_balance,
        max(c_acctbal) as max_balance
    from {{ ref("customer") }}
    group by c_nationkey
)
select
  *
from min_and_max_balance
join {{ ref("nation_stats") }}
  on min_and_max_balance.c_nationkey = nation_stats.n_nationkey
where min_and_max_balance.min_balance > nation_stats.avg_balance
  or min_and_max_balance.max_balance < nation_stats.avg_balance
