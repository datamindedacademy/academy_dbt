# dbt exercise 7: Filter orders with date variables

Use project variables to select orders in a report interval.

1. Add this to `dbt_project.yml`:

   ```yaml
   vars:
     report_interval_start: '1995-01-01'
     report_interval_end: '1995-03-31'
   ```

2. Create `models/orders.sql`. Read `stg_orders` with `ref()`.
3. Filter `o_orderdate` between both variables. Include both boundary dates.
4. Run `dbt run`. Inspect the order dates and the SQL in `target/compiled/`.
5. Add a singular test that returns orders outside the interval. Run `dbt test`.

Quote each rendered variable as a SQL date:

```sql
date '{{ var("report_interval_start") }}'
```
