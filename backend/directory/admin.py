from django.contrib import admin
from .models import Opportunity, SupportResource


@admin.register(Opportunity)
class OpportunityAdmin(admin.ModelAdmin):
    list_display = ('title', 'organisation', 'county', 'category', 'is_verified', 'is_active', 'last_verified_at')
    list_filter = ('category', 'county', 'is_verified', 'is_active')
    search_fields = ('title', 'organisation', 'summary')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(SupportResource)
class SupportResourceAdmin(admin.ModelAdmin):
    list_display = ('name', 'kind', 'county', 'is_verified', 'is_active', 'last_verified_at')
    list_filter = ('kind', 'county', 'is_verified', 'is_active')
    search_fields = ('name', 'description')
    readonly_fields = ('created_at', 'updated_at')
