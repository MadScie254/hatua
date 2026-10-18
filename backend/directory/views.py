from django.db.models import Q
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.exceptions import ValidationError
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView

from .models import Opportunity, SupportResource
from .serializers import ListingReportSerializer, OpportunitySerializer, SupportResourceSerializer

# The app downloads each directory in one request and filters on the device (offline use, and
# the user's county never leaves the phone). Raise with care; add paging before ~500.
MAX_RESULTS = 250


@api_view(['GET'])
@permission_classes([AllowAny])
def health(request):
    return Response({'status': 'ok', 'service': 'hatua-api', 'version': 'v1'})


@api_view(['GET'])
@permission_classes([AllowAny])
def index(request):
    """Plain description of the public API. Deliberately does not reveal the admin path."""
    return Response({
        'service': 'hatua-api',
        'description': 'Public, read-only directory of verified opportunities and support resources (Kenya).',
        'endpoints': [
            '/api/v1/health/', '/api/v1/opportunities/', '/api/v1/support-resources/', '/api/v1/reports/ (POST)',
        ],
    })


class PublicDirectoryList(ListAPIView):
    """Anonymous, read-only list of published records with county/text/type filters."""

    permission_classes = (AllowAny,)
    search_fields: tuple[str, ...] = ()
    type_param = ''
    type_field = ''
    type_choices: tuple[str, ...] = ()

    def base_queryset(self):
        raise NotImplementedError

    def get_queryset(self):
        params = self.request.query_params
        qs = self.base_queryset()
        county = params.get('county', '').strip()[:80]
        query = params.get('q', '').strip()[:100]
        kind = params.get(self.type_param, '').strip()[:30]
        if county:
            qs = qs.filter(Q(county__iexact=county) | Q(county__iexact='Nationwide'))
        if kind:
            if kind not in self.type_choices:
                raise ValidationError({self.type_param: f'Must be one of: {", ".join(self.type_choices)}.'})
            qs = qs.filter(**{self.type_field: kind})
        if query:
            text = Q()
            for field in self.search_fields:
                text |= Q(**{f'{field}__icontains': query})
            qs = qs.filter(text)
        return qs[:MAX_RESULTS]


class OpportunityList(PublicDirectoryList):
    serializer_class = OpportunitySerializer
    search_fields = ('title', 'summary', 'organisation')
    type_param = type_field = 'category'
    type_choices = tuple(Opportunity.Category.values)

    def base_queryset(self):
        return Opportunity.objects.published().filter(Opportunity.open_filter())


class SupportResourceList(PublicDirectoryList):
    serializer_class = SupportResourceSerializer
    search_fields = ('name', 'description')
    type_param = type_field = 'kind'
    type_choices = tuple(SupportResource.Kind.values)

    def base_queryset(self):
        return SupportResource.objects.published()


class ListingReportCreate(APIView):
    """POST-only, anonymous "report a problem" for a published listing.

    No authentication (so no session or CSRF), no IP or device stored; throttled per client
    by the `reports` scope. Responds with a fixed body so it cannot be used to probe records.
    """

    authentication_classes = ()
    permission_classes = (AllowAny,)
    throttle_classes = (ScopedRateThrottle,)
    throttle_scope = 'reports'

    def post(self, request):
        serializer = ListingReportSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'status': 'received'}, status=status.HTTP_201_CREATED)
