"""Delete handled listing reports after the retention period (data minimisation).

Reports that are still `new` are kept until staff handle them. Runs on every production
deploy (build.py); safe to run by hand: `python manage.py purge_reports --days 90`.
"""
from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from directory.models import ListingReport


class Command(BaseCommand):
    help = 'Delete handled listing reports older than --days (default 90).'

    def add_arguments(self, parser):
        parser.add_argument('--days', type=int, default=90)

    def handle(self, *args, days=90, **options):
        cutoff = timezone.now() - timedelta(days=max(days, 1))
        deleted, _ = ListingReport.objects.exclude(status=ListingReport.Status.NEW).filter(
            created_at__lt=cutoff
        ).delete()
        self.stdout.write(f'purge_reports: deleted {deleted} handled report(s) older than {days} days.')
