from django.test import SimpleTestCase

from config.deploy import admin_path, database_config, on_vercel, platform_hosts, split_csv


class PlatformHostsTests(SimpleTestCase):
    def test_collects_vercel_hosts_without_scheme_or_duplicates(self):
        env = {
            'VERCEL': '1',
            'VERCEL_PROJECT_PRODUCTION_URL': 'hatua-api.vercel.app',
            'VERCEL_URL': 'hatua-api-abc123-team.vercel.app',
            'VERCEL_BRANCH_URL': 'https://hatua-api.vercel.app/',
        }
        self.assertTrue(on_vercel(env))
        self.assertEqual(platform_hosts(env), ['hatua-api.vercel.app', 'hatua-api-abc123-team.vercel.app'])

    def test_no_platform_outside_vercel(self):
        self.assertFalse(on_vercel({}))
        self.assertEqual(platform_hosts({}), [])

    def test_split_csv(self):
        self.assertEqual(split_csv(' a.example, ,b.example '), ['a.example', 'b.example'])
        self.assertEqual(split_csv(None), [])


class DatabaseConfigTests(SimpleTestCase):
    def test_neon_pooler_on_serverless_disables_cursors_and_prepared_statements(self):
        cfg = database_config(
            'postgresql://u:p@ep-cool-123-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require',
            serverless=True,
        )
        self.assertEqual(cfg['ENGINE'], 'django.db.backends.postgresql')
        self.assertEqual(cfg['CONN_MAX_AGE'], 0)
        self.assertTrue(cfg['DISABLE_SERVER_SIDE_CURSORS'])
        self.assertIsNone(cfg['OPTIONS']['prepare_threshold'])
        self.assertEqual(cfg['OPTIONS']['sslmode'], 'require')
        self.assertEqual(cfg['OPTIONS']['connect_timeout'], 10)

    def test_direct_connection_keeps_defaults(self):
        cfg = database_config('postgresql://u:p@db.internal:5432/app', serverless=False)
        self.assertEqual(cfg['CONN_MAX_AGE'], 60)
        self.assertFalse(cfg['DISABLE_SERVER_SIDE_CURSORS'])
        self.assertNotIn('prepare_threshold', cfg['OPTIONS'])

    def test_explicit_transaction_pool_mode_hint_is_consumed(self):
        cfg = database_config('postgresql://u:p@pooler.example:6543/app?pool_mode=transaction', serverless=True)
        self.assertTrue(cfg['DISABLE_SERVER_SIDE_CURSORS'])
        self.assertNotIn('pool_mode', cfg['OPTIONS'], 'must not be passed to libpq')

    def test_sqlite_untouched(self):
        cfg = database_config('sqlite:////tmp/x.sqlite3', serverless=True)
        self.assertEqual(cfg['ENGINE'], 'django.db.backends.sqlite3')
        self.assertFalse(cfg['DISABLE_SERVER_SIDE_CURSORS'])
        self.assertNotIn('OPTIONS', cfg)


class AdminPathTests(SimpleTestCase):
    def test_normalises(self):
        self.assertEqual(admin_path(None), 'admin/')
        self.assertEqual(admin_path('/staff-portal/'), 'staff-portal/')
        self.assertEqual(admin_path('staff-x7q2'), 'staff-x7q2/')

    def test_rejects_unsafe_values(self):
        for bad in ('/', 'a b', 'x?y', 'x#y'):
            with self.assertRaises(ValueError, msg=bad):
                admin_path(bad)
