# Exercise 2 — Sources, staging models, and the DAG

## Goal

Declare the raw TPC-H tables as *sources*, build staging models on top of them
with `source()`, and build a downstream model with `ref()`.

## Why this matters

dbt's superpower is *modularity*: build the final result piece by piece instead
of in one giant query. For that, dbt must know how your models depend on each
other. The `ref()` and `source()` functions create those links, and from them dbt
derives a **DAG** (Directed Acyclic Graph) — so it always runs everything in the
right order, and can even parallelize.

## Concepts

**Sources** represent raw data that already exists in the warehouse (dbt only
does the "T" — the data was Extracted and Loaded by something else). You declare
them once in a `.yml` file inside `models/`:

```yaml
sources:
  - name: tpch
    database: postgres
    schema: tpch
    tables:
      - name: customer
      - name: orders
```

The same TPC-H tables live in a different place on each backend: the catalog
`samples` on Databricks, and `snowflake_sample_data.tpch_sf1` on Snowflake. To
make one project run on all three, let dbt choose:

```yaml
    database: "{{ {'databricks': 'samples', 'snowflake': 'snowflake_sample_data'}.get(target.type, 'postgres') }}"
    schema: "{{ 'tpch_sf1' if target.type == 'snowflake' else 'tpch' }}"
```

**Referring to data.** In a model, never hard-code table names:

- `{{ source('tpch', 'customer') }}` — read from a declared source table
- `{{ ref('stg_customer') }}` — read from another dbt model

Both compile to the real table name *and* register a dependency edge in the DAG.
If a raw table moves or gets renamed, you update one `.yml` file instead of
every query.

**Staging models** (by convention prefixed `stg_`) are thin, clean wrappers
around sources — the first layer of every dbt project:

```sql
-- models/stg_customer.sql
SELECT * FROM {{ source('tpch', 'customer') }}
```

## Exercise

In the dbt project you created in exercise 1:

1. Modify the `schema.yml` file: add a source named `tpch` which refers to
   database `postgres`, schema `tpch`.
2. Add at least the tables `customer` and `orders` to this source.
3. Add 2 models: `stg_customer.sql` and `stg_orders.sql` that select all
   columns from their respective source.
4. Add a model `customer_stats.sql` which gives for each customer (`custkey`)
   the total amount spent (= sum of prices of all their orders).
5. *(Optional)* Calculate more customer statistics.

Run `dbt run` and check the resulting tables/views in the database.

## Tips

- `customer_stats` must read from the *staging models* with `ref()`, not from
  the sources directly. That's the layering habit that pays off later.
- The amount spent per customer is a `GROUP BY` on the orders — you wrote almost
  this exact query in SQL exercise 3.
- Solution branch: `solutions/exercise_2`.
