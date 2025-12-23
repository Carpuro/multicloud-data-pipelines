import boto3
import json
import os

s3 = boto3.client("s3")

BUCKET = os.environ["DATA_LAKE_BUCKET"]
INPUT_PREFIX = "raw/"
OUTPUT_PREFIX = "processed/"


def main():
    response = s3.list_objects_v2(Bucket=BUCKET, Prefix=INPUT_PREFIX)
    objects = response.get("Contents", [])

    transformed = []

    for obj in objects:
        body = s3.get_object(Bucket=BUCKET, Key=obj["Key"])["Body"].read()
        payload = json.loads(body)
        for record in payload["data"]:
            record["budget_eur"] = round(record["budget_usd"] * 0.92, 2)
            transformed.append(record)

    output_key = f"{OUTPUT_PREFIX}transformed_data.json"

    s3.put_object(
        Bucket=BUCKET,
        Key=output_key,
        Body=json.dumps(transformed),
        ContentType="application/json"
    )

    print(f"Processed {len(transformed)} records")


if __name__ == "__main__":
    main()
