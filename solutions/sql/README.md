# SQL exercise answers

Files 01–05 follow the current exercise tasks and the Databricks slides.
Use `samples.tpch` in Databricks. The supplied reference uses the shorter `tpch` prefix.
Select one query at a time in the SQL editor.

## Alignment with the supplied reference

| Exercise | Alignment |
|---|---|
| 1 | Uses the supplied CASE expression for priority multiplication. The short form is equivalent for the five TPC-H priorities. |
| 2 | Uses the same joins and filters. The no-orders query returns the customer fields and the unmatched order fields. |
| 3 | Uses a left join for customer spending. Customers without orders have total 0 and average NULL. |
| 4 | The slides use Asia; the supplied reference uses Africa. The numbered answer keeps Asia. |
| 5 | Uses RANK, as in both supplied alternatives. Equal revenue gets equal rank and can produce more than three rows. |

The `ROW_NUMBER` alternative in exercise 5 gives at most three rows per nation.
This is a different tie policy from the supplied `RANK` answers.

[Additional reference queries](additional_reference_queries.sql) include the low-priority filter, discount percentages, CTE alternative, and Africa variant.
These do not add tasks to the current slides.
The supplied low-priority query omits its stated status condition and uses `<=` for “below”.
The additional answer uses `< 250000` and `o_orderstatus <> 'F'` to match the written question.

Column aliases and result order can differ from the supplied examples without changing the selected data.
The data-product demonstration remains in [06_data_products.sql](06_data_products.sql).
