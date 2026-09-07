-- Solutions: SQL exercise 1 — Selecting and filtering rows

-- 1. All the customers where the marketing segment is 'MACHINERY'
SELECT *
FROM samples.tpch.customer
WHERE c_mktsegment = 'MACHINERY';

-- 2. All the orders with priority '3-MEDIUM', total price above 100 000,
--    and status not 'F'
SELECT *
FROM samples.tpch.orders
WHERE o_orderpriority = '3-MEDIUM'
  AND o_totalprice > 100000
  AND o_orderstatus <> 'F';

-- 3. Which order priority levels do we use?
SELECT DISTINCT o_orderpriority
FROM samples.tpch.orders;

-- 4. For each order: the order key and the total price multiplied by the
--    order's priority (the leading digit of o_orderpriority)
SELECT
    o_orderkey,
    CASE
        WHEN o_orderpriority = '1-URGENT' THEN 1 * o_totalprice
        WHEN o_orderpriority = '2-HIGH' THEN 2 * o_totalprice
        WHEN o_orderpriority = '3-MEDIUM' THEN 3 * o_totalprice
        WHEN o_orderpriority = '4-NOT SPECIFIED' THEN 4 * o_totalprice
        WHEN o_orderpriority = '5-LOW' THEN 5 * o_totalprice
    END AS mult_price
FROM samples.tpch.orders;

-- Short alternative for the five TPC-H priorities:
-- o_totalprice * CAST(LEFT(o_orderpriority, 1) AS INT) AS mult_price

-- 5. All the orders where the order comment contains the word "express"
SELECT *
FROM samples.tpch.orders
WHERE o_comment LIKE '%express%';
