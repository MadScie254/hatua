"""Public directory records only. NO user health or recovery profiles in MVP."""
import uuid

from django.db import models


class PublishedRecord(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    county = models.CharField(max_length=80, db_index=True, help_text='Kenyan county or Nationwide')
    is_verified = models.BooleanField(default=False, db_index=True)
    is_active = models.BooleanField(default=False, db_index=True)
    source_url = models.URLField(max_length=500, blank=True)
    last_verified_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

    def __str__(self):
        return str(self.pk)


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
        ordering = ['-created_at']

    def __str__(self):
        return self.title


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
        ordering = ['name']

    def __str__(self):
        return self.name
