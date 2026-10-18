"""Public directory records only. NO user health or recovery profiles in MVP."""
import uuid
from datetime import timedelta

from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models import Q
from django.utils import timezone

from .counties import COUNTY_CHOICES


def verification_max_age() -> timedelta:
    """How long a verification stays valid before the record silently drops out of the API."""
    return timedelta(days=settings.HATUA_VERIFICATION_MAX_AGE_DAYS)


class PublishedQuerySet(models.QuerySet):
    def published(self, now=None):
        """The ONLY definition of what the public API may show.

        Verified AND active AND verified recently (not in the future, not older than
        HATUA_VERIFICATION_MAX_AGE_DAYS). A record without a verification date is never public.
        """
        now = now or timezone.now()
        return self.filter(
            is_verified=True,
            is_active=True,
            last_verified_at__isnull=False,
            last_verified_at__lte=now,
            last_verified_at__gt=now - verification_max_age(),
        )


class PublishedRecord(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    county = models.CharField(
        max_length=80, db_index=True, choices=COUNTY_CHOICES,
        help_text='Kenyan county or Nationwide',
    )
    is_verified = models.BooleanField(
        default=False, db_index=True,
        help_text='Tick only after checking the source yourself. Requires a source URL and verification time.',
    )
    is_active = models.BooleanField(
        default=False, db_index=True,
        help_text='Shown publicly only while verified and the verification is recent. Untick to revoke at once.',
    )
    source_url = models.URLField(
        max_length=500, blank=True,
        help_text='Official page or written confirmation used as evidence. Shown to users as "Verify source".',
    )
    last_verified_at = models.DateTimeField(
        null=True, blank=True,
        help_text='When a staff member last confirmed the details against the source.',
    )
    verified_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, editable=False,
        on_delete=models.SET_NULL, related_name='+',
        help_text='Staff account that last verified this record. Internal only; never exposed by the API.',
    )
    verification_note = models.CharField(
        max_length=240, blank=True,
        help_text='Internal: how the source was checked, e.g. "phoned the centre" or a desk check. '
                  'Cleared when staff re-verify unless you edit it. Never exposed by the API.',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = PublishedQuerySet.as_manager()

    class Meta:
        abstract = True

    def __str__(self):
        return str(self.pk)

    @property
    def verification_expires_at(self):
        if self.last_verified_at is None:
            return None
        return self.last_verified_at + verification_max_age()

    def publication_status(self, now=None) -> str:
        now = now or timezone.now()
        if not self.is_verified:
            return 'not verified'
        if self.last_verified_at is None or self.last_verified_at > now:
            return 'verification date missing'
        if self.last_verified_at <= now - verification_max_age():
            return 'verification expired'
        if not self.is_active:
            return 'verified, not active'
        return 'published'

    def clean(self):
        super().clean()
        errors = {}
        if self.is_verified:
            if not self.source_url:
                errors['source_url'] = 'A source URL is required before a record can be marked verified.'
            if self.last_verified_at is None:
                errors['last_verified_at'] = 'Record when you checked the source before marking it verified.'
            elif self.last_verified_at > timezone.now() + timedelta(minutes=5):
                errors['last_verified_at'] = 'Verification time cannot be in the future.'
        if self.is_active and not self.is_verified:
            errors['is_active'] = 'Verify the record before activating it.'
        if errors:
            raise ValidationError(errors)


class Opportunity(PublishedRecord):
    class Category(models.TextChoices):
        JOB = 'job', 'Employment'
        TRAINING = 'training', 'Training'
        GRANT = 'grant', 'Grant / financial assistance'
        APPRENTICESHIP = 'apprenticeship', 'Apprenticeship'
        OTHER = 'other', 'Other'

    title = models.CharField(max_length=180)
    organisation = models.CharField(max_length=160)
    summary = models.TextField()
    category = models.CharField(max_length=20, choices=Category.choices)
    eligibility = models.TextField(blank=True)
    cost_label = models.CharField(max_length=80, blank=True)
    application_url = models.URLField(max_length=500, blank=True)
    deadline = models.DateField(null=True, blank=True)

    class Meta:
        ordering = ('-created_at',)
        verbose_name_plural = 'opportunities'

    def __str__(self):
        return self.title

    @classmethod
    def open_filter(cls, today=None) -> Q:
        today = today or timezone.localdate()
        return Q(deadline__isnull=True) | Q(deadline__gte=today)


class SupportResource(PublishedRecord):
    class Kind(models.TextChoices):
        HELPLINE = 'helpline', 'Helpline'
        FACILITY = 'facility', 'Treatment facility'
        NGO = 'ngo', 'Support organisation'
        EDUCATION = 'education', 'Education resource'

    name = models.CharField(max_length=180)
    description = models.TextField()
    kind = models.CharField(max_length=20, choices=Kind.choices)
    phone = models.CharField(max_length=35, blank=True)
    website_url = models.URLField(max_length=500, blank=True)
    location_label = models.CharField(max_length=180, blank=True)

    class Meta:
        ordering = ('name',)

    def __str__(self):
        return self.name


class SeedBatch(models.Model):
    """A curated batch from directory/seed/ that `load_directory_seed` has applied.

    Each batch is applied at most once per database, so records staff later edit, revoke or
    delete are never recreated by a later deploy.
    """

    name = models.CharField(max_length=120, unique=True)
    applied_at = models.DateTimeField(auto_now_add=True)
    opportunities_created = models.PositiveIntegerField(default=0)
    resources_created = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ('-applied_at',)

    def __str__(self):
        return self.name


class ListingReport(models.Model):
    """A user's report that a PUBLIC listing is wrong, broken or suspicious.

    Deliberately minimal: no account, IP address, device or contact details are stored. The
    optional note is shown only to staff and purged with the report (see purge_reports).
    """

    class RecordType(models.TextChoices):
        OPPORTUNITY = 'opportunity', 'Opportunity'
        SUPPORT_RESOURCE = 'support_resource', 'Support resource'

    class Reason(models.TextChoices):
        BROKEN_LINK = 'broken_link', 'Link does not work'
        WRONG_CONTACT = 'wrong_contact', 'Phone number or address is wrong'
        CLOSED = 'closed', 'Closed, full or no longer offered'
        SUSPECTED_SCAM = 'suspected_scam', 'Looks like a scam or asks for money'
        OTHER = 'other', 'Something else is wrong'

    class Status(models.TextChoices):
        NEW = 'new', 'New'
        ACTIONED = 'actioned', 'Fixed or revoked'
        DISMISSED = 'dismissed', 'Checked, no change needed'

    MAX_NOTE = 300

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    record_type = models.CharField(max_length=20, choices=RecordType.choices)
    record_id = models.UUIDField(db_index=True)
    record_label = models.CharField(max_length=180, help_text='Title or name when the report was made.')
    reason = models.CharField(max_length=20, choices=Reason.choices)
    note = models.CharField(max_length=MAX_NOTE, blank=True)
    status = models.CharField(max_length=12, choices=Status.choices, default=Status.NEW, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, editable=False,
        on_delete=models.SET_NULL, related_name='+',
    )

    class Meta:
        ordering = ('-created_at',)

    def __str__(self):
        return f'{self.get_reason_display()}: {self.record_label}'
