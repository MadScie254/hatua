from django.conf import settings
from django.contrib import admin
from django.urls import include, path

from directory.views import health, index

admin.site.site_header = 'HATUA staff curation'
admin.site.site_title = 'HATUA staff'
admin.site.index_title = 'Verify and publish directory entries'

urlpatterns = [
    path('', index, name='index'),
    path(settings.ADMIN_URL, admin.site.urls),
    path('api/v1/health/', health, name='health'),
    path('api/v1/', include('directory.urls')),
]
