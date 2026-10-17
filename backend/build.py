"""Vercel build step for hatua-api (configured as buildCommand in vercel.json).

Vercel installs requirements.txt and runs `collectstatic` itself. This script adds:
  1. `check --deploy` failing on errors (warnings are printed, not fatal);
  2. production only: database migrations and the first staff superuser.

Preview builds never migrate, so a preview branch cannot change the production schema.
Migrations use Neon's direct connection (DATABASE_URL_UNPOOLED) when it exists, because
schema changes should not go through the transaction-mode pooler.
"""
import os


def main() -> None:
    vercel_env = os.getenv('VERCEL_ENV', 'local')
    production = vercel_env == 'production'
    if production and os.getenv('DATABASE_URL_UNPOOLED'):
        # Must be set before Django reads settings.
        os.environ['DATABASE_URL'] = os.environ['DATABASE_URL_UNPOOLED']
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

    import django
    from django.core.management import call_command

    django.setup()
    print('build.py: check --deploy', flush=True)
    call_command('check', deploy=True, fail_level='ERROR')
    if not production:
        print(f'build.py: VERCEL_ENV={vercel_env}; skipping migrations and superuser.', flush=True)
        return
    print('build.py: migrate', flush=True)
    call_command('migrate', interactive=False)
    call_command('ensure_superuser')


if __name__ == '__main__':
    main()
