# Exercise 5 — Window functions

## Goal

Use a window function (`RANK() OVER (...)`) to compute a value that depends on
*other* rows, and combine it with a CTE to filter on the result.

## Why this matters

Some questions cannot be answered by plain aggregation: "top 3 per group",
"running total", "difference with the previous row". Aggregation collapses rows;
window functions keep every row and add context *about* the surrounding rows.

## Concepts

A window function calculates something about a set of related rows (the
"window") while keeping each individual row. You recognize it by the keyword
`OVER`:

```sql
SELECT
    game,
    player,
    score,
    RANK() OVER (
        PARTITION BY game        -- restart the ranking for each game
        ORDER BY score DESC      -- highest score gets rank 1
    ) AS rank
FROM highscores;
```

- `PARTITION BY` splits the rows into groups (like `GROUP BY`, but without
  collapsing them).
- `ORDER BY` inside `OVER` defines the ranking order within each group.

Typical uses: rankings, running sums, difference with the previous row.

One catch: you cannot put a window function in a `WHERE` clause (it is computed
too late — see the evaluation order in exercise 3). The standard trick: compute
the rank in a CTE, then filter on it in the next step.

## Exercise

For each nation, show me our top-3 highest-revenue customers in that nation.

> Tip: first calculate each customer's rank within their nation, then make that
> a CTE and filter on it.

## Tips

- "Revenue of a customer" here: the sum of `o_totalprice` over their orders.
  Compute it with a `GROUP BY` first (in its own CTE).
- Then rank with `RANK() OVER (PARTITION BY nation ORDER BY revenue DESC)`.
- Then `WHERE rank <= 3` in the final select.
