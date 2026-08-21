-- Solutions: SQL exercise 3 — Group by and aggregations

-- 1. The highest total price of any order we've ever received
SELECT MAX(o_totalprice) AS highest_total_price
FROM samples.tpch.orders;

-- 2. How many customers do we have from Germany?
SELECT COUNT(*) AS num_german_customers
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.nation AS n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'GERMANY';

-- 3. The average total order price for orders from German customers
SELECT AVG(o.o_totalprice) AS avg_order_price
FROM samples.tpch.orders AS o
INNER JOIN samples.tpch.customer AS c ON o.o_custkey = c.c_custkey
INNER JOIN samples.tpch.nation AS n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'GERMANY';

-- 4. The amount of customers per country, most customers first
SELECT n.n_name AS nation, COUNT(*) AS num_customers
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.nation AS n ON c.c_nationkey = n.n_nationkey
GROUP BY n.n_name
ORDER BY num_customers DESC;

-- 5. Total and average amount spent per customer, best customers first
SELECT
    c.c_name,
    SUM(o.o_totalprice) AS total_spent,
    AVG(o.o_totalprice) AS avg_spent
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
GROUP BY c.c_name
ORDER BY total_spent DESC;

-- 6. All the customers that have placed more than 25 orders
SELECT c.c_name, COUNT(*) AS num_orders
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
GROUP BY c.c_name
HAVING COUNT(*) > 25;

-- 7. The customers that have placed more than 15 orders above 100 000 euros
SELECT c.c_name, COUNT(*) AS num_big_orders
FROM samples.tpch.customer AS c
INNER JOIN samples.tpch.orders AS o ON o.o_custkey = c.c_custkey
WHERE o.o_totalprice > 100000        -- filters individual orders
GROUP BY c.c_name
HAVING COUNT(*) > 15;                -- filters customer groups
