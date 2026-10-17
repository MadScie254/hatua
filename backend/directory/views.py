from django.db.models import Q
from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from .models import Opportunity, SupportResource
from .serializers import OpportunitySerializer, SupportResourceSerializer


@api_view(['GET'])
@permission_classes([AllowAny])
def health(request):
    return Response({'status': 'ok', 'service': 'hatua-api', 'version': 'v1'})


class OpportunityList(ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = OpportunitySerializer

    def get_queryset(self):
        qs = Opportunity.objects.filter(is_active=True, is_verified=True).filter(
            Q(deadline__isnull=True) | Q(deadline__gte=timezone.localdate())
        )
        county = self.request.query_params.get('county', '').strip()[:80]
        query = self.request.query_params.get('q', '').strip()[:100]
        if county:
            qs = qs.filter(Q(county__iexact=county) | Q(county__iexact='Nationwide'))
        if query:
            qs = qs.filter(Q(title__icontains=query) | Q(summary__icontains=query) | Q(organisation__icontains=query))
        return qs[:100]


class SupportResourceList(ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = SupportResourceSerializer

    def get_queryset(self):
        qs = SupportResource.objects.filter(is_active=True, is_verified=True)
        county = self.request.query_params.get('county', '').strip()[:80]
        query = self.request.query_params.get('q', '').strip()[:100]
        if county:
            qs = qs.filter(Q(county__iexact=county) | Q(county__iexact='Nationwide'))
        if query:
            qs = qs.filter(Q(name__icontains=query) | Q(description__icontains=query))
        return qs[:100]
