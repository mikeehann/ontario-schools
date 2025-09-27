#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# You can find these by running 'terraform output' in your terraform directory.

# export S3_PUBLIC_BUCKET="your-name"
# export S3_PRIVATE_BUCKET="your-name"
PUBLIC_BUCKET_NAME="${S3_PUBLIC_BUCKET?Error: S3_PUBLIC_BUCKET environment variable is not set.}"
PRIVATE_BUCKET_NAME="${S3_PRIVATE_BUCKET?Error: S3_PRIVATE_BUCKET environment variable is not set.}"


# --- 1. Build Frontend Assets ---
echo "▶️  Running the build script..."
./build.sh


# --- 2. Upload Public Website Files ---
echo "⬆️  Uploading public files to s3://${PUBLIC_BUCKET_NAME}..."
aws s3 sync dist/ "s3://${PUBLIC_BUCKET_NAME}" --delete


# --- 3. Upload Private Data File ---
echo "⬆️  Uploading private data file to s3://${PRIVATE_BUCKET_NAME}..."
aws s3 cp static/ontario_schools.geojson "s3://${PRIVATE_BUCKET_NAME}/ontario_schools.geojson"


# --- 4. Invalidate CloudFront Cache ---
echo "♻️  Invalidating CloudFront cache..."
# Get the CloudFront distribution ID from Terraform's output
DISTRIBUTION_ID=$(cd terraform && terraform output cloudfront_distribution_id | tr -d '"')

if [ -z "$DISTRIBUTION_ID" ]; then
    echo "⚠️  Could not find CloudFront Distribution ID from Terraform output."
else
    # Create an invalidation for all files
    aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"
    echo "✅ CloudFront invalidation created."
fi


echo -e "\n🚀 Deployment complete!"