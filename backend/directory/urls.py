from django.urls import path

from .views import ListingReportCreate, OpportunityList, SupportResourceList

urlpatterns = [
    path('opportunities/', OpportunityList.as_view(), name='opportunity-list'),
    path('support-resources/', SupportResourceList.as_view(), name='support-resource-list'),
    path('reports/', ListingReportCreate.as_view(), name='listing-report-create'),
]
