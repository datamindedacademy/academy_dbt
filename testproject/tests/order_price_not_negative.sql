select *
from {{ ref("orders") }}
where o_totalprice < 0
