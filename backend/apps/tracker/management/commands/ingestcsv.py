
from django.core.management.base import BaseCommand
from django.apps import apps
import csv

# ingests CSV into database for testing purposes
# args: CSV filename, specified model


class Command(BaseCommand):
    help = "Import a CSV file into the database to populate static tables. CSV header must match model field names."

    def add_arguments(self, parser):
        parser.add_argument("filename", type=str)
        parser.add_argument("model", type=str, choices=["Hero", "ShopItem", "Ability"])

    def handle(self, *args, **options):
        filename = options["filename"]
        model_name = options["model"]

        Model = apps.get_model("tracker", model_name)

        with open(filename, newline="") as f:
            reader = csv.DictReader(f)
            objs = [Model(**row) for row in reader]

        Model.objects.bulk_create(objs)

        self.stdout.write(self.style.SUCCESS(f"inserted {len(objs)} rows into tracker.{model_name}"))
