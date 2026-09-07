# Exercise 4 — Generating documentation

## Goal

Generate and browse a documentation website for your dbt project, including the
lineage graph (DAG), and add descriptions to a model.

## Why this matters

Documentation usually goes stale because it lives far away from the code. In dbt
it lives *next to* the code (in the same `.yml` files), and the website —
including the full lineage graph — is generated from the project itself. Free,
always up-to-date documentation is one of dbt's biggest selling points.

## Concepts

Two commands:

- `dbt docs generate` — compiles information about your project and the
  warehouse into `manifest.json` and `catalog.json`. Run `dbt run` first!
- `dbt docs serve` — serves those files as a local website.

Descriptions for models and columns go in the schema config file:

```yaml
models:
  - name: customer_stats
    description: "One row per customer with lifetime statistics."
    columns:
      - name: total_spent
        description: "Sum of the total price of all the customer's orders."
```

The docs site also visualizes your **DAG**: the dependency graph derived from
the `ref()` and `source()` calls you wrote in exercise 2. Sources show up as
green nodes.

## Exercise

In the dbt project you created:

1. Run `dbt docs generate`.
2. Run `dbt docs serve`.
3. Check out the result. Find `customer_stats` and open its **lineage graph**.
   Does it match what you expect: source → staging → stats?
4. *(Optional)* Add documentation (a model description and column descriptions)
   for the `customer_stats` model and recreate the docs site.

## Tips

- In a codespace, the docs site is on a forwarded port: check the **Ports** tab
  and open the URL for port 8080.
- Stop the docs server with `Ctrl-C` when you're done.
