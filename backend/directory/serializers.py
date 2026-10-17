from rest_framework import serializers
from .models import Opportunity, SupportResource


class OpportunitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Opportunity
        fields = [
            'id', 'title', 'organisation', 'summary', 'category', 'county',
            'eligibility', 'cost_label', 'application_url', 'source_url',
            'deadline', 'last_verified_at',
        ]


class SupportResourceSerializer(serializers.ModelSerializer):
    class Meta:
        model = SupportResource
        fields = [
            'id', 'name', 'description', 'kind', 'county', 'phone',
            'website_url', 'location_label', 'source_url', 'last_verified_at',
        ]
