# dbt exercise 4: Explore your project documentation

Generate the documentation and inspect model dependencies.

1. Run these commands inside `dbt_academy`:

   ```bash
   dbt docs generate
   dbt docs serve --port 8080
   ```

2. Open the **Ports** tab in Codespaces. Open port **8080**.
3. Find `customer_stats`. Trace both staging models to their sources in the dependency graph.
4. Add model and column descriptions in `models/customer_stats.yml`. For example:

   ```yaml
   version: 2
   models:
     - name: customer_stats
       description: Total order value per customer.
       columns:
         - name: total_spent
           description: Sum of the full order amounts.
   ```

5. Stop the server with `Ctrl-C`. Generate and serve the documentation again to inspect your changes.
