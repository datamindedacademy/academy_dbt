SELECT c_custkey FROM {{ ref('customer_stats') }} WHERE total_spent < 0
UNION ALL
SELECT 0 FROM {{ ref('customer_stats') }} HAVING COUNT(*) = 0
