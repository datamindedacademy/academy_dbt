WITH total_orders_query AS (
    SELECT c_name, o_custkey, 
        sum(O_TOTALPRICE) as total_spend, 
        count(o_orderkey) as total_orders, 
        div0(total_spend, total_orders) as avg_spent_order
    FROM snowflake_sample_data.tpch_sf1.orders o
    INNER JOIN snowflake_sample_data.tpch_sf1.customer c ON o.o_custkey = c.c_custkey
    GROUP BY o_custkey, c_name
    ORDER BY total_spend DESC), 
avg_discount_query AS(
    select 
        c_custkey, 
        avg(l_discount) as avg_discount, 
        sum(l_discount*l_extendedprice) as total_discount,
        avg(l_discount*l_extendedprice)/sum(l_extendedprice) as weighted_discount
    from snowflake_sample_data.tpch_sf1.lineitem 
    inner join snowflake_sample_data.tpch_sf1.orders on lineitem.l_orderkey = orders.o_orderkey
    inner join snowflake_sample_data.tpch_sf1.customer on orders.o_custkey = customer.c_custkey
    group by c_custkey
    order by avg_discount desc)
    
select * 
from total_orders_query toq 
inner join avg_discount_query adq on toq.o_custkey = adq.c_custkey