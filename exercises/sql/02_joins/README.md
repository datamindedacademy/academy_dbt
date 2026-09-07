# SQL exercise 2: Join tables

Use `samples.tpch`. Write one query per task.

1. List customer names with their nation.
2. Add each nation's region to the result.
3. List distinct customer names with an order line whose discount exceeds `0.09`.
4. List customers who have no orders.
5. List distinct African suppliers who supply parts with brand `'Brand#43'`.

Use `customer → orders → lineitem` for task 3.
Use `region → nation → supplier → partsupp → part` for task 5.
For task 4, use a left join and check for a missing order key.
