select * 
from {{ ref('total_orders')}} toq
inner join {{ ref('avg_discount')}} adq on toq.o_custkey = adq.c_custkey