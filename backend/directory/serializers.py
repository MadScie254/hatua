from rest_framework import serializers

from .models import ListingReport, Opportunity, SupportResource


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


class ListingReportSerializer(serializers.Serializer):
    """Write-only input for POST /api/v1/reports/. Only published records can be reported."""

    record_type = serializers.ChoiceField(choices=ListingReport.RecordType.choices)
    record_id = serializers.UUIDField()
    reason = serializers.ChoiceField(choices=ListingReport.Reason.choices)
    note = serializers.CharField(
        max_length=ListingReport.MAX_NOTE, required=False, allow_blank=True, trim_whitespace=True,
    )

    def validate(self, attrs):
        if attrs['record_type'] == ListingReport.RecordType.OPPORTUNITY:
            record = Opportunity.objects.published().filter(id=attrs['record_id']).first()
            label = record.title if record else ''
        else:
            record = SupportResource.objects.published().filter(id=attrs['record_id']).first()
            label = record.name if record else ''
        if record is None:
            raise serializers.ValidationError({'record_id': 'No published listing with this id.'})
        attrs['record_label'] = label
        return attrs

    def create(self, validated_data):
        return ListingReport.objects.create(**validated_data)
