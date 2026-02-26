# Place image in ECR
1. Open cloud shell
2. Create ECR repo and login:
    ```bash
    AccountID=xxxxxxxxxxxx
    region=eu-west-1

    aws ecr create-repository --repository-name wiki \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256
    aws ecr get-login-password --region $region | \
    docker login --username AWS --password-stdin \
    $AccountID.dkr.ecr.$region.amazonaws.com
    ```
3. Pull and tag the image:
    ```bash
    docker pull ghcr.io/requarks/wiki:2.5.312
    docker tag ghcr.io/requarks/wiki:2.5.312 $AccountID.dkr.ecr.$region.amazonaws.com/wiki:2.5.312
    ```
3. Push the image:
    ```bash
    docker push $AccountID.dkr.ecr.$region.amazonaws.com/wiki:2.5.312
    ```
# Upload wikijs.env to S3 and enable versioning

1. Create bucket:
    ```bash
    BUCKET_ID=$RANDOM
    aws s3 mb s3://wikijs-conf-${BUCKET_ID} --region $region
    ```
2. Upload file to bucket:
    ```bash
    aws s3 cp wikijs.env s3://wikijs-conf-${BUCKET_ID}/wikijs.env
    ```
3. Enable versioning on the bucket for quick state file error recovery:
    ```bash
    aws s3api put-bucket-versioning --bucket wikijs-conf-${BUCKET_ID} \
    --versioning-configuration Status=Enabled

    ```

