# SQL exercises

Open the Databricks **SQL editor** and select your SQL warehouse.
Run this in each new query tab:

```sql
USE CATALOG samples;
USE SCHEMA tpch;
SELECT * FROM tpch.customer LIMIT 5;
```

You can also use full names such as `samples.tpch.customer`.
For the Postgres backup, use SQLTools and `tpch.customer` without the `samples` catalog.

## Source tables

| Table | Contents | Column prefix |
|---|---|---|
| `customer` | Customers | `c_` |
| `orders` | Customer orders | `o_` |
| `lineitem` | Order lines | `l_` |
| `part` | Products | `p_` |
| `supplier` | Suppliers | `s_` |
| `partsupp` | Parts available from each supplier | `ps_` |
| `nation` | Countries | `n_` |
| `region` | Regions | `r_` |

For example, `orders.o_custkey` refers to `customer.c_custkey`.

| Exercise | Topic |
|---|---|
| [1](01_select_and_filter/) | Select and filter |
| [2](02_joins/) | Join tables |
| [3](03_group_by_and_aggregations/) | Aggregate results |
| [4](04_ctes/) | Common table expressions |
| [5](05_window_functions/) | Window functions |
