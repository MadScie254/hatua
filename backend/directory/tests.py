from datetime import timedelta
from django.test import TestCase
from django.utils import timezone
from .models import Opportunity, SupportResource


class PublicDirectoryTests(TestCase):
    def setUp(self):
        self.public_job = Opportunity.objects.create(
            title='Public example job', organisation='Example Organisation',
            summary='Example for testing only', category='job', county='Nairobi',
            is_verified=True, is_active=True,
        )
        self.draft_job = Opportunity.objects.create(
            title='Hidden draft', organisation='Unverified Source', summary='Not available',
            category='job', county='Nairobi', is_verified=False, is_active=True,
        )
        self.expired_job = Opportunity.objects.create(
            title='Expired test', organisation='Example Organisation', summary='Expired',
            category='job', county='Nationwide', is_verified=True, is_active=True,
            deadline=timezone.localdate() - timedelta(days=1),
        )
        self.public_support = SupportResource.objects.create(
            name='Example verified resource', description='A test resource, not a real service',
            kind='ngo', county='Nationwide', is_verified=True, is_active=True,
        )
        self.draft_support = SupportResource.objects.create(
            name='Unpublished facility', description='Do not display', kind='facility',
            county='Nairobi', is_verified=True, is_active=False,
        )

    def test_health(self):
        response = self.client.get('/api/v1/health/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')

    def test_only_verified_active_unexpired_opportunities(self):
        response = self.client.get('/api/v1/opportunities/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json()), 1)
        self.assertEqual(response.json()[0]['title'], 'Public example job')
        self.assertNotIn('is_verified', response.json()[0])

    def test_county_and_query_filter(self):
        self.assertEqual(len(self.client.get('/api/v1/opportunities/?county=Kisumu').json()), 0)
        self.assertEqual(len(self.client.get('/api/v1/opportunities/?county=Nairobi&q=Public').json()), 1)
        self.assertEqual(len(self.client.get('/api/v1/opportunities/?q=zz-nothing').json()), 0)

    def test_only_verified_active_support(self):
        response = self.client.get('/api/v1/support-resources/?county=Nairobi')
        self.assertEqual(response.status_code, 200)
        self.assertEqual([v['name'] for v in response.json()], ['Example verified resource'])

    def test_post_is_not_allowed(self):
        self.assertEqual(self.client.post('/api/v1/opportunities/', {}).status_code, 405)
