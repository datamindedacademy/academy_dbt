# Exercise 9 — Macros and packages

## Goal

Write a reusable macro and use it in a model; know where to find community
packages so you don't reinvent the wheel.

## Why this matters

A for loop removes repetition *within* one model. A **macro** removes repetition
*across* models: it is the dbt equivalent of a function. And whatever generic
problem you're solving, someone probably already packaged a macro for it.

## Concepts

**Macros** are defined in `.sql` files in the `macros/` folder:

```sql
{% macro cents_to_dollars(column_name) %}
    ({{ column_name }} / 100)::numeric(16, 2)
{% endmacro %}
```

...and called from any model:

```sql
select
  id,
  {{ cents_to_dollars('amount_cents') }} as amount_dollars
from {{ ref('raw_payments') }}
```

The macro's output is pasted into the SQL at compile time — check
`target/compiled/` to see the result.

Fun fact: the generic tests from exercise 5 (`unique`, `not_null`, ...) are
themselves macros — you can write your own with `{% test my_test(...) %}`.

**Packages** let you reuse other people's macros and tests. Declare them in
`packages.yml` (next to `dbt_project.yml`) and run `dbt deps` to install:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0
```

Packages worth knowing: `dbt_utils` (must-have utilities),
`dbt_expectations` (many extra generic tests), `codegen` (generates dbt
boilerplate), `dbt_project_evaluator` (audits your project against best
practices). Browse them all at https://hub.getdbt.com/.

## Exercise

1. Add a macro `is_in_reporting_interval(date_column)` which checks whether a
   column is between the variables `report_interval_start` and
   `report_interval_end` (from exercise 7).
2. Use it in `customer_stats` (or in the `orders` model where you added the
   `WHERE` clause in exercise 7 — replace the hand-written condition).
3. *(Optional, advanced)* Install `dbt_utils` and use
   `dbt_utils.get_column_values()` to fetch the list of order statuses for the
   for loop of exercise 8, instead of hard-coding `['O', 'P', 'F']`.

## Tips

- The macro should render to a boolean SQL expression, so it can be used as
  `WHERE {{ is_in_reporting_interval('o_orderdate') }}`.
- Inside a macro you can still use `{{ var(...) }}`.
- For the optional part: `get_column_values` queries the database at compile
  time, so the referenced model must already be materialized (run it first).
- Solution branch: `solutions/macros`.
