#!/usr/bin/env python3
"""Check the course in an isolated schema; remove that schema after the check."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import uuid

import yaml


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', choices=['databricks', 'postgres'], default='databricks')
    parser.add_argument('--profile', default='dbt_test')
    parser.add_argument('--profiles-dir', type=Path,
                        default=Path(os.environ.get('DBT_PROFILES_DIR', Path.home() / '.dbt')))
    args = parser.parse_args()
    dbt = shutil.which('dbt')
    if not dbt:
        parser.error('dbt is missing. Run this check inside the course codespace.')
    try:
        profiles = yaml.safe_load((args.profiles_dir / 'profiles.yml').read_text())
        output = dict(profiles[args.profile]['outputs'][args.target])
    except (OSError, KeyError, TypeError, yaml.YAMLError):
        parser.error('Profile or target is missing. Run ./create_profiles.sh first.')
    schema = 'academy_check_' + uuid.uuid4().hex[:12]
    output['schema'] = schema
    print(f'Check destination: {args.target}, schema {schema}', flush=True)
    with tempfile.TemporaryDirectory(prefix='academy-check-') as directory:
        root = Path(directory)
        project = root / 'project'
        shutil.copytree(Path(__file__).parent / 'dbt', project,
                        ignore=shutil.ignore_patterns('target', 'logs', 'dbt_packages'))
        config = root / 'profiles'
        config.mkdir(mode=0o700)
        profile_file = config / 'profiles.yml'
        profile_file.write_text(yaml.safe_dump({'academy_check': {
            'target': args.target, 'outputs': {args.target: output}}}))
        profile_file.chmod(0o600)
        env = dict(os.environ, DBT_SEND_ANONYMOUS_USAGE_STATS='false')

        def run(*command):
            subprocess.run([dbt, *command, '--project-dir', str(project),
                            '--profiles-dir', str(config), '--target', args.target],
                           env=env, check=True)

        # No cleanup request is needed if the connection itself fails.
        run('debug')
        failed = False
        try:
            run('run-operation', 'check_sources')
            run('build')
            run('run-operation', 'check_snapshot', '--args', '{expected_rows: 5, expected_current: 5}')
            seed = project / 'seeds/country_codes.csv'
            seed.write_text(seed.read_text() + 'CN,China\n')
            run('seed')
            run('snapshot')
            run('run-operation', 'check_snapshot', '--args', '{expected_rows: 6, expected_current: 6}')
            lines = seed.read_text().splitlines()
            seed.write_text(lines[0] + ',continent\n' + '\n'.join(
                line + ',' + continent for line, continent in zip(
                    lines[1:], ['North America', 'North America', 'Europe', 'Europe', 'Europe', 'Asia']
                )) + '\n')
            run('seed', '--full-refresh')
            run('snapshot')
            run('run-operation', 'check_snapshot', '--args', '{expected_rows: 12, expected_current: 6}')
            run('docs', 'generate')
        except subprocess.CalledProcessError:
            failed = True
        finally:
            try:
                run('run-operation', 'cleanup_check')
            except subprocess.CalledProcessError:
                print(f'Cleanup failed. Remove only the check schema: {schema}', flush=True)
                failed = True
        if failed:
            raise SystemExit(1)
    print('PASS: sources, views, table, tests, variables, loop, macro, seed, snapshot history, and docs.')


if __name__ == '__main__':
    main()
