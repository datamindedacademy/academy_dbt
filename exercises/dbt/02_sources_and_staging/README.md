# dbt exercise 2: Declare sources and build models

Build `customer_stats` from the customer and orders source tables.

1. Create `models/sources.yml`:

   ```yaml
   version: 2
   sources:
     - name: tpch
       database: samples
       schema: tpch
       tables:
         - name: customer
         - name: orders
   ```

2. Create `models/stg_customer.sql`:

   ```sql
   select * from {{ source('tpch', 'customer') }}
   ```

3. Create `models/stg_orders.sql` with the same pattern for `orders`.
4. Create `models/customer_stats.sql`. Join both staging models with `ref()`.
5. Return one row per `c_custkey`. Name `sum(o_totalprice)` as `total_spent`.
6. Run `dbt run`. Inspect `workspace.dbt.customer_stats`.

Use a left join from customers to orders to retain customers without orders.
Match `c_custkey` to `o_custkey`.
On Databricks, `database` means catalog. For the Postgres backup, use `database: postgres`.
