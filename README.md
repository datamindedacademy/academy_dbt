# dbt_training_excercise
[![Open in
Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/jelledv/dbt_training_excercise.git)

Slides for the exercise: https://docs.google.com/presentation/d/1hnOXtAIAClQgcPbHpWrU3Hf51Q5FAa7aFNxCD4JcAnQ/edit?usp=sharing

Enter the folder "audiance_measurment" explore the files in folders:

- models
- tests

And file:
- dbt_profiles.yml

Try running the following commands:

- dbt run
- dbt test

** To run the model with variables:

``dbt run --vars '{date: 2021-02-10, num_days: 3}'``

dbt cheat sheet: https://github.com/bruno-szdl/cheatsheets/blob/main/dbt_cheat_sheet.pdf

### Exercises

1) Generate the documentation of the dbt project and serve the documentation on a local webserver. Find out how to do this in the documentation of dbt: https://docs.getdbt.com/docs/building-a-dbt-project/documentation

2) Refactor the dbt project to follow the best practices described from dbt labs: https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview and https://docs.getdbt.com/blog/stakeholder-friendly-model-names

3) Take a look at all the singular tests in the tests directory. Try to replace as many tests as possible with generic tests from packages that exist. Here are two packages that can get you started: 
   - https://hub.getdbt.com/dbt-labs/dbt_utils/latest/
   - https://hub.getdbt.com/calogica/dbt_expectations/latest/

4) Use the codegen package from dbt labs to generate a complete yaml source file. Altough it is not required to list all the columns, it helps for readability and completion. You can also use the codegen package to generate base models, so you don't reference sources deep down in your models logic
    - https://hub.getdbt.com/dbt-labs/codegen/latest/
    ```
   dbt run-operation generate_source --args '{"schema_name": "public", "database_name": "dbtworkshop",
    "generate_columns": True, "include_descriptions": True}'
    ```
5. Use SQLStuff to do linting (https://docs.sqlfluff.com/en/stable/index.html). The primary aim of SQLFluff as a project is in service of that first aim of quality assurance. With larger and larger teams maintaining large bodies of SQL code, it becomes more and more important that the code is not just valid but also easily comprehensible by other users of the same codebase. One way to ensure readability is to enforce a consistent style, and the tools used to do this are called linters.
Some famous linters which are well known in the software community are flake8 and jslint (the former is used to lint the SQLFluff project itself).
SQLFluff aims to fill this space for SQL.
    - Add a .sqlstuff file to the root of your dbt project
    ```
    [sqlfluff]
    templater = dbt
    sql_file_exts = .sql,.sql.j2,.dml,.ddl
    rules = L001,L003,L004,L005,L006,L007,L008,L010,L011,L012,L014,L015,L017,L018,L021,L022,L023,L025,L027,L028,L030,L035,L036,L037,L039,L040,L041,L042,L045,L046,L048,L051,L055
    
    [sqlfluff:indentation]
    indented_joins = false
    indented_using_on = true
    template_blocks_indent = false
    
    [sqlfluff:templater]
    unwrap_wrapped_queries = true
    
    [sqlfluff:templater:jinja]
    apply_dbt_builtins = true
    ```
   - Do some linting checks. It also possible to autofix models with SQLStuff
   ```
    sqlfluff lint models --dialect redshift
    ```

    ```
    sqlfluff fix models --dialect redshift
    ```
6. Make sure that all the data marts are materialized as a table and that all the staging models are materialized as views. Do this in your dbt_project.yml file. Documentation: https://docs.getdbt.com/docs/building-a-dbt-project/building-models/materializations
7. Generate a new dbt project from scratch and get the connection working to Redshift using 'dbt debug' 
### Reference tables

#### schedule
```
CREATE TABLE "public"."schedule"(channel integer encode az64,
                                 start   timestamp without time zone encode az64,
                                 stop    timestamp without time zone encode az64,
                                 program character varying(50) encode lzo,
                                 genre   character varying(20) encode lzo);
```



#### timestamps
```
CREATE TABLE "public"."timestamps"(users   character varying(20) encode lzo,
                                   time    timestamp without time zone encode az64,
                                   channel integer encode az64);
```

### Backup data
The schedule and timestamp data for the exercise can be found in the data directory. It can be loaded from the Redshift Editor v2 or with a SQL command once it has been uploaded to an S3 bucket