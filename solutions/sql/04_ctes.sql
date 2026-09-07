-- Solutions: SQL exercise 4 — Common Table Expressions (CTEs)

-- • This query calculates revenue for each Asian country from purchases where the customer and supplier share
--   that country.

--   It has three steps:

--   1. Find Asian countries.
--      asian_nations lists countries whose region is ASIA.

--   2. Find purchases within the same country.
--      local_transactions connects each order line to its order, customer, and supplier.
--      It keeps Asian customers whose supplier belongs to the same country.
--      A Chinese customer with a Chinese supplier qualifies. A Chinese customer with an Indian supplier does
--      not.
--      It calculates each line’s revenue after the discount.
--      For example, 100 × (1 − 0.10) gives 90.

--   3. Add the revenue per country.
--      The final query adds those amounts and lists countries from highest revenue to lowest.

--   The two named sections are common table expressions (CTEs). They name intermediate query results within this
--   SQL statement.


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



-- • This query calculates revenue for each Asian country from purchases where the customer and supplier share
--   that country.

--   It has three steps:

--   1. Find Asian countries.
--      asian_nations lists countries whose region is ASIA.

--   2. Find purchases within the same country.
--      local_transactions connects each order line to its order, customer, and supplier.
--      It keeps Asian customers whose supplier belongs to the same country.
--      A Chinese customer with a Chinese supplier qualifies. A Chinese customer with an Indian supplier does
--      not.
--      It calculates each line’s revenue after the discount.
--      For example, 100 × (1 − 0.10) gives 90.

--   3. Add the revenue per country.
--      The final query adds those amounts and lists countries from highest revenue to lowest.

--   The two named sections are common table expressions (CTEs). They name intermediate query results within this
--   SQL statement.