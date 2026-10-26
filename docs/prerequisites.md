# Place image in ECR
1. Open cloud shell
2. Create ECR repo and login:
    ```bash
    REGION=eu-west-1
    AccountID=xxxxxxxxxxxx
    
    aws ecr create-repository --repository-name wiki \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

    aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin \
    $AccountID.dkr.ecr.$REGION.amazonaws.com
    ```
3. Pull and tag the image:
    ```bash
    docker pull ghcr.io/requarks/wiki:2.5.312
    docker tag ghcr.io/requarks/wiki:2.5.312 $AccountID.dkr.ecr.$REGION.amazonaws.com/wiki:2.5.312
    ```
3. Push the image:
    ```bash
    docker push $AccountID.dkr.ecr.$REGION.amazonaws.com/wiki:2.5.312
    ```
# Upload wikijs.env to S3 and enable versioning

1. Create bucket:
    ```bash
    BUCKET_NAME=wikijs-on-ecs-goland10
    aws s3 mb s3://${BUCKET_NAME} --region $REGION
    ```
2. Enable versioning on the bucket for quick state file error recovery:
    ```bash
    aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} \
    --versioning-configuration Status=Enabled

    ```
3. Upload file to bucket:
    ```bash
    aws s3 cp wikijs.env s3://${BUCKET_NAME}/wikijs.env
    ```
# Delete Prerequisites

1. Delete ECR repo
    ```bash
    REGION=eu-west-1
    
    aws ecr delete-repository \
    --repository-name wiki \
    --region $REGION \
    --force
    ```
2. Delete bucket
    ```bash
    BUCKET_NAME=wikijs-on-ecs-goland10
    
    aws s3api delete-objects \
    --bucket $BUCKET_NAME \
    --delete "$(aws s3api list-object-versions \
        --bucket  $BUCKET_NAME \
        --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
        --output json)"

    aws s3api delete-objects \
    --bucket $BUCKET_NAME \
    --delete "$(aws s3api list-object-versions \
        --bucket $BUCKET_NAME \
        --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
        --output json)"

    aws s3 rb s3://$BUCKET_NAME --region $REGION
    ```