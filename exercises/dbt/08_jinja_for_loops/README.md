# dbt exercise 8: Generate status counts with a loop

Extend `customer_stats` with these columns:

| Column | Count |
|---|---|
| `num_orders_with_status_o` | Orders where `o_orderstatus = 'O'` |
| `num_orders_with_status_p` | Orders where `o_orderstatus = 'P'` |
| `num_orders_with_status_f` | Orders where `o_orderstatus = 'F'` |

1. Use a Jinja for loop to generate the three expressions.
2. Run `dbt run`. Inspect the new columns and the SQL in `target/compiled/`.
3. Optional: define the list as an `order_statuses` project variable.

Use `sum(case when ... then 1 else 0 end)` to count matching orders.
Use `loop.last` if you need to omit the final comma.
