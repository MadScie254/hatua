from datetime import timedelta

from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from django.test import TestCase, override_settings
from django.utils import timezone

from .models import Opportunity, SupportResource

SOURCE = 'https://example.invalid/official-page'


def make_opportunity(**overrides):
    fields = {
        'title': 'Public example job', 'organisation': 'Example Organisation',
        'summary': 'Example for testing only', 'category': 'job', 'county': 'Nairobi',
        'is_verified': True, 'is_active': True, 'source_url': SOURCE,
        'last_verified_at': timezone.now() - timedelta(days=1),
    }
    fields.update(overrides)
    return Opportunity.objects.create(**fields)


def make_resource(**overrides):
    fields = {
        'name': 'Example verified resource', 'description': 'A test resource, not a real service',
        'kind': 'ngo', 'county': 'Nationwide', 'is_verified': True, 'is_active': True,
        'source_url': SOURCE, 'last_verified_at': timezone.now() - timedelta(days=1),
    }
    fields.update(overrides)
    return SupportResource.objects.create(**fields)


class PublicDirectoryTests(TestCase):
    def setUp(self):
        self.public_job = make_opportunity()
        make_opportunity(title='Hidden draft', is_verified=False)
        make_opportunity(title='Expired deadline', county='Nationwide',
                         deadline=timezone.localdate() - timedelta(days=1))
        make_opportunity(title='Never dated', last_verified_at=None)
        make_opportunity(title='Stale verification', last_verified_at=timezone.now() - timedelta(days=91))
        make_opportunity(title='Future verification', last_verified_at=timezone.now() + timedelta(days=2))
        make_opportunity(title='Training course', category='training', county='Kisumu')
        self.public_support = make_resource()
        make_resource(name='Unpublished facility', kind='facility', county='Nairobi', is_active=False)
        make_resource(name='Kisumu helpline', kind='helpline', county='Kisumu')

    def titles(self, url):
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200, response.content)
        return sorted(item.get('title') or item.get('name') for item in response.json())

    def test_health(self):
        response = self.client.get('/api/v1/health/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')

    def test_only_published_unexpired_opportunities(self):
        self.assertEqual(self.titles('/api/v1/opportunities/'), ['Public example job', 'Training course'])

    def test_public_payload_hides_moderation_fields(self):
        item = self.client.get('/api/v1/opportunities/?county=Nairobi').json()[0]
        for private in ('is_verified', 'is_active', 'verified_by', 'created_at', 'updated_at'):
            self.assertNotIn(private, item)
        self.assertEqual(item['source_url'], SOURCE)
        self.assertIsNotNone(item['last_verified_at'])

    def test_county_filter_includes_nationwide(self):
        self.assertEqual(self.titles('/api/v1/opportunities/?county=Kisumu'), ['Training course'])
        self.assertEqual(self.titles('/api/v1/opportunities/?county=Mombasa'), [])
        self.assertEqual(self.titles('/api/v1/support-resources/?county=Kisumu'),
                         ['Example verified resource', 'Kisumu helpline'])

    def test_text_query(self):
        self.assertEqual(self.titles('/api/v1/opportunities/?county=Nairobi&q=Public'), ['Public example job'])
        self.assertEqual(self.titles('/api/v1/opportunities/?q=zz-nothing'), [])
        self.assertEqual(self.titles('/api/v1/support-resources/?q=helpline'), ['Kisumu helpline'])

    def test_category_and_kind_filters(self):
        self.assertEqual(self.titles('/api/v1/opportunities/?category=training'), ['Training course'])
        self.assertEqual(self.titles('/api/v1/support-resources/?kind=helpline'), ['Kisumu helpline'])

    def test_unknown_category_is_rejected(self):
        response = self.client.get('/api/v1/opportunities/?category=casino')
        self.assertEqual(response.status_code, 400)
        self.assertIn('category', response.json())
        self.assertEqual(self.client.get('/api/v1/support-resources/?kind=rehab-ads').status_code, 400)

    def test_only_published_support(self):
        self.assertEqual(self.titles('/api/v1/support-resources/?county=Nairobi'), ['Example verified resource'])

    @override_settings(HATUA_VERIFICATION_MAX_AGE_DAYS=7)
    def test_verification_window_is_configurable(self):
        make_opportunity(title='Checked 10 days ago', last_verified_at=timezone.now() - timedelta(days=10))
        self.assertNotIn('Checked 10 days ago', self.titles('/api/v1/opportunities/'))

    def test_write_methods_not_allowed(self):
        for method in ('post', 'put', 'patch', 'delete'):
            response = getattr(self.client, method)('/api/v1/opportunities/')
            self.assertEqual(response.status_code, 405, method)


