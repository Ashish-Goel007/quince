import boto3
from botocore.exceptions import ClientError

# S3 Bucket with Public Access
s3 = boto3.client('s3')

list_bucket = s3.list_buckets()['Buckets'] # List all S3 Buckets
for bucket in list_bucket:
    response = s3.get_public_access_block(Bucket=bucket['Name']) #Get Public Settings of S3 bucket
    S3PublicAccess = response['PublicAccessBlockConfiguration']
    if(S3PublicAccess['BlockPublicAcls'] == False or S3PublicAccess['IgnorePublicAcls'] == False or S3PublicAccess['BlockPublicPolicy'] == False or S3PublicAccess['RestrictPublicBuckets'] == False):
        print("Bucket {} has public access".format(bucket['Name']))