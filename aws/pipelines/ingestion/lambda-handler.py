import json
import os
import boto3
from datetime import datetime
import uuid

# --- AWS clients ---
s3 = boto3.client("s3")

# --- Env vars ---
DATA_LAKE_BUCKET = os.environ["DATA_LAKE_BUCKET"]


def fetch_data_from_source():
    """
    Simulates pulling data from an external API / SaaS (e.g. Smartsheet).
    Replace this logic with a real API call later.
    """
    return [
        {"id": 1, "name": "Alice", "value": 100},
        {"id": 2, "name": "Bob", "value": 200},
    ]


def lambda_handler(event, context):
    # --- Timestamp & pathing ---
    now = datetime.utcnow()
    date_path = now.strftime("%Y-%m-%d")
    run_id = str(uuid.uuid4())

    s3_key = f"raw/source=mock/date={date_path}/data_{run_id}.json"

    # --- Fetch data ---
    records = fetch_data_from_source()

    payload = {
        "metadata": {
            "run_id": run_id,
            "record_count": len(records),
            "ingestion_timestamp": now.isoformat()
        },
        "data": records
    }

    # --- Write to S3 ---
    s3.put_object(
        Bucket=DATA_LAKE_BUCKET,
        Key=s3_key,
        Body=json.dumps(payload),
        ContentType="application/json"
    )

    return {
        "status": "SUCCESS",
        "records_ingested": len(records),
        "s3_path": f"s3://{DATA_LAKE_BUCKET}/{s3_key}"
    }
