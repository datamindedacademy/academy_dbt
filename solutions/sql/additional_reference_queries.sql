-- Additional queries from the supplied reference answers.
-- These are separate from the numbered tasks in the current slides.

-- Low-priority orders below 250000 whose status is not F.
-- The supplied SQL omitted the status filter and used <= instead of <.
-- This version follows its written question.
SELECT o_orderkey
FROM samples.tpch.orders
WHERE o_orderpriority = '5-LOW'
  AND o_totalprice < 250000
  AND o_orderstatus <> 'F';

-- Distinct discount percentages.
SELECT DISTINCT l_discount * 100 AS discount_percentage
FROM samples.tpch.lineitem;

-- More than 15 orders above 100000, using a CTE instead of HAVING.
WITH high_paying_customers AS (
    SELECT
        c.c_name AS customer_name,
        COUNT(*) AS num_orders_above_100k
    FROM samples.tpch.customer AS c
    INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
    WHERE o.o_totalprice > 100000
    GROUP BY c.c_custkey, c.c_name
)
SELECT *
FROM high_paying_customers
WHERE num_orders_above_100k > 15;

-- The supplied reference uses Africa. SQL exercise 4 in the slides uses Asia.
WITH african_nations AS (
    SELECT n.n_nationkey, n.n_name
    FROM samples.tpch.nation AS n
    INNER JOIN samples.tpch.region AS r ON n.n_regionkey = r.r_regionkey
    WHERE r.r_name = 'AFRICA'
)
SELECT
    n.n_name AS nation,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM samples.tpch.lineitem AS l
INNER JOIN samples.tpch.orders AS o ON l.l_orderkey = o.o_orderkey
INNER JOIN samples.tpch.customer AS c ON o.o_custkey = c.c_custkey
INNER JOIN samples.tpch.supplier AS s ON l.l_suppkey = s.s_suppkey
INNER JOIN african_nations AS n ON c.c_nationkey = n.n_nationkey
WHERE c.c_nationkey = s.s_nationkey
GROUP BY n.n_nationkey, n.n_name
ORDER BY total_revenue DESC;
