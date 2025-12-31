import snowflake.connector
import os
from dataclasses import dataclass

if __name__ == "__main__":
    print(
        """
        Usage:
        - Create a file users.csv with first_name,last_name,email of each participant.
          Don't include a header row.
        - Set env var DEFAULT_USER_PASSWORD to the default password that will be set
        - Run this script, check the SQL it intends to run.
        - Set EXECUTE_SQL to True and rerun it.

        WARNING!!! The existing account(s) for these users will be deleted.

        If multiple participants have the same first name,
        this script will give an error. Either create those users manually
        or update this script.
        """
    )

    # Set this to False to only print the SQL to-be-executed.
    # Set this to True to actually run the SQL.
    EXECUTE_SQL = False

    # Change this to the database to use for the course.
    # You must already have created it (this script does not create it).
    # It will also be the prefix for user's names.
    COURSENAME = "WINTERSCHOOL2026"
    DATABASE = COURSENAME

    # These should in theory not change from year to year
    ACCOUNT = "ic07601.eu-west-1"
    WAREHOUSE = "COMPUTE_WH"
    SCHEMA = "public"
    ROLE = "ACCOUNTADMIN"

    # Read DEFAULT_USER_PASSWORD env var
    DEFAULT_USER_PASSWORD = os.environ["DEFAULT_USER_PASSWORD"]

    assert DEFAULT_USER_PASSWORD != "", "Set environment variable DEFAULT_USER_PASSWORD"
    assert (
        "'" not in DEFAULT_USER_PASSWORD
    ), "DEFAULT_USER_PASSWORD cannot contain single quotes (fix this script)"

    def run_sql(sql_stmt):
        """
        Print & run (if EXECUTE_SQL) the given query.
        """
        print(sql_stmt)
        if EXECUTE_SQL:
            cs = ctx.cursor()
            try:
                cs.execute(sql_stmt)
                one_row = cs.fetchone()
                print(one_row[0])
            finally:
                cs.close()

    @dataclass
    class User:
        first_name: str
        last_name: str
        full_name: str
        email: str

    # Parse users.csv
    # (Note: this assumes no comma's or in names or emails but you )
    users: list[User] = []
    with open("users.csv", "r") as f:
        for u in f:
            if u == "":
                continue
            first_name, last_name, email = u.split(",")
            users.append(
                User(
                    first_name=first_name.strip().replace(" ", "_").lower(),
                    last_name=last_name.strip().replace(" ", "_").lower(),
                    full_name=f"{first_name.strip()} {last_name.strip()}",
                    email=email.strip().replace(" ", "_").lower(),
                )
            )

    print("Users:")
    for user in users:
        assert user.first_name != ""
        assert user.last_name != ""
        assert user.full_name != ""
        assert user.email != ""
        print(f" - {user}")

    # Check for no duplicate first names
    if len(users) != len({u.first_name for u in users}):
        raise ValueError("Duplicate first names detected!")

    ctx = snowflake.connector.connect(
        account=ACCOUNT,
        warehouse=WAREHOUSE,
        database=DATABASE,
        authenticator="externalbrowser",
    )
    run_sql("USE ROLE ACCOUNTADMIN")
    run_sql("USE DATABASE " + DATABASE)

    for user in users:
        username = f"{COURSENAME}_{user.first_name}"

        print(f"Creating user {username}...")

        drop_stmt = """
            DROP USER IF EXISTS {0}
        """.format(
            username
        )

        drop_schema = """
            DROP SCHEMA IF EXISTS DBT_{0}
        """.format(
            user.first_name
        )

        insert_stmt = f"""
            CREATE USER {username}
            PASSWORD = '{DEFAULT_USER_PASSWORD}'
            LOGIN_NAME = '{username}'
            DISPLAY_NAME = '{user.full_name}'
            EMAIL = '{user.email}'
            DEFAULT_ROLE = 'STUDENT'
            DEFAULT_WAREHOUSE = 'COMPUTE_WH'
            MUST_CHANGE_PASSWORD = TRUE
            DAYS_TO_EXPIRY = 30;
        """

        # Force MFA to prepare for Snowflake which will start enforcing it in the near future
        set_auth_policy_stmt = f"""
        ALTER USER "{username}" SET
            authentication policy dm_academy_metadata.student_auth_policies.dm_academy_student_auth_policy;
        """

        grant_stmt = """
            GRANT ROLE "STUDENT" TO USER {0};
        """.format(
            username
        )

        create_stmt = """
            CREATE SCHEMA DBT_{0} 
        """.format(
            user.first_name
        )

        grant_schema_stmt = """
            GRANT ALL PRIVILEGES ON SCHEMA DBT_{0} TO ROLE student;
        """.format(
            user.first_name
        )

        run_sql(drop_stmt)
        run_sql(drop_schema)
        run_sql(insert_stmt)
        run_sql(set_auth_policy_stmt)
        run_sql(grant_stmt)
        run_sql(create_stmt)
        run_sql(grant_schema_stmt)

    grant_stmt = f"GRANT USAGE ON DATABASE {DATABASE} TO ROLE student;"
    run_sql(grant_stmt)
    grant_stmt = f"GRANT ALL PRIVILEGES ON DATABASE {DATABASE} TO ROLE student;"
    run_sql(grant_stmt)
    grant_stmt = f"GRANT USAGE ON SCHEMA {DATABASE}.public TO ROLE student;"
    run_sql(grant_stmt)
    grant_stmt = f"GRANT SELECT ON ALL TABLES IN DATABASE {DATABASE} TO ROLE student;"
    run_sql(grant_stmt)
    grant_stmt = (
        f"GRANT SELECT ON FUTURE TABLES IN DATABASE {DATABASE} TO ROLE student;"
    )
    run_sql(grant_stmt)
    grant_stmt = f"GRANT SELECT ON ALL VIEWS IN DATABASE {DATABASE} TO ROLE student;"
    run_sql(grant_stmt)
    grant_stmt = f"GRANT SELECT ON FUTURE VIEWS IN DATABASE {DATABASE} TO ROLE student;"
    run_sql(grant_stmt)
