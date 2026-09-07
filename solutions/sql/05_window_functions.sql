-- Solutions: SQL exercise 5 — Window functions

-- Top-three revenue ranks per nation, as in the supplied reference answers.
-- RANK keeps ties, so a nation can have more than three result rows.
-- Revenue uses full order prices without line-item discounts.
WITH revenue_per_customer AS (
    SELECT
        c.c_custkey,
        c.c_name,
        c.c_nationkey,
        SUM(o.o_totalprice) AS total_revenue
    FROM samples.tpch.customer AS c
    INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_nationkey
),

customer_with_rank AS (
    SELECT
        c_name,
        c_nationkey,
        total_revenue,
        RANK() OVER (
            PARTITION BY c_nationkey
            ORDER BY total_revenue DESC
        ) AS rank_in_nation
    FROM revenue_per_customer
)

SELECT n.n_name, c.c_name, c.c_nationkey, c.total_revenue, c.rank_in_nation
FROM customer_with_rank AS c
INNER JOIN samples.tpch.nation AS n ON c.c_nationkey = n.n_nationkey
WHERE c.rank_in_nation <= 3
ORDER BY n.n_name, c.rank_in_nation, c.c_name;

-- For at most three rows per nation, as explained in the exercise hint:
-- include c_custkey in customer_with_rank and use
-- ROW_NUMBER() OVER (
--     PARTITION BY c_nationkey ORDER BY total_revenue DESC, c_custkey
-- ) AS rank_in_nation
