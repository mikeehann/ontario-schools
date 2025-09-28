import json
import os
import boto3
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_BUCKET = os.environ.get("S3_BUCKET")
S3_KEY = os.environ.get("S3_KEY")

s3_client = boto3.client("s3")


def lambda_handler(event, context):
    """
    Generates a pre-signed URL for a private S3 object.
    """
    logger.info(f"Generating pre-signed URL for s3://{S3_BUCKET}/{S3_KEY}")

    if not S3_BUCKET or not S3_KEY:
        logger.error("Error: S3_BUCKET or S3_KEY environment variables not set.")
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "Server is not configured correctly."}),
        }

    try:
        presigned_url = s3_client.generate_presigned_url(
            "get_object", Params={"Bucket": S3_BUCKET, "Key": S3_KEY}, ExpiresIn=300
        )

        logger.info("Successfully generated pre-signed URL.")
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
            },
            "body": json.dumps({"url": presigned_url}),
        }

    except ClientError as e:
        logger.error(f"An unexpected S3 client error occurred: {e}")
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "Could not generate data URL."}),
        }
