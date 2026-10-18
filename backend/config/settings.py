"""HATUA backend settings. Production requires explicitly configured secrets and DB."""
import os
from pathlib import Path

from config.deploy import admin_path, database_config, on_vercel, platform_hosts, split_csv

BASE_DIR = Path(__file__).resolve().parent.parent
DEBUG = os.getenv('DJANGO_DEBUG', '0') == '1'
ON_VERCEL = on_vercel(os.environ)
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', '')
if not SECRET_KEY:
    if DEBUG:
        SECRET_KEY = 'dev-only-not-for-production-replace-before-deployment'  # noqa: S105 (DEBUG-only fallback)
    else:
        raise RuntimeError('DJANGO_SECRET_KEY must be configured in production')

# Explicit hosts from the environment, plus the hostnames Vercel assigns to this deployment.
_PLATFORM_HOSTS = platform_hosts(os.environ)
ALLOWED_HOSTS = split_csv(os.getenv('DJANGO_ALLOWED_HOSTS', '' if not DEBUG else 'localhost,127.0.0.1'))
ALLOWED_HOSTS += [h for h in _PLATFORM_HOSTS if h not in ALLOWED_HOSTS]
if not DEBUG and not ALLOWED_HOSTS:
    raise RuntimeError('DJANGO_ALLOWED_HOSTS must be configured in production')
CSRF_TRUSTED_ORIGINS = split_csv(os.getenv('DJANGO_CSRF_TRUSTED_ORIGINS'))
CSRF_TRUSTED_ORIGINS += [f'https://{h}' for h in _PLATFORM_HOSTS if f'https://{h}' not in CSRF_TRUSTED_ORIGINS]

# Staff admin path. Override in production so the login page is not at the well-known /admin/.
ADMIN_URL = admin_path(os.getenv('DJANGO_ADMIN_URL'))

INSTALLED_APPS = [
    'django.contrib.admin', 'django.contrib.auth', 'django.contrib.contenttypes',
    'django.contrib.sessions', 'django.contrib.messages', 'django.contrib.staticfiles',
    'rest_framework', 'corsheaders', 'directory',
]
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
ROOT_URLCONF = 'config.urls'
TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [], 'APP_DIRS': True,
    'OPTIONS': {'context_processors': [
        'django.template.context_processors.debug',
        'django.template.context_processors.request',
        'django.contrib.auth.context_processors.auth',
        'django.contrib.messages.context_processors.messages',
    ]},
}]
# WSGI only: Vercel prefers ASGI when both are set, and every view here is synchronous.
WSGI_APPLICATION = 'config.wsgi.application'

url = os.getenv('DATABASE_URL')
if not url and not DEBUG:
    raise RuntimeError('DATABASE_URL must be configured in production')
DATABASES = {'default': database_config(url or f'sqlite:///{BASE_DIR / "db.sqlite3"}', serverless=ON_VERCEL)}
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]
LANGUAGE_CODE = 'en'
TIME_ZONE = 'Africa/Nairobi'
USE_I18N = True
USE_TZ = True
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': ['rest_framework.permissions.IsAuthenticated'],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {'anon': '60/min', 'user': '600/hour', 'reports': '10/hour'},
    'DEFAULT_RENDERER_CLASSES': ['rest_framework.renderers.JSONRenderer'],
}
# A verification older than this silently removes the record from the public API until staff
# re-check the source. 90 days is a conservative starting point, not a validated figure;
# revisit with pilot partners (see docs/CONTENT_VERIFICATION.md).
HATUA_VERIFICATION_MAX_AGE_DAYS = int(os.getenv('HATUA_VERIFICATION_MAX_AGE_DAYS', '90'))
if HATUA_VERIFICATION_MAX_AGE_DAYS < 1:
    raise RuntimeError('HATUA_VERIFICATION_MAX_AGE_DAYS must be a positive number of days')

CORS_ALLOWED_ORIGINS =[s.strip() for s in os.getenv('CORS_ALLOWED_ORIGINS', '').split(',') if s.strip()]
SESSION_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_SECURE = not DEBUG
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_REFERRER_POLICY = 'same-origin'
X_FRAME_OPTIONS = 'DENY'
SECURE_SSL_REDIRECT = not DEBUG and os.getenv('DJANGO_SECURE_SSL_REDIRECT', '1') == '1'
SECURE_HSTS_SECONDS = 31536000 if not DEBUG else 0
SECURE_HSTS_INCLUDE_SUBDOMAINS = not DEBUG
SECURE_HSTS_PRELOAD = False
# Behind Vercel's (or another trusted) TLS-terminating proxy, trust X-Forwarded-Proto so
# request.is_secure() is correct; otherwise SECURE_SSL_REDIRECT would loop.
if ON_VERCEL or os.getenv('DJANGO_TRUST_X_FORWARDED_PROTO') == '1':
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Without this, Django sends production errors only to (unconfigured) admin email, so they
# would never appear in the hosting platform's logs. Never log request bodies or goals.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {'console': {'class': 'logging.StreamHandler'}},
    'loggers': {
        'django': {'handlers': ['console'], 'level': 'WARNING'},
        'directory': {'handlers': ['console'], 'level': 'INFO'},
    },
}
