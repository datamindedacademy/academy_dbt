# SQL exercise 5: Rank customers within each nation

Return the three customers with the highest total order value in each nation.

1. Sum `o_totalprice` per customer. Include the customer name and nation.
2. Rank customers within their nation, with the highest total first.
3. Put the rank calculation in a CTE. Select ranks 1 to 3.

Use `row_number() over (partition by ... order by ...)` for at most three rows per nation.
Use a stable tie-breaker, such as the customer key. `rank()` can include more rows when customers tie.
