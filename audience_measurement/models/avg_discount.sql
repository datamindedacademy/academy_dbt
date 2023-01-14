select 
        c_custkey, 
        avg(l_discount) as avg_discount, 
        sum(l_discount*l_extendedprice) as total_discount,
        avg(l_discount*l_extendedprice)/sum(l_extendedprice) as weighted_discount
    from snowflake_sample_data.tpch_sf1.lineitem 
    inner join snowflake_sample_data.tpch_sf1.orders on lineitem.l_orderkey = orders.o_orderkey
    inner join snowflake_sample_data.tpch_sf1.customer on orders.o_custkey = customer.c_custkey
    group by c_custkey
    order by avg_discount desc