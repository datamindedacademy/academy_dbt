# Exercise 11 — Capstone: migrate SQL views to dbt

> ⚠️ **Dataset note:** this capstone uses the Belgian Covid-19 dataset, which is
> **not** loaded in the Postgres codespace (only TPC-H is). The starting queries
> below were written for Snowflake and use Snowflake functions (`LAST_DAY`,
> `DATEADD`, `TO_VARCHAR`). To run this exercise on Postgres, the data must
> first be loaded and the functions ported. Until then, treat this as a design
> exercise — or better: apply the same steps to the TPC-H project you built.

## Goal

Take an existing set of raw SQL views and migrate them into a fresh, well
structured dbt project: modular models, sources, tests, and documentation.

## Why this matters

This is the real-life job: a team has a pile of hand-maintained SQL views, and
you turn them into a maintainable dbt project. Everything from exercises 1–10
comes together here.

## The dataset

Belgian Covid-19 open data (https://epistat.wiv-isp.be/covid/, codebook:
https://epistat.sciensano.be/COVID19BE_codebook.pdf), plus population
statistics per municipality (https://statbel.fgov.be/):

- `cases_muni` — new Covid-19 cases per date and municipality
- `vacc_muni_cum` — cumulative vaccinated people per date, age, dose type, and
  municipality
- `population` — population per municipality

The business question: is there a correlation between **vaccinations per
capita** up to a date X, and **cases per capita** in the 8 weeks after X?
(Hard-code X = August 10th, 2021 for now. And remember: correlation ≠
causation!)

## Starting point: 3 raw SQL views

**View 1 — `vaccinations_per_municipality_sql`:**

```sql
CREATE OR REPLACE VIEW vaccinations_per_municipality_sql AS
with muni_vacc_with_dates as (
  select
    *,
    LAST_DAY(TO_DATE(CONCAT('20', substring(year_week, 1, 2)), 'YYYY'), week) AS last_day_of_first_week,
    DATEADD(week, substring(year_week, 4, 2) - 1, last_day_of_first_week) AS last_day_of_the_week
  from public.vacc_muni_cum
),
vaccinations as (
  select
    nis5,
    sum(cumul) as fully_vaccinated,
    '2021-08-10' as by_date,
    last_day_of_the_week
  from muni_vacc_with_dates
  where (dose='B' or dose='C' or dose='E')
  group by nis5, last_day_of_the_week
  having last_day_of_the_week >= by_date
     and last_day_of_the_week < dateadd(week, 1, by_date)
)
select * from vaccinations;
```

**View 2 — `cases_per_municipality_sql`:**

```sql
CREATE OR REPLACE VIEW cases_per_municipality_sql AS
with cases_with_year_week as (
  select
    *,
    CONCAT(SUBSTRING(to_varchar(date_part(year, date_of_case)), 3, 2), 'W',
           to_varchar(date_part(week, date_of_case))) as year_week
  from public.cases_muni
),
new_cases_next_eight_weeks as (
  select
    nis5,
    TX_DESCR_NL, TX_DESCR_FR, TX_ADM_DSTR_DESCR_NL, TX_ADM_DSTR_DESCR_FR,
    PROVINCE, REGION,
    sum(cases) as new_cases,
    dateadd(week, 0, '2021-08-10') as from_date,
    dateadd(week, 8, '2021-08-10') as to_date
  from cases_with_year_week
  where date_of_case > from_date and date_of_case < to_date
  group by nis5, TX_DESCR_NL, TX_DESCR_FR, TX_ADM_DSTR_DESCR_NL,
           TX_ADM_DSTR_DESCR_FR, PROVINCE, REGION
)
select * from new_cases_next_eight_weeks;
```

**View 3 — `covid_stats_per_municipality_sql`:**

```sql
CREATE OR REPLACE VIEW covid_stats_per_municipality_sql AS
with joined as (
  select
    cases.*,
    vaccination.fully_vaccinated,
    vaccination.by_date
  from cases_per_municipality_sql as cases
  left join vaccinations_per_municipality_sql as vaccination
    on cases.nis5 = vaccination.nis5
),
population_stat as (
  select
    joined.*,
    population.population
  from joined
  left join public.population on population.refnis = joined.nis5
),
final as (
  select
    *,
    new_cases / population as cases_per_capita,
    fully_vaccinated / population AS vacc_per_capita
  from population_stat
)
select * from final;
```

## Exercise

1. Create a new dbt project: run `dbt init` and name the project `covid`.
   (dbt says a profile already exists and asks to overwrite it — answer **no**.)
2. Put each part in its own model.
3. Add references (`ref()`) and sources (`source()`).
4. *(Optional)* Add info in a schema file.
5. *(Optional)* Add one or more generic tests (a column-level test in
   `schema.yml`).
6. *(Optional)* Add a singular test (a SQL file in the `tests/` folder).
7. *(Optional)* Generate documentation.

## Structure it like the pros

Follow dbt Labs' recommended layering when you split the views into models:

```
models/
├── 1_staging/        <- clean versions of source tables (rename, cast; no joins/aggregations)
├── 2_intermediate/   <- complex internal logic (joins, aggregations; not for consumers)
└── 3_marts/          <- the output layer, visible for consumers
```

And the general best practices:

- Use CTEs; split big models into multiple smaller ones.
- Use Jinja (variables, loops, macros) to keep code DRY — but don't overdo it.
- Don't reinvent the wheel: use packages (`dbt_utils`, `dbt_expectations`).
- Test as much as you can.

Reference: https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview
