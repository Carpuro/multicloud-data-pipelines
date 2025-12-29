import json
import os
from datetime import datetime
from google.cloud import storage
from flask import Flask, request, jsonify

app = Flask(__name__)

# Env vars
DATA_LAKE_BUCKET = os.environ.get("DATA_LAKE_BUCKET")

def process_data(records):
    """
    Data Transformation Logic
    """
    processed = []
    
    for record in records:
        # Example transformation: add processed_at timestamp and categorize budget
        processed_record = {
            **record,
            "processed_at": datetime.utcnow().isoformat(),
            "budget_category": "high" if record.get("budget_usd", 0) > 150000 else "standard",
            "days_active": calculate_days_active(record.get("start_date"), record.get("end_date"))
        }
        processed.append(processed_record)
    
    return processed

def calculate_days_active(start_date, end_date):
    """
    Calculate number of days between start_date and end_date
    """
    try:
        from datetime import datetime
        start = datetime.fromisoformat(start_date)
        end = datetime.fromisoformat(end_date)
        return (end - start).days
    except:
        return None

@app.route("/", methods=["POST"])
def transform():
    """
    principal function to transform data
    """
    try:
        # Get input path from request
        data = request.get_json()
        input_path = data.get("input_path", "").replace("gs://", "")
        
        if not input_path:
            return jsonify({"error": "input_path required"}), 400
        
        # Parse bucket and blob
        parts = input_path.split("/", 1)
        bucket_name = parts[0]
        blob_name = parts[1]
        
        # Read from GCS
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        content = blob.download_as_string()
        input_data = json.loads(content)
        
        # Process data
        records = input_data.get("data", [])
        processed_records = process_data(records)
        
        # Save to processed/
        output_blob_name = blob_name.replace("raw/", "processed/")
        output_bucket = storage_client.bucket(DATA_LAKE_BUCKET)
        output_blob = output_bucket.blob(output_blob_name)
        
        output_payload = {
            "metadata": {
                **input_data.get("metadata", {}),
                "processed_at": datetime.utcnow().isoformat(),
                "processed_count": len(processed_records)
            },
            "data": processed_records
        }
        
        output_blob.upload_from_string(
            json.dumps(output_payload),
            content_type="application/json"
        )
        
        return jsonify({
            "status": "SUCCESS",
            "records_processed": len(processed_records),
            "output_path": f"gs://{DATA_LAKE_BUCKET}/{output_blob_name}"
        }), 200
        
    except Exception as e:
        return jsonify({
            "status": "ERROR",
            "error": str(e)
        }), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))