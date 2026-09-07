# Run the TPC-H data products

This complete project builds two data products on Databricks.
Run the supplied models and inspect their output. No exercise edits are required.

## Build and view the report

Complete [Databricks setup](../../../docs/setup_instructions.md) first.
Use the course container, or activate the local environment described below.
Run these commands from the repository root:

```bash
./create_profiles.sh --target databricks
cd solutions/dbt/dataproducts
dbt debug
dbt build
dbt show --select preview_monthly_order_value --limit 10
```
The profile script discovers this project's `academy_dataproducts` profile automatically.
The build creates eight models and runs 27 data tests and one unit test.
No package download or source data upload is required.

In VS Code, run the commands above in the terminal.

With the default `.env`, the output schema is `workspace.dbt_dataproducts`.
dbt adds `_dataproducts` to your configured output schema.
The source data stays in `samples.tpch`.

To see the complete output, run this query in the Databricks SQL editor or SQLTools:

```sql
select *
from workspace.dbt_dataproducts.ca_sales_ext_monthly_order_value
order by nation_id, order_month;
```

Change the catalog and schema in this query if your `.env` uses other values.
The result has one row per country and month for January through March 1995.
The customer determines the country. The report includes all order statuses.
`order_value` means the sum of order amounts. The dataset does not specify a currency.

The live Databricks check on 7 September 2026 returns 75 report rows and 280,721 orders.
The total order value is `42,417,781,915.94`.
The first three rows are:

| Country | Month | Orders | Customers | Order value |
|---|---|---:|---:|---:|
| ALGERIA | 1995-01-01 | 3,848 | 3,446 | 585,285,977.52 |
| ALGERIA | 1995-02-01 | 3,552 | 3,197 | 529,899,522.47 |
| ALGERIA | 1995-03-01 | 3,866 | 3,515 | 592,605,229.77 |

| Column | Meaning |
|---|---|
| `nation_id`, `nation_name` | The customer's country |
| `order_month` | The first day of the order month |
| `order_count` | The number of orders |
| `customer_count` | The number of distinct customers with orders in this month |
| `order_value` | The sum of order amounts |

Do not add monthly customer counts to calculate distinct customers across the full quarter.
A customer can have orders in more than one month.

## Understand the two products

The source-aligned product (`SA/tpch`) publishes reusable customers, orders, and countries.
It preserves the source keys and gives columns clear names and fixed types.
The consumer-aligned product (`CA/sales`) joins these interfaces and produces the monthly report.

```text
samples.tpch.customer ──> SA internal customers ──> SA external customers ─┐
samples.tpch.orders   ──> SA internal orders    ──> SA external orders    ─┼─> CA internal orders ──> CA external report
samples.tpch.nation   ──> SA internal nations   ──> SA external nations   ─┘
```

Each product has an `internal` folder and an `external` folder under `models/dataproducts`.
Internal models are views. External models are Delta tables with contracts for column names and types.
`external` means a published interface here. It does not mean external storage.

The `tpch` and `sales` groups define the dbt product boundaries.
Private models accept references within their group. Public models accept references from other groups.
Databricks permissions control database access separately. [dbt model access](https://docs.getdbt.com/docs/mesh/govern/model-access)

Generate the documentation and dependency graph:

```bash
dbt docs generate
dbt docs serve --port 8080
```

Open forwarded port 8080 in Codespaces.

## Compare the result with plain SQL

The [complete SQL pipeline](../../sql_pipeline/) builds the same eight objects and runs 27 matching data checks.
Use the [SQL pipeline guide](../../sql_pipeline/) for the comparison and the failure demonstration.

Run [the complete SQL query](../../sql/06_data_products.sql) in Databricks SQL or SQLTools.
It uses the same sources and the same default reporting period.
The dbt test `ca_report_matches_plain_sql` compares every result column in both directions.
It detects extra, missing, or changed rows.

| Work | Plain SQL | This dbt project |
|---|---|---|
| Calculate the report | One supplied SQL query | SQL split into eight models |
| Store intermediate results | Add table or view statements | Configure views and tables in YAML |
| Choose execution order | Supply an ordered script | Use the dependencies from `ref()` |
| Check data | Write SQL assertions and handle failures | Run attached tests with `dbt build` |
| Describe interfaces | Maintain interface definitions | Add model contracts and descriptions |

## See the tests

| Test | What it checks |
|---|---|
| `unique`, `not_null` | Identifiers and required values |
| `relationships` | Orders reference customers; customers reference countries |
| `accepted_values` | Order status is `O`, `P`, or `F` |
| `sa_order_amount_nonnegative` | Order amounts are nonnegative |
| `ca_country_month_unique` | Each country and month has one report row |
| `ca_report_not_empty` | The reporting period produces output |
| `ca_order_totals_preserved` | Joins preserve the source order count and total amount |
| `ca_report_matches_plain_sql` | The report equals an independent source query |
| `monthly_totals_and_distinct_customers` | Four mock orders produce three expected report rows |

The unit test checks distinct customer counts and separate country/month totals.
The contracts also check the four published interfaces during the build.

To demonstrate a failure, run this optional command:

```bash
dbt build --vars '{inject_duplicate_customer: true}'
```

The internal customer model adds one duplicate to its output.
The `unique` test fails on the published customer table.
dbt skips both consumer models because they depend on that table.
The command returns a failure status as expected. [dbt build](https://docs.getdbt.com/reference/commands/build)

An earlier report table can remain after a failed build.
The build does not roll back every table as one transaction.
Restore the normal data before you inspect the report again:

```bash
dbt build
dbt show --select preview_monthly_order_value --limit 10
```

The variable defaults to `false`; no file edit is required.

## Change the reporting period

The end date is exclusive.
For April 1995, use:

```bash
dbt build --vars '{report_interval_start: "1995-04-01", report_interval_end: "1995-05-01"}'
dbt show --select preview_monthly_order_value --limit 10
```

The tests use the supplied dates automatically.
Change the dates in the standalone SQL query when you compare another period.
Run `dbt build` without variables to restore the default quarter.

## Run locally outside the course container

The project needs dbt Core and the Databricks adapter.
The `dbt Cloud CLI` executable does not use this local Core setup.
Check `dbt --version` if commands request a dbt Cloud account.

With `uv` installed, create a separate environment from the repository root:

```bash
uv venv --python 3.12 .venv
uv pip install --python .venv/bin/python 'dbt-core==1.10.17' 'dbt-databricks==1.10.19'
source .venv/bin/activate
./create_profiles.sh --target databricks
cd solutions/dbt/dataproducts
dbt build
dbt show --select preview_monthly_order_value --limit 10
```

For dbt Power User, select its Python interpreter through **Python: Select Interpreter**.
Use `.venv/bin/python` locally, or the installed Python interpreter in the course container.
Keep the dbt integration setting at `core`.

For SQL files and extension differences, see [Databricks setup](../../../docs/setup_instructions.md).
