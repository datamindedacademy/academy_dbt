 SELECT c_name, o_custkey, 
        sum(O_TOTALPRICE) as total_spend, 
        count(o_orderkey) as total_orders, 
        div0(total_spend, total_orders) as avg_spent_order
    FROM snowflake_sample_data.tpch_sf1.orders o
    INNER JOIN snowflake_sample_data.tpch_sf1.customer c ON o.o_custkey = c.c_custkey
    GROUP BY o_custkey, c_name
    ORDER BY total_spend DESC