-- Solutions: SQL exercise 2 — Joining tables

-- 1. All the customer names, together with their nation
SELECT c.c_name, n.n_name AS nation
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.nation AS n ON c.c_nationkey = n.n_nationkey;

-- 2. All the customer names, with their nation and its continent (= region)
SELECT c.c_name, n.n_name AS nation, r.r_name AS region
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.nation AS n ON c.c_nationkey = n.n_nationkey
INNER JOIN samples.tpch.region AS r ON n.n_regionkey = r.r_regionkey;

-- 3. All the unique customer names that bought a product with a discount
--    higher than 9%
SELECT DISTINCT c.c_name
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
INNER JOIN samples.tpch.lineitem AS l ON l.l_orderkey = o.o_orderkey
WHERE l.l_discount > 0.09;

-- 4. All customers that have never placed an order
SELECT c.c_name
FROM samples.tpch.customer AS c
LEFT JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
WHERE o.o_orderkey IS NULL;

-- 5. All unique African supplier names that supply parts of brand 'Brand#43'
SELECT DISTINCT s.s_name
FROM samples.tpch.region AS r
INNER JOIN samples.tpch.nation AS n ON n.n_regionkey = r.r_regionkey
INNER JOIN samples.tpch.supplier AS s ON s.s_nationkey = n.n_nationkey
INNER JOIN samples.tpch.partsupp AS ps ON ps.ps_suppkey = s.s_suppkey
INNER JOIN samples.tpch.part AS p ON p.p_partkey = ps.ps_partkey
WHERE r.r_name = 'AFRICA'
  AND p.p_brand = 'Brand#43';
