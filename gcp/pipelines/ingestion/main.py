import json
import os
from datetime import datetime
from google.cloud import storage
import uuid
import functions_framework

# Env vars
DATA_LAKE_BUCKET = os.environ.get("DATA_LAKE_BUCKET")

def fetch_data_from_source():
    """
    This function simulates pulling data from an external API.
    """
    return [
        {
            "record_id": "CNTR-001",
            "project_name": "IT Modernization",
            "owner": "alice.smith@company.com",
            "status": "Active",
            "budget_usd": 125000,
            "start_date": "2024-01-15",
            "end_date": "2024-12-31",
            "last_updated": "2025-01-10T14:32:00Z",
            "region": "NA",
            "metadata": {
                "source_system": "smartsheet",
                "version": 3
            }
        },
        {
            "record_id": "CNTR-002",
            "project_name": "Cloud Migration",
            "owner": "bob.jones@company.com",
            "status": "Delayed",
            "budget_usd": 300000,
            "start_date": "2023-09-01",
            "end_date": "2025-03-31",
            "last_updated": "2025-01-09T09:10:00Z",
            "region": "EU",
            "metadata": {
                "source_system": "smartsheet",
                "version": 5
            }
        },
        {
            "record_id": "CNTR-003",
            "project_name": "Data Platform Revamp",
            "owner": "carla.mendez@company.com",
            "status": "Completed",
            "budget_usd": 85000,
            "start_date": "2023-05-01",
            "end_date": "2024-04-30",
            "last_updated": "2024-05-02T11:45:00Z",
            "region": "LATAM",
            "metadata": {
                "source_system": "smartsheet",
                "version": 2
            }
        },
        {
            "record_id": "CNTR-004",
            "project_name": "Security Hardening",
            "owner": "daniel.lee@company.com",
            "status": "Active",
            "budget_usd": 150000,
            "start_date": "2024-06-01",
            "end_date": "2025-06-30",
            "last_updated": "2025-01-11T08:20:00Z",
            "region": "APAC",
            "metadata": {
                "source_system": "smartsheet",
                "version": 4
            }
        },
        {
            "record_id": "CNTR-005",
            "project_name": "AI Enablement",
            "owner": "elena.rossi@company.com",
            "status": "On Hold",
            "budget_usd": 200000,
            "start_date": "2024-03-10",
            "end_date": "2025-12-15",
            "last_updated": "2025-01-08T16:05:00Z",
            "region": "NA",
            "metadata": {
                "source_system": "smartsheet",
                "version": 1
            }
        }
    ]

@functions_framework.http
def ingest_data(request):
    """
    Cloud Function entry point
    """
    # Timestamp & pathing
    now = datetime.utcnow()
    date_path = now.strftime("%Y-%m-%d")
    run_id = str(uuid.uuid4())
    
    blob_name = f"raw/source=mock/date={date_path}/data_{run_id}.json"
    
    # Fetch data
    records = fetch_data_from_source()
    
    payload = {
        "metadata": {
            "run_id": run_id,
            "record_count": len(records),
            "ingestion_timestamp": now.isoformat()
        },
        "data": records
    }
    
    # Write to GCS
    storage_client = storage.Client()
    bucket = storage_client.bucket(DATA_LAKE_BUCKET)
    blob = bucket.blob(blob_name)
    blob.upload_from_string(
        json.dumps(payload),
        content_type="application/json"
    )
    
    return {
        "status": "SUCCESS",
        "records_ingested": len(records),
        "gcs_path": f"gs://{DATA_LAKE_BUCKET}/{blob_name}"
    }, 200