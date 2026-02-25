# Place image in ECR
1. Open cloud shell
2. Create ECR repo and login:
    ```bash
    AccountID=xxxx-xxxx-xxxx
    aws ecr create-repository --repository-name wiki \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256
    aws ecr get-login-password --region eu-west-1 | \
    docker login --username AWS --password-stdin \
    $AccountID.dkr.ecr.eu-west-1.amazonaws.com
    ```
3. Pull and tag the image:
    ```bash
    docker pull ghcr.io/requarks/wiki:2.5.312
    docker tag ghcr.io/requarks/wiki:2.5.312 $AccountID.dkr.ecr.eu-west-1.amazonaws.com/wiki:2.5.312
    ```
3. Push the image:
    ```bash
    docker push $AccountID.dkr.ecr.eu-west-1.amazonaws.com/wiki:2.5.312
    ```
# Upload wikijs.env to S3

1. Create bucket:
    ```bash
    aws s3 mb s3://wikijs-conf --region eu-west-1
    ```
2. Upload file to bucket:
    ```bash
    aws s3 cp wikijs.env s3://wikijs-conf/wikijs.env
    ```

