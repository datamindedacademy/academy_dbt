"""Profile generation checks. All credentials and output paths are temporary."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

import yaml


class ProfilesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        shutil.copy(Path(__file__).resolve().parents[1] / 'create_profiles.sh', self.root)
        self.profiles = self.root / 'profiles'
        self.cfg = self.root / 'config/databrickscfg'
        self.env = dict(os.environ, DBT_PROFILES_DIR=str(self.profiles),
                        DATABRICKS_CONFIG_FILE=str(self.cfg))

    def run_script(self, *args, succeeds=True):
        result = subprocess.run(['bash', str(self.root / 'create_profiles.sh'), *args],
                                env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, succeeds, result.stderr)
        if succeeds:
            return yaml.safe_load((self.profiles / 'profiles.yml').read_text())

    def databricks(self):
        (self.root / '.env').write_text('DATABRICKS_HOST=https://example.cloud.databricks.com/\n'
                                       'DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/test\n'
                                       'DATABRICKS_TOKEN=fake-token\n')

    def test_postgres_without_env_has_no_empty_profile(self):
        profiles = self.run_script()
        self.assertEqual(set(profiles), {'dbt_test', 'covid'})
        self.assertEqual(profiles['dbt_test']['target'], 'postgres')
        self.assertFalse(self.cfg.exists())

    def test_databricks_default_and_normalized_host(self):
        self.databricks()
        profile = self.run_script()['dbt_test']
        self.assertEqual(profile['target'], 'databricks')
        self.assertEqual(profile['outputs']['databricks']['host'], 'example.cloud.databricks.com')
        self.assertEqual((self.profiles / 'profiles.yml').stat().st_mode & 0o777, 0o600)
        self.assertEqual(self.cfg.stat().st_mode & 0o777, 0o600)

    def test_explicit_postgres(self):
        self.databricks()
        self.assertEqual(self.run_script('--target', 'postgres')['dbt_test']['target'], 'postgres')

    def test_project_profile_and_extra_name(self):
        project = self.root / 'student'
        project.mkdir()
        (project / 'dbt_project.yml').write_text('name: student\nprofile: "custom" # comment\n')
        self.assertEqual(set(self.run_script('extra')), {'dbt_test', 'covid', 'custom', 'extra'})

    def test_incomplete_credentials_do_not_replace_profiles(self):
        self.run_script()
        before = (self.profiles / 'profiles.yml').read_bytes()
        (self.root / '.env').write_text('DATABRICKS_HOST=example.cloud.databricks.com\n')
        self.run_script(succeeds=False)
        self.assertEqual((self.profiles / 'profiles.yml').read_bytes(), before)

    def test_repeated_run_preserves_other_databricks_sections(self):
        self.databricks()
        self.cfg.parent.mkdir()
        self.cfg.write_text('[other]\nhost = https://other.example\n')
        self.run_script()
        before = self.cfg.read_text()
        self.run_script()
        self.assertEqual(before, self.cfg.read_text())
        self.assertIn('[other]', before)
        self.assertEqual(before.count('[academy]'), 1)

    def test_password_with_yaml_punctuation(self):
        (self.root / '.env').write_text('POSTGRES_PASSWORD="a: b # c\'d"\n')
        self.assertEqual(self.run_script()['dbt_test']['outputs']['postgres']['password'], "a: b # c'd")

    def test_missing_target_credentials(self):
        self.run_script('--target', 'databricks', succeeds=False)
        self.assertFalse((self.profiles / 'profiles.yml').exists())


if __name__ == '__main__':
    unittest.main()
