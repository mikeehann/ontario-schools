import json
import boto3
import os

# Get bucket and key from environment variables
S3_BUCKET = os.environ['S3_BUCKET']
S3_KEY = os.environ['S3_KEY']

s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        s3_object = s3.get_object(Bucket=S3_BUCKET, Key=S3_KEY)
        geojson_data = s3_object['Body'].read().decode('utf-8')

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*', # CORS
                'Content-Type': 'application/json'
            },
            'body': geojson_data
        }
    except Exception as e:
        print(e)
        return {'statusCode': 500, 'body': json.dumps('Error fetching GeoJSON')}