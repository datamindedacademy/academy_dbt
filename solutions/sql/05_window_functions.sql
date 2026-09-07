-- Solutions: SQL exercise 5 — Window functions

-- For each nation: our top-3 highest-revenue customers in that nation.
-- Step 1: revenue per customer. Step 2: rank within the nation.
-- Step 3: filter on the rank (a window function cannot go in WHERE).
WITH customer_revenue AS (
    SELECT
        n.n_name AS nation,
        c.c_name AS customer,
        SUM(o.o_totalprice) AS revenue
    FROM samples.tpch.customer AS c
    INNER JOIN samples.tpch.nation AS n ON c.c_nationkey = n.n_nationkey
    INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
    GROUP BY n.n_name, c.c_name
),

ranked AS (
    SELECT
        nation,
        customer,
        revenue,
        RANK() OVER (
            PARTITION BY nation
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

SELECT nation, customer, revenue, revenue_rank
FROM ranked
WHERE revenue_rank <= 3
ORDER BY nation, revenue_rank;
