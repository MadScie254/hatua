# Initial schema authored for HATUA bootstrap. Validate using makemigrations --check.
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True
    dependencies = []

    operations = [
        migrations.CreateModel(
            name='Opportunity',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('county', models.CharField(db_index=True, help_text='Kenyan county or Nationwide', max_length=80)),
                ('is_verified', models.BooleanField(db_index=True, default=False)),
                ('is_active', models.BooleanField(db_index=True, default=False)),
                ('source_url', models.URLField(blank=True, max_length=500)),
                ('last_verified_at', models.DateTimeField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('title', models.CharField(max_length=180)),
                ('organisation', models.CharField(max_length=160)),
                ('summary', models.TextField()),
                ('category', models.CharField(choices=[('job', 'Employment'), ('training', 'Training'), ('grant', 'Grant / financial assistance'), ('apprenticeship', 'Apprenticeship'), ('other', 'Other')], max_length=20)),
                ('eligibility', models.TextField(blank=True)),
                ('cost_label', models.CharField(blank=True, max_length=80)),
                ('application_url', models.URLField(blank=True, max_length=500)),
                ('deadline', models.DateField(blank=True, null=True)),
            ],
            options={'ordering': ['-created_at']},
        ),
        migrations.CreateModel(
            name='SupportResource',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('county', models.CharField(db_index=True, help_text='Kenyan county or Nationwide', max_length=80)),
                ('is_verified', models.BooleanField(db_index=True, default=False)),
                ('is_active', models.BooleanField(db_index=True, default=False)),
                ('source_url', models.URLField(blank=True, max_length=500)),
                ('last_verified_at', models.DateTimeField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('name', models.CharField(max_length=180)),
                ('description', models.TextField()),
                ('kind', models.CharField(choices=[('helpline', 'Helpline'), ('facility', 'Treatment facility'), ('ngo', 'Support organisation'), ('education', 'Education resource')], max_length=20)),
                ('phone', models.CharField(blank=True, max_length=35)),
                ('website_url', models.URLField(blank=True, max_length=500)),
                ('location_label', models.CharField(blank=True, max_length=180)),
            ],
            options={'ordering': ['name']},
        ),
    ]
