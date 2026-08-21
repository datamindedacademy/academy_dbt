# Exercise 7 — Jinja: variables

## Goal

Define project variables in `dbt_project.yml` and use them in a model with
`{{ var(...) }}`.

## Why this matters

Values like a reporting date range shouldn't be hard-coded in five different
models. Variables define them once, and can even be overridden per run from the
command line — which is how the same project serves different environments and
periods.

## Concepts

**Jinja** is a templating language that dbt layers on top of SQL. You have used
it already: `ref()` and `source()` are Jinja. Recognize it by the braces:

- `{{ ... }}` — expressions, printed into the SQL
- `{% ... %}` — statements (if, for, set)
- `{# ... #}` — comments

dbt *compiles* (renders) your templated SQL to plain SQL before running it. The
compiled files land in `target/compiled/` — your best friend when debugging.

**Variables** are defined in `dbt_project.yml`:

```yaml
vars:
  start_date: '2016-06-01'
```

...used in any model, test, or macro as `{{ var('start_date') }}`, and
overridden at run time with `dbt run --vars '{"start_date": "2020-01-01"}'`.

**The datatype trap.** A rendered SQL query is plain text. If `start_date` is
`'1995-01-01'`, then

```sql
WHERE order_date > {{ var("start_date") }}
```

compiles to `WHERE order_date > 1995-01-01` — which SQL reads as the *number*
1995 minus 1 minus 1 = 1993. Comparing a date to an integer fails (or worse,
silently does the wrong thing). Quote it and make it a date:

```sql
WHERE order_date > date '{{ var("start_date") }}'
```

## Exercise

We'll make a report based only on the orders in a given time interval.

1. Add two variables:
   - `report_interval_start`: set it to `'1995-01-01'`
   - `report_interval_end`: set it to `'1995-03-31'`
2. In the `orders` model (create a thin model over the orders staging model if
   you don't have one yet), add a `WHERE` clause which selects only the orders
   in this interval.
3. Run the project with `dbt run`. Check the result.
4. Add a test to check that it worked.

## Tips

- In SQL, the syntax for an interval filter is:

  ```sql
  WHERE date_column
    BETWEEN date '1995-01-01'
    AND date '1995-03-31'
  ```

  (`date '...'` does the same thing as `CAST('...' AS date)`.)
- If things go wrong, check the generated SQL in `target/compiled/`!
- For the test: a singular test selecting the orders *outside* the interval.
- Solution branch: `solutions/vars`.
