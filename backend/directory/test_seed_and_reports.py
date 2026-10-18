import json
import re
import tempfile
from datetime import timedelta
from io import StringIO
from pathlib import Path
from unittest import mock

from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.core.management import call_command
from django.core.management.base import CommandError
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework.throttling import ScopedRateThrottle

from .counties import COUNTIES, NATIONWIDE
from .management.commands.load_directory_seed import SEED_DIR, record_id
from .models import ListingReport, Opportunity, SeedBatch, SupportResource
from .tests import make_opportunity, make_resource


def write_batch(directory, name='test-batch', checked_at=None, **extra):
    checked_at = checked_at or (timezone.now() - timedelta(hours=1)).isoformat()
    batch = {
        'name': name, 'checked_at': checked_at, 'verification_note': 'Desk check (test)',
        'opportunities': [{
            'key': 'job-1', 'title': 'Seeded job', 'organisation': 'Org', 'summary': 'Summary',
            'category': 'job', 'county': 'Nairobi', 'eligibility': '', 'cost_label': 'Free',
            'application_url': 'https://example.invalid/apply', 'source_url': 'https://example.invalid/src',
            'deadline': None,
        }],
        'support_resources': [{
            'key': 'line-1', 'name': 'Seeded helpline', 'description': 'Test only', 'kind': 'helpline',
            'county': 'Nationwide', 'phone': '116', 'website_url': '', 'location_label': '',
            'source_url': 'https://example.invalid/src',
        }],
    }
    batch.update(extra)
    Path(directory, f'{name}.json').write_text(json.dumps(batch), encoding='utf-8')
    return batch


class LoadDirectorySeedTests(TestCase):
    def run_cmd(self, seed_dir, *args):
        out = StringIO()
        call_command('load_directory_seed', '--seed-dir', str(seed_dir), *args, stdout=out)
        return out.getvalue()

    def test_applies_once_and_publishes_with_provenance(self):
        with tempfile.TemporaryDirectory() as tmp:
            write_batch(tmp)
            self.assertIn('applied test-batch', self.run_cmd(tmp))
            job = Opportunity.objects.get()
            self.assertEqual(job.id, record_id('test-batch', 'job-1'))
            self.assertEqual(job.verification_note, 'Desk check (test)')
            self.assertIsNone(job.verified_by)
            self.assertEqual(job.publication_status(), 'published')
            self.assertEqual(len(self.client.get('/api/v1/support-resources/').json()), 1)
            # Staff delete one record and revoke the other; a later deploy must not undo that.
            job.delete()
            SupportResource.objects.update(is_active=False)
            self.assertIn('already applied', self.run_cmd(tmp))
            self.assertFalse(Opportunity.objects.exists())
            self.assertFalse(SupportResource.objects.get().is_active)
            self.assertEqual(SeedBatch.objects.get().opportunities_created, 1)

    def test_dry_run_writes_nothing(self):
        with tempfile.TemporaryDirectory() as tmp:
            write_batch(tmp)
            self.assertIn('dry run', self.run_cmd(tmp, '--dry-run'))
            self.assertFalse(Opportunity.objects.exists())
            self.assertFalse(SeedBatch.objects.exists())

    def test_invalid_record_fails_the_whole_batch(self):
        with tempfile.TemporaryDirectory() as tmp:
            batch = write_batch(tmp)
            batch['support_resources'][0]['county'] = 'Atlantis'
            Path(tmp, 'test-batch.json').write_text(json.dumps(batch), encoding='utf-8')
            with self.assertRaises(CommandError):
                self.run_cmd(tmp)
            self.assertFalse(Opportunity.objects.exists())
            self.assertFalse(SeedBatch.objects.exists())

    def test_future_check_time_is_refused(self):
        with tempfile.TemporaryDirectory() as tmp:
            write_batch(tmp, checked_at=(timezone.now() + timedelta(days=1)).isoformat())
            with self.assertRaises(CommandError):
                self.run_cmd(tmp)


