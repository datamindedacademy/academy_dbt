-- Solutions: SQL exercise 4 — Common Table Expressions (CTEs)

-- Total revenue per country in Asia from locally supplied orders.
-- "Locally supplied": the customer and the supplier are in the same nation.
-- Revenue = SUM(l_extendedprice * (1 - l_discount)).
WITH asian_nations AS (
    SELECT n.n_nationkey, n.n_name
    FROM samples.tpch.nation AS n
    INNER JOIN samples.tpch.region AS r ON n.n_regionkey = r.r_regionkey
    WHERE r.r_name = 'ASIA'
),

local_transactions AS (
    SELECT
        an.n_name AS nation,
        l.l_extendedprice * (1 - l.l_discount) AS revenue
    FROM samples.tpch.lineitem AS l
    INNER JOIN samples.tpch.orders   AS o ON o.o_orderkey = l.l_orderkey
    INNER JOIN samples.tpch.customer AS c ON c.c_custkey  = o.o_custkey
    INNER JOIN samples.tpch.supplier AS s ON s.s_suppkey  = l.l_suppkey
    INNER JOIN asian_nations AS an ON an.n_nationkey = c.c_nationkey
    WHERE c.c_nationkey = s.s_nationkey   -- customer and supplier in the same nation
)

SELECT nation, SUM(revenue) AS total_revenue
FROM local_transactions
GROUP BY nation
ORDER BY total_revenue DESC;