class PublicationRuleTests(TestCase):
    def build(self, **overrides):
        fields = {
            'title': 'Draft', 'organisation': 'Org', 'summary': 'Summary', 'category': 'job',
            'county': 'Nairobi',
        }
        fields.update(overrides)
        return Opportunity(**fields)

    def test_draft_without_provenance_is_valid(self):
        self.build().full_clean()

    def test_verified_requires_source_and_date(self):
        with self.assertRaises(ValidationError) as ctx:
            self.build(is_verified=True).full_clean()
        self.assertIn('source_url', ctx.exception.message_dict)
        self.assertIn('last_verified_at', ctx.exception.message_dict)

    def test_verification_cannot_be_future_dated(self):
        with self.assertRaises(ValidationError) as ctx:
            self.build(is_verified=True, source_url=SOURCE,
                       last_verified_at=timezone.now() + timedelta(days=1)).full_clean()
        self.assertIn('last_verified_at', ctx.exception.message_dict)

    def test_active_requires_verified(self):
        with self.assertRaises(ValidationError) as ctx:
            self.build(is_active=True).full_clean()
        self.assertIn('is_active', ctx.exception.message_dict)

    def test_unknown_county_rejected(self):
        with self.assertRaises(ValidationError) as ctx:
            self.build(county='Atlantis').full_clean()
        self.assertIn('county', ctx.exception.message_dict)

    def test_complete_record_is_valid_and_published(self):
        record = self.build(is_verified=True, is_active=True, source_url=SOURCE,
                            last_verified_at=timezone.now())
        record.full_clean()
        self.assertEqual(record.publication_status(), 'published')

    def test_publication_status_labels(self):
        now = timezone.now()
        self.assertEqual(self.build().publication_status(), 'not verified')
        self.assertEqual(self.build(is_verified=True).publication_status(), 'verification date missing')
        self.assertEqual(self.build(is_verified=True, last_verified_at=now - timedelta(days=200))
                         .publication_status(), 'verification expired')
        self.assertEqual(self.build(is_verified=True, last_verified_at=now).publication_status(),
                         'verified, not active')


class AdminWorkflowTests(TestCase):
    def setUp(self):
        self.staff = get_user_model().objects.create_superuser('reviewer', 'reviewer@example.invalid', 'pw-test-only')
        self.client.force_login(self.staff)

    def add_form(self, **overrides):
        now = timezone.localtime()
        data = {
            'title': 'Admin-entered', 'organisation': 'Org', 'summary': 'Summary', 'category': 'training',
            'county': 'Nairobi', 'eligibility': '', 'cost_label': '', 'application_url': '', 'deadline': '',
            'source_url': SOURCE, 'is_verified': 'on', 'is_active': 'on',
            'last_verified_at_0': now.strftime('%Y-%m-%d'), 'last_verified_at_1': now.strftime('%H:%M:%S'),
        }
        data.update(overrides)
        return self.client.post('/admin/directory/opportunity/add/', data)

    def test_admin_records_reviewer_on_verification(self):
        response = self.add_form()
        self.assertEqual(response.status_code, 302, response.content[:2000])
        record = Opportunity.objects.get(title='Admin-entered')
        self.assertEqual(record.verified_by, self.staff)
        self.assertEqual(record.publication_status(), 'published')

    def test_admin_refuses_verified_without_source(self):
        response = self.add_form(source_url='')
        self.assertEqual(response.status_code, 200)  # form re-rendered with errors
        self.assertFalse(Opportunity.objects.filter(title='Admin-entered').exists())

    def test_revoke_action_unpublishes_immediately(self):
        record = make_opportunity()
        self.assertEqual(len(self.client.get('/api/v1/opportunities/').json()), 1)
        response = self.client.post('/admin/directory/opportunity/', {
            'action': 'revoke', '_selected_action': [str(record.pk)],
        })
        self.assertEqual(response.status_code, 302)
        record.refresh_from_db()
        self.assertFalse(record.is_active)
        self.assertEqual(self.client.get('/api/v1/opportunities/').json(), [])

    def test_admin_changelist_and_state_filter_render(self):
        make_opportunity(title='Stale', last_verified_at=timezone.now() - timedelta(days=120))
        for state in ('', 'published', 'expired', 'unverified'):
            url = '/admin/directory/opportunity/' + (f'?state={state}' if state else '')
            self.assertEqual(self.client.get(url).status_code, 200, state)
        self.assertEqual(self.client.get('/admin/directory/supportresource/').status_code, 200)


class EnsureSuperuserCommandTests(TestCase):
    STRONG = 'correct-horse-battery-staple-91'

    def call(self, **env):
        from io import StringIO
        from unittest import mock

        from django.core.management import call_command

        out = StringIO()
        with mock.patch.dict('os.environ', env, clear=False):
            call_command('ensure_superuser', stdout=out)
        return out.getvalue()

    def test_creates_once_and_never_prints_password(self):
        output = self.call(DJANGO_SUPERUSER_USERNAME='daniel', DJANGO_SUPERUSER_PASSWORD=self.STRONG,
                           DJANGO_SUPERUSER_EMAIL='staff@example.invalid')
        user = get_user_model().objects.get(username='daniel')
        self.assertTrue(user.is_superuser and user.is_staff)
        self.assertTrue(user.check_password(self.STRONG))
        self.assertNotIn(self.STRONG, output)

    def test_existing_user_is_left_unchanged(self):
        get_user_model().objects.create_superuser('daniel', '', 'already-changed-password-77')
        output = self.call(DJANGO_SUPERUSER_USERNAME='daniel', DJANGO_SUPERUSER_PASSWORD=self.STRONG)
        self.assertIn('left unchanged', output)
        self.assertTrue(get_user_model().objects.get(username='daniel').check_password('already-changed-password-77'))

    def test_skips_without_env(self):
        output = self.call(DJANGO_SUPERUSER_USERNAME='', DJANGO_SUPERUSER_PASSWORD='')
        self.assertIn('skipped', output)
        self.assertFalse(get_user_model().objects.exists())

    def test_weak_password_is_rejected(self):
        from django.core.management.base import CommandError

        with self.assertRaises(CommandError):
            self.call(DJANGO_SUPERUSER_USERNAME='daniel', DJANGO_SUPERUSER_PASSWORD='password')
        self.assertFalse(get_user_model().objects.exists())


class IndexAndAdminPathTests(TestCase):
    def test_index_lists_public_endpoints_only(self):
        body = self.client.get('/').json()
        self.assertEqual(body['service'], 'hatua-api')
        self.assertIn('/api/v1/opportunities/', body['endpoints'])
        self.assertNotIn('admin', str(body))
