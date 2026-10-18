"""Staff-only curation. This is NOT a partner dashboard; partners never get Admin access."""
from django.contrib import admin, messages
from django.urls import reverse
from django.utils import timezone
from django.utils.html import format_html

from .models import ListingReport, Opportunity, SeedBatch, SupportResource, verification_max_age


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
            if 'verification_note' not in form.changed_data:
                # A new check by this staff member replaces the earlier one (e.g. a desk check).
                obj.verification_note = ''
        if not obj.is_verified:
            obj.verified_by = None
        super().save_model(request, obj, form, change)


    @admin.display(description='Open reports')
    def open_reports(self, obj):
        return ListingReport.objects.filter(record_id=obj.id, status=ListingReport.Status.NEW).count() or ''


@admin.register(Opportunity)
class OpportunityAdmin(PublishedRecordAdmin):
    list_display = (
        'title', 'organisation', 'county', 'category', 'state', 'deadline', 'last_verified_at', 'open_reports',
    )
    list_filter = (*PublishedRecordAdmin.list_filter, 'category')
    search_fields = ('title', 'organisation', 'summary')


@admin.register(SupportResource)
class SupportResourceAdmin(PublishedRecordAdmin):
    list_display = ('name', 'kind', 'county', 'state', 'last_verified_at', 'open_reports')
    list_filter = (*PublishedRecordAdmin.list_filter, 'kind')
    search_fields = ('name', 'description')


def _set_report_status(request, queryset, status):
    return queryset.update(status=status, reviewed_by=request.user, reviewed_at=timezone.now())


@admin.action(description='Mark fixed or revoked (I changed or removed the listing)')
def mark_actioned(modeladmin, request, queryset):
    count = _set_report_status(request, queryset, ListingReport.Status.ACTIONED)
    modeladmin.message_user(request, f'{count} report(s) marked fixed or revoked.')


@admin.action(description='Mark checked, no change needed')
def mark_dismissed(modeladmin, request, queryset):
    count = _set_report_status(request, queryset, ListingReport.Status.DISMISSED)
    modeladmin.message_user(request, f'{count} report(s) dismissed.')


@admin.register(ListingReport)
class ListingReportAdmin(admin.ModelAdmin):
    """Moderation queue for user reports. Revoke the listing itself from its own page."""

    actions = (mark_actioned, mark_dismissed)
    list_display = ('created_at', 'reason', 'record_label', 'record_type', 'status', 'reviewed_by')
    list_filter = ('status', 'reason', 'record_type')
    search_fields = ('record_label', 'note')
    readonly_fields = (
        'record_type', 'record_id', 'record_label', 'listing_link', 'reason', 'note',
        'created_at', 'reviewed_at', 'reviewed_by',
    )
    fields = readonly_fields[:4] + ('reason', 'note', 'status', 'created_at', 'reviewed_at', 'reviewed_by')

    def has_add_permission(self, request):
        return False

    @admin.display(description='Listing')
    def listing_link(self, obj):
        model = 'opportunity' if obj.record_type == ListingReport.RecordType.OPPORTUNITY else 'supportresource'
        url = reverse(f'admin:directory_{model}_change', args=[obj.record_id])
        return format_html('<a href="{}">Open the listing to fix or revoke it</a>', url)

    def save_model(self, request, obj, form, change):
        if 'status' in form.changed_data:
            obj.reviewed_by = request.user
            obj.reviewed_at = timezone.now()
        super().save_model(request, obj, form, change)


@admin.register(SeedBatch)
class SeedBatchAdmin(admin.ModelAdmin):
    list_display = ('name', 'applied_at', 'opportunities_created', 'resources_created')
    readonly_fields = list_display

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False