class ShippedSeedDataTests(TestCase):
    """The real batches in directory/seed/: every record valid, sourced and dialable."""

    def test_shipped_batches_are_valid_and_complete(self):
        paths = sorted(SEED_DIR.glob('*.json'))
        self.assertTrue(paths)
        call_command('load_directory_seed', '--dry-run', stdout=StringIO())
        for path in paths:
            batch = json.loads(path.read_text(encoding='utf-8'))
            self.assertIn('Claude', batch['verification_note'])
            for item in batch['opportunities'] + batch['support_resources']:
                self.assertTrue(item['source_url'].startswith('https://'), item['key'])
                self.assertIn(item['county'], (NATIONWIDE, *COUNTIES), item['key'])
                for url_field in ('application_url', 'website_url'):
                    if item.get(url_field):
                        self.assertTrue(item[url_field].startswith('https://'), item['key'])
                phone = item.get('phone', '')
                if phone:
                    digits = re.sub(r'\D', '', phone)
                    self.assertTrue(len(digits) in (3, 4) or len(digits) in (10, 12), (item['key'], phone))

    def test_api_returns_every_shipped_support_resource(self):
        call_command('load_directory_seed', stdout=StringIO())
        total = SupportResource.objects.count()
        self.assertGreater(total, 50)
        self.assertEqual(len(self.client.get('/api/v1/support-resources/').json()), total)


class ListingReportTests(TestCase):
    url = '/api/v1/reports/'

    def setUp(self):
        cache.clear()  # throttle history lives in the cache
        self.addCleanup(cache.clear)
        self.client = APIClient(enforce_csrf_checks=True)
        self.job = make_opportunity()
        self.resource = make_resource()

    def post(self, **data):
        body = {'record_type': 'opportunity', 'record_id': str(self.job.id), 'reason': 'broken_link'}
        body.update(data)
        return self.client.post(self.url, body, format='json')

    def test_anonymous_report_is_stored_without_csrf_or_identity(self):
        response = self.post(note='  The apply link gives a 404  ')
        self.assertEqual(response.status_code, 201, response.content)
        self.assertEqual(response.json(), {'status': 'received'})
        report = ListingReport.objects.get()
        self.assertEqual(report.record_label, self.job.title)
        self.assertEqual(report.note, 'The apply link gives a 404')
        self.assertEqual(report.status, ListingReport.Status.NEW)
        stored = {f.name for f in ListingReport._meta.get_fields()}
        self.assertFalse(stored & {'ip', 'ip_address', 'user_agent', 'device', 'phone', 'email'})

    def test_support_resource_can_be_reported(self):
        response = self.post(record_type='support_resource', record_id=str(self.resource.id), reason='wrong_contact')
        self.assertEqual(response.status_code, 201, response.content)

    def test_rejects_unknown_unpublished_or_mismatched_records(self):
        hidden = make_opportunity(title='Draft', is_verified=False, is_active=False)
        for data in (
            {'record_id': '00000000-0000-0000-0000-000000000000'},
            {'record_id': str(hidden.id)},
            {'record_type': 'support_resource'},  # an opportunity id under the wrong type
            {'reason': 'spam'},
            {'note': 'x' * (ListingReport.MAX_NOTE + 1)},
            {'record_type': 'user'},
        ):
            self.assertEqual(self.post(**data).status_code, 400, data)
        self.assertFalse(ListingReport.objects.exists())

    def test_reports_are_write_only(self):
        self.post()
        self.assertEqual(self.client.get(self.url).status_code, 405)

    def test_reports_are_rate_limited(self):
        rates = {**ScopedRateThrottle.THROTTLE_RATES, 'reports': '2/hour'}
        with mock.patch.object(ScopedRateThrottle, 'THROTTLE_RATES', rates):
            codes = [self.post().status_code for _ in range(3)]
        self.assertEqual(codes, [201, 201, 429])

    def test_staff_triage_records_reviewer_and_purge_keeps_new(self):
        staff = get_user_model().objects.create_superuser('mod', 'mod@example.invalid', 'pw-test-only')
        self.post()
        self.post(reason='suspected_scam')
        old, newest = ListingReport.objects.order_by('created_at')
        admin = self.client_class()
        admin.force_login(staff)
        self.assertEqual(admin.get('/admin/directory/listingreport/').status_code, 200)
        self.assertEqual(admin.get(f'/admin/directory/listingreport/{old.pk}/change/').status_code, 200)
        response = admin.post('/admin/directory/listingreport/', {
            'action': 'mark_dismissed', '_selected_action': [str(old.pk)],
        })
        self.assertEqual(response.status_code, 302)
        old.refresh_from_db()
        self.assertEqual((old.status, old.reviewed_by), (ListingReport.Status.DISMISSED, staff))
        self.assertEqual(admin.get('/admin/directory/opportunity/').status_code, 200)  # open_reports column
        ListingReport.objects.update(created_at=timezone.now() - timedelta(days=120))
        call_command('purge_reports', stdout=StringIO())
        self.assertEqual(list(ListingReport.objects.values_list('pk', flat=True)), [newest.pk])
