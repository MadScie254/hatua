"""Apply curated directory batches from directory/seed/*.json, each at most once per database.

A batch is a reviewed set of public listings with provenance: every record carries the
official source URL that was checked, and the batch says when and how (`checked_at`,
`verification_note`). Records are created verified and active, so they appear in the public
API until their verification expires (HATUA_VERIFICATION_MAX_AGE_DAYS) or staff revoke them.

Applied batches are recorded in SeedBatch. A later run (every production deploy runs this
command) skips them, so records that staff edit, revoke or delete are never recreated.
Record IDs are derived from each record's `key`, so the same batch gives the same IDs in every
database (bookmarks keep working).

    python manage.py load_directory_seed            # apply new batches
    python manage.py load_directory_seed --dry-run  # validate only, write nothing
"""
import json
import uuid
from datetime import datetime
from pathlib import Path

from django.core.exceptions import ValidationError
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from directory.models import Opportunity, SeedBatch, SupportResource

SEED_DIR = Path(__file__).resolve().parents[2] / 'seed'
ID_NAMESPACE = uuid.UUID('6f1c2b8e-1d0a-4c55-9f53-7a8d2b0e4c11')

OPPORTUNITY_FIELDS = (
    'title', 'organisation', 'summary', 'category', 'county', 'eligibility', 'cost_label',
    'application_url', 'source_url', 'deadline',
)
RESOURCE_FIELDS = (
    'name', 'description', 'kind', 'county', 'phone', 'website_url', 'location_label', 'source_url',
)


def record_id(batch_name: str, key: str) -> uuid.UUID:
    return uuid.uuid5(ID_NAMESPACE, f'{batch_name}/{key}')


class Command(BaseCommand):
    help = 'Apply curated public directory batches from directory/seed/ (each batch once).'

    def add_arguments(self, parser):
        parser.add_argument('--dry-run', action='store_true', help='Validate every batch; write nothing.')
        parser.add_argument('--seed-dir', default=str(SEED_DIR), help='Directory of batch JSON files.')

    def handle(self, *args, dry_run=False, seed_dir=str(SEED_DIR), **options):
        paths = sorted(Path(seed_dir).glob('*.json'))
        if not paths:
            self.stdout.write('load_directory_seed: no batches found.')
            return
        for path in paths:
            self.apply(path, dry_run=dry_run)

    def apply(self, path: Path, *, dry_run: bool) -> None:
        batch = json.loads(path.read_text(encoding='utf-8'))
        name = batch['name']
        if SeedBatch.objects.filter(name=name).exists():
            self.stdout.write(f'load_directory_seed: {name} already applied; skipping.')
            return
        checked_at = datetime.fromisoformat(batch['checked_at'])
        if checked_at.tzinfo is None:
            raise CommandError(f'{path.name}: checked_at must include a UTC offset.')
        common = {
            'is_verified': True,
            'is_active': True,
            'last_verified_at': checked_at,
            'verification_note': batch.get('verification_note', '')[:240],
        }
        opportunities = [
            self.build(Opportunity, name, item, OPPORTUNITY_FIELDS, common)
            for item in batch.get('opportunities', [])
        ]
        resources = [
            self.build(SupportResource, name, item, RESOURCE_FIELDS, common)
            for item in batch.get('support_resources', [])
        ]
        keys = [item['key'] for item in batch.get('opportunities', []) + batch.get('support_resources', [])]
        if len(keys) != len(set(keys)):
            raise CommandError(f'{path.name}: duplicate record keys.')
        if dry_run:
            self.stdout.write(
                f'load_directory_seed: {name} is valid ({len(opportunities)} opportunities, '
                f'{len(resources)} support resources); dry run, nothing written.'
            )
            return
        with transaction.atomic():
            created_opps = self.create_missing(Opportunity, opportunities)
            created_res = self.create_missing(SupportResource, resources)
            SeedBatch.objects.create(
                name=name, opportunities_created=created_opps, resources_created=created_res,
            )
        self.stdout.write(self.style.SUCCESS(
            f'load_directory_seed: applied {name}: {created_opps} opportunities, {created_res} support resources.'
        ))

    def build(self, model, batch_name, item, fields, common):
        unknown = set(item) - set(fields) - {'key'}
        if unknown:
            raise CommandError(f'{batch_name}/{item.get("key")}: unknown fields {sorted(unknown)}')
        obj = model(id=record_id(batch_name, item['key']), **common, **{f: item.get(f) or '' for f in fields})
        if model is Opportunity and not item.get('deadline'):
            obj.deadline = None
        try:
            obj.full_clean()
        except ValidationError as exc:
            raise CommandError(f'{batch_name}/{item["key"]}: {exc.message_dict}') from exc
        return obj

    @staticmethod
    def create_missing(model, objects) -> int:
        existing = set(model.objects.filter(id__in=[o.id for o in objects]).values_list('id', flat=True))
        new = [o for o in objects if o.id not in existing]
        model.objects.bulk_create(new)
        return len(new)
