"""Hosting-platform helpers kept free of Django settings so they can be unit tested.

Vercel exposes system environment variables at build and run time (VERCEL, VERCEL_ENV,
VERCEL_URL, VERCEL_PROJECT_PRODUCTION_URL, VERCEL_BRANCH_URL). Neon, added through the
Vercel Marketplace, injects DATABASE_URL (pooled, PgBouncer transaction mode) and
DATABASE_URL_UNPOOLED (direct, used for migrations).
"""
from collections.abc import Mapping

import dj_database_url

PLATFORM_HOST_VARS = ('VERCEL_PROJECT_PRODUCTION_URL', 'VERCEL_URL', 'VERCEL_BRANCH_URL')


def on_vercel(env: Mapping[str, str]) -> bool:
    return env.get('VERCEL') == '1'


def platform_hosts(env: Mapping[str, str]) -> list[str]:
    """Hostnames Vercel assigned to this deployment (no scheme, no path), de-duplicated."""
    hosts: list[str] = []
    for key in PLATFORM_HOST_VARS:
        value = env.get(key, '').strip()
        if not value:
            continue
        host = value.split('://')[-1].split('/')[0].lower()
        if host and host not in hosts:
            hosts.append(host)
    return hosts


def split_csv(value: str | None) -> list[str]:
    return [item.strip() for item in (value or '').split(',') if item.strip()]


def database_config(url: str, *, serverless: bool) -> dict:
    """Django DATABASES['default'] for a URL, tuned for serverless + transaction pooling.

    - serverless: no persistent connections (instances freeze between requests).
    - pooled (PgBouncer/Supavisor transaction mode, e.g. Neon '-pooler' hosts): server-side
      cursors and automatic prepared statements are unsafe because consecutive statements
      may run on different server connections.
    """
    config = dj_database_url.parse(url, conn_max_age=0 if serverless else 60, conn_health_checks=not serverless)
    if config.get('ENGINE') == 'django.db.backends.postgresql':
        host = str(config.get('HOST') or '')
        options = config.setdefault('OPTIONS', {})
        if '-pooler' in host or options.pop('pool_mode', None) == 'transaction':
            config['DISABLE_SERVER_SIDE_CURSORS'] = True
            options['prepare_threshold'] = None
        if serverless:
            options.setdefault('connect_timeout', 10)
    return config


def admin_path(value: str | None) -> str:
    """Normalise DJANGO_ADMIN_URL to 'segment/' form; default 'admin/'."""
    path = (value or 'admin').strip().strip('/')
    if not path or any(ch in path for ch in ' ?#'):
        raise ValueError('DJANGO_ADMIN_URL must be a simple path such as "staff-portal/"')
    return f'{path}/'
