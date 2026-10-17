"""Create the first staff superuser from environment variables, once.

Runs during the production build on Vercel (see build.py), because serverless hosting gives
no shell to run `createsuperuser`. Idempotent: an existing account is never modified, so
changing the password in the admin afterwards is safe. The password is never printed.

    DJANGO_SUPERUSER_USERNAME, DJANGO_SUPERUSER_PASSWORD, DJANGO_SUPERUSER_EMAIL (optional)
"""
import os

from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.core.management.base import BaseCommand, CommandError


class Command(BaseCommand):
    help = 'Create the initial superuser from DJANGO_SUPERUSER_* env vars if it does not exist.'

    def handle(self, *args, **options):
        username = os.getenv('DJANGO_SUPERUSER_USERNAME', '').strip()
        password = os.getenv('DJANGO_SUPERUSER_PASSWORD', '')
        email = os.getenv('DJANGO_SUPERUSER_EMAIL', '').strip()
        if not username or not password:
            self.stdout.write('ensure_superuser: DJANGO_SUPERUSER_USERNAME/PASSWORD not set; skipped.')
            return

        user_model = get_user_model()
        if user_model.objects.filter(username=username).exists():
            self.stdout.write(f'ensure_superuser: "{username}" already exists; left unchanged.')
            return

        candidate = user_model(username=username, email=email)
        try:
            validate_password(password, user=candidate)
        except ValidationError as exc:
            raise CommandError('DJANGO_SUPERUSER_PASSWORD rejected: ' + ' '.join(exc.messages)) from None

        user_model.objects.create_superuser(username=username, email=email, password=password)
        self.stdout.write(self.style.SUCCESS(f'ensure_superuser: created superuser "{username}".'))
