"""Staff-only curation. This is NOT a partner dashboard; partners never get Admin access."""
from django.contrib import admin, messages
from django.utils import timezone

from .models import Opportunity, SupportResource, verification_max_age


class VerificationStateFilter(admin.SimpleListFilter):
    title = 'publication state'
    parameter_name = 'state'

    def lookups(self, request, model_admin):
        return (
            ('published', 'Published now'),
            ('expired', 'Verification expired'),
            ('unverified', 'Not verified'),
        )

    def queryset(self, request, queryset):
        now = timezone.now()
        if self.value() == 'published':
            return queryset.published(now)
        if self.value() == 'expired':
            return queryset.filter(is_verified=True, last_verified_at__lte=now - verification_max_age())
        if self.value() == 'unverified':
            return queryset.filter(is_verified=False)
        return queryset


@admin.action(description='Revoke now: unpublish selected records (urgent removals)')
def revoke(modeladmin, request, queryset):
    count = queryset.update(is_active=False, updated_at=timezone.now())
    modeladmin.message_user(request, f'{count} record(s) removed from the public API.', messages.WARNING)


class PublishedRecordAdmin(admin.ModelAdmin):
    actions = (revoke,)
    readonly_fields = ('verified_by', 'verification_expires_at', 'created_at', 'updated_at')
    list_filter = (VerificationStateFilter, 'county', 'is_verified', 'is_active')

    @admin.display(description='State')
    def state(self, obj):
        return obj.publication_status()

    def save_model(self, request, obj, form, change):
        # Record WHO verified, whenever the verification itself changes. Model.clean() already
        # refused a verified record without source_url/last_verified_at.
        verification_changed = not change or {'is_verified', 'last_verified_at', 'source_url'} & set(
            form.changed_data
        )
        if obj.is_verified and verification_changed:
            obj.verified_by = request.user
        if not obj.is_verified:
            obj.verified_by = None
        super().save_model(request, obj, form, change)


@admin.register(Opportunity)
class OpportunityAdmin(PublishedRecordAdmin):
    list_display = ('title', 'organisation', 'county', 'category', 'state', 'deadline', 'last_verified_at')
    list_filter = (*PublishedRecordAdmin.list_filter, 'category')
    search_fields = ('title', 'organisation', 'summary')


@admin.register(SupportResource)
class SupportResourceAdmin(PublishedRecordAdmin):
    list_display = ('name', 'kind', 'county', 'state', 'last_verified_at')
    list_filter = (*PublishedRecordAdmin.list_filter, 'kind')
    search_fields = ('name', 'description')
