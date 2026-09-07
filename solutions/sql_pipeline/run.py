#!/usr/bin/env python3
"""Build the SQL data products in order, check them, and show the report."""

import argparse
from datetime import date
import json
import os
from pathlib import Path
import re
from string import Template
import sys
import time

import yaml


ROOT = Path(__file__).resolve().parent
# This list is the orchestration logic. SQL table references do not set this order.
STEPS = [
    ('build', 'models/01_internal_nations.sql'),
    ('build', 'models/02_internal_customers.sql'),
    ('build', 'models/03_internal_orders.sql'),
    ('build', 'models/04_external_nations.sql'),
    ('build', 'models/05_external_customers.sql'),
    ('build', 'models/06_external_orders.sql'),
    ('check', 'checks/01_source_product.sql'),
    ('build', 'models/07_consumer_orders.sql'),
    ('build', 'models/08_consumer_report.sql'),
    ('check', 'checks/02_consumer_product.sql'),
    ('check', 'checks/03_plain_sql_equivalence.sql'),
]
CHECK_COUNTS = {
    'checks/01_source_product.sql': 17,
    'checks/02_consumer_product.sql': 9,
    'checks/03_plain_sql_equivalence.sql': 1,
    'checks/04_dbt_equivalence.sql': 1,
}


class PipelineFailure(RuntimeError):
    """A data check fails. Later steps must not execute."""


def identifier(value):
    if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_-]{0,254}', value):
        raise ValueError(f'Unsupported catalog or schema name: {value!r}')
    return f'`{value}`'


def render(path, values):
    return Template((ROOT / path).read_text()).substitute(values).strip().rstrip(';')


def check_rows(rows, expected_count, report=print):
    if len(rows) != expected_count:
        raise PipelineFailure(f'Expected {expected_count} check results, received {len(rows)}.')
    failed = []
    for name, failures in rows:
        if failures is None or failures != 0:
            failed.append(name)
            report(f'FAIL {name}: {failures} invalid rows or groups')
        else:
            report(f'PASS {name}')
    if failed:
        raise PipelineFailure('Data checks failed: ' + ', '.join(failed))


def run_steps(cursor, values, events, steps=STEPS, report=print):
    for index, (kind, path) in enumerate(steps):
        report(f'RUN  {path}')
        started = time.monotonic()
        try:
            cursor.execute(render(path, values))
            if kind == 'check':
                check_rows(cursor.fetchall(), CHECK_COUNTS[path], report)
        except Exception:
            events.append({'step': path, 'status': 'FAIL'})
            for _, skipped in steps[index + 1:]:
                events.append({'step': skipped, 'status': 'SKIP'})
                report(f'SKIP {skipped}')
            raise
        events.append({'step': path, 'status': 'PASS', 'seconds': round(time.monotonic() - started, 2)})
        report(f'OK   {path}')


def preview(cursor, values):
    relation = values['destination'] + '.ca_sales_ext_monthly_order_value'
    cursor.execute(f'SELECT * FROM {relation} ORDER BY nation_id, order_month LIMIT 10')
    print('\n' + ' | '.join(column[0] for column in cursor.description))
    for row in cursor.fetchall():
        print(' | '.join(str(value) for value in row))
    cursor.execute(f'SELECT count(*) AS report_rows, sum(order_count) AS orders, '
                   f'sum(order_value) AS order_value FROM {relation}')
    print('\nReport rows | Orders | Order value')
    print(' | '.join(str(value) for value in cursor.fetchone()))


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profiles-dir', type=Path,
                        default=Path(os.environ.get('DBT_PROFILES_DIR', Path.home() / '.dbt')))
    parser.add_argument('--profile', default='academy_dataproducts')
    parser.add_argument('--start', type=date.fromisoformat, default=date(1995, 1, 1))
    parser.add_argument('--end', type=date.fromisoformat, default=date(1995, 4, 1),
                        help='Exclusive end date.')
    parser.add_argument('--inject-duplicate-customer', action='store_true')
    parser.add_argument('--compare-only', action='store_true',
                        help='Compare existing SQL and dbt reports. Do not build any objects.')
    parser.add_argument('--report-json', type=Path, help='Write step statuses to this file.')
    args = parser.parse_args(argv)
    if args.start >= args.end:
        parser.error('--start must precede --end.')
    if args.compare_only and args.inject_duplicate_customer:
        parser.error('--compare-only cannot inject a duplicate.')
    return args


def main(argv=None):
    args = parse_args(argv)
    token = ''
    events = []
    try:
        profiles = yaml.safe_load((args.profiles_dir / 'profiles.yml').read_text())
        config = profiles[args.profile]['outputs']['databricks']
        if config.get('type') != 'databricks':
            raise ValueError('The selected output must use the Databricks adapter.')
        catalog = config['catalog']
        if catalog.lower() == 'samples':
            raise ValueError('Choose an output catalog such as workspace. samples is read-only source data.')
        destination = identifier(catalog) + '.' + identifier(config['schema'] + '_sql_dataproducts')
        values = {
            'destination': destination,
            'dbt_destination': identifier(catalog) + '.' + identifier(config['schema'] + '_dataproducts'),
            'start_date': args.start.isoformat(),
            'end_date': args.end.isoformat(),
            'inject_duplicate_customer': 'true' if args.inject_duplicate_customer else 'false',
        }
        token = config['token']
        from databricks import sql

        print(f'SQL output: {destination}', flush=True)
        with sql.connect(server_hostname=config['host'].removeprefix('https://').rstrip('/'),
                         http_path=config['http_path'], access_token=token) as connection:
            with connection.cursor() as cursor:
                if args.compare_only:
                    run_steps(cursor, values, events, [('check', 'checks/04_dbt_equivalence.sql')])
                else:
                    cursor.execute(f'CREATE SCHEMA IF NOT EXISTS {destination}')
                    run_steps(cursor, values, events)
                preview(cursor, values)
        print('\nPASS: SQL and dbt reports match.' if args.compare_only
              else '\nPASS: eight SQL models and 27 data checks. The report is ready.')
        return 0
    except (OSError, KeyError, TypeError, yaml.YAMLError) as error:
        print(f'Setup error ({type(error).__name__}). Run ./create_profiles.sh --target databricks.', file=sys.stderr)
        return 1
    except Exception as error:
        message = str(error).replace(token, '[REDACTED]') if token else str(error)
        print(f'FAIL: {message}', file=sys.stderr)
        return 1
    finally:
        if args.report_json:
            args.report_json.parent.mkdir(parents=True, exist_ok=True)
            args.report_json.write_text(json.dumps(events, indent=2) + '\n')


if __name__ == '__main__':
    raise SystemExit(main())
