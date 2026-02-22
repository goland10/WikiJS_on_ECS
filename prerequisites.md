# Place image in ECR
1. Open cloud shell
2. Create ECR repo:
    aws ecr create-repository --repository-name wiki --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256
3. aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 643218715566.dkr.ecr.eu-west-1.amazonaws.com
3. Pull and tag the image:
    docker pull ghcr.io/requarks/wiki:2.5.312
    docker tag ghcr.io/requarks/wiki:2.5.312 643218715566.dkr.ecr.eu-west-1.amazonaws.com/wiki:2.5.312
3. Push the image:
    docker push 643218715566.dkr.ecr.eu-west-1.amazonaws.com/wiki:2.5.312

